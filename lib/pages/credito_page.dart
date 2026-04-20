import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sistrade/services/auth_service.dart';
import '../config.dart';

// ───────────────────────────────────────────────────────────────
//  CONFIGURAÇÃO
// ───────────────────────────────────────────────────────────────

const String _kBaseUrl = AppConfig.baseUrl;

/// Intervalo de polling para checar status do pagamento (segundos)
const int _kPollingIntervalSeg = 5;

/// Timeout máximo aguardando pagamento (minutos) — mesmo valor do PIX no backend
const int _kTimeoutMinutos = 10;

/// Quantas falhas de rede consecutivas são toleradas antes de avisar o usuário
const int _kMaxFalhasRede = 4;

// ───────────────────────────────────────────────────────────────
//  MODELO — Planos
// ───────────────────────────────────────────────────────────────

class Plano {
  final int anos;
  final double valor;

  const Plano({required this.anos, required this.valor});

  String get label => '$anos anos — R\$ ${valor.toStringAsFixed(2)}';
  String get descricao => 'Acesso por $anos anos';
}

/// Gera planos de 10 em 10 anos até 100, R$50 a cada 10 anos
final List<Plano> planos = List.generate(10, (i) {
  final anos = (i + 1) * 10;
  final valor = (i + 1) * 0.50;//50.0
  return Plano(anos: anos, valor: valor);
});

// ───────────────────────────────────────────────────────────────
//  ESTADOS do fluxo de pagamento
// ───────────────────────────────────────────────────────────────

enum PaymentState {
  idle,       // aguardando seleção
  loading,    // gerando PIX
  awaiting,   // QR exibido, aguardando pagamento
  polling,    // checando status
  confirmed,  // pago e creditado
  failed,     // erro
  timeout,    // expirou
}

// ───────────────────────────────────────────────────────────────
//  SERVIÇO — chamadas reais ao backend
// ───────────────────────────────────────────────────────────────

class PaymentService {
  /// Cria preferência de pagamento PIX no backend
  static Future<Map<String, dynamic>> criarPix({
    required String userId,
    required Plano plano,
  }) async {
    final res = await http.post(
      Uri.parse('$_kBaseUrl/payments/pix'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId':    userId,
        'anos':      plano.anos,
        'valor':     plano.valor,
        'descricao': plano.descricao,
      }),
    ).timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      final body = _parseBody(res.body);
      throw Exception(body['erro'] ?? 'Erro ao gerar PIX (${res.statusCode})');
    }

    return _parseBody(res.body) as Map<String, dynamic>;
  }

  /// Consulta status do pagamento
  static Future<String> consultarStatus(String paymentId) async {
    final res = await http.get(
      Uri.parse('$_kBaseUrl/payments/$paymentId/status'),
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('Erro ao consultar status (${res.statusCode})');
    }

    final body = _parseBody(res.body);
    return body['status'] as String;
  }

  /// Credita o usuário na base de dados após confirmação
  static Future<void> creditarUsuario({
    required String userId,
    required String paymentId,
    required Plano plano,
  }) async {
    // Tenta até 3 vezes com backoff, pois esta é a operação crítica
    for (int tentativa = 1; tentativa <= 3; tentativa++) {
      try {
        final res = await http.post(
          Uri.parse('$_kBaseUrl/payments/$paymentId/credit'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId':    userId,
            'paymentId': paymentId,
            'anos':      plano.anos,
            'valor':     plano.valor,
          }),
        ).timeout(const Duration(seconds: 15));

        if (res.statusCode == 200) return; // sucesso

        final body = _parseBody(res.body);
        // 402 = pagamento não aprovado no backend — não tenta de novo
        if (res.statusCode == 402) {
          throw Exception(body['erro'] ?? 'Pagamento não aprovado no servidor.');
        }

        // Outros erros: tenta de novo
        throw Exception(body['erro'] ?? 'Erro ao registrar crédito (${res.statusCode})');

      } catch (e) {
        if (tentativa == 3) rethrow;
        // Espera antes de tentar de novo: 2s, 4s
        await Future.delayed(Duration(seconds: tentativa * 2));
      }
    }
  }

  static dynamic _parseBody(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return {};
    }
  }
}

// ───────────────────────────────────────────────────────────────
//  WIDGET PRINCIPAL
// ───────────────────────────────────────────────────────────────

class CreditoPage extends StatefulWidget {
  final Function(int) onMenuItemSelected;
  const CreditoPage({super.key, required this.onMenuItemSelected});

  @override
  State<CreditoPage> createState() => _CreditoPageState();
}

class _CreditoPageState extends State<CreditoPage>
    with TickerProviderStateMixin {

  // ── State ────────────────────────────────────────────────────
  Plano? _planoSelecionado;
  PaymentState _state = PaymentState.idle;
  String _erro = '';
  String? _paymentId;
  String? _pixCode;
  String? _pixQrBase64;
  int _pollingCount = 0;
  int _falhasRedeConsecutivas = 0;
  Timer? _pollingTimer;
  Timer? _timeoutTimer;
  bool _copiado = false;
  bool _loading = false;

  // ID do usuário logado — substitua pelo seu AuthService
  String _userId = '0';

  // ── Animações ────────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _successCtrl;
  late Animation<double> _successAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _successAnim = CurvedAnimation(
      parent: _successCtrl,
      curve: Curves.elasticOut,
    );

    _carregarUsuario();    
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _timeoutTimer?.cancel();
    _pulseCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  // ── Ações ────────────────────────────────────────────────────


  // ─────────────────────────────────────────────
  // CARREGAR USUÁRIO
  // ─────────────────────────────────────────────
  Future<void> _carregarUsuario() async {

    setState(() => _loading = true);
    try {
      final user = await AuthService.getUserData();
      // -------------------------
      // 🔢 Inteiros seguros
      // -------------------------
      _userId = user['codusuario'].toString() ?? '0';
      //nome = user['nome'] ?? '';

    //debugPrint('codusuario: $_userId');
    } catch (_) {
      setState(() => _erro = 'Erro ao carregar dados do usuário.');
    } finally {
      setState(() => _loading = false);
    }

  }


  Future<void> _gerarPix() async {
    if (_planoSelecionado == null) return;
    setState(() {
      _state = PaymentState.loading;
      _erro = '';
      _falhasRedeConsecutivas = 0;
    });

    try {
      final data = await PaymentService.criarPix(
        userId: _userId,
        plano: _planoSelecionado!,
      );
      setState(() {
        _paymentId   = data['paymentId'] as String;
        _pixCode     = data['pixCode'] as String?;
        _pixQrBase64 = data['pixQrBase64'] as String?;
        _state       = PaymentState.awaiting;
        _pollingCount = 0;
        _falhasRedeConsecutivas = 0;
      });
      _iniciarPolling();
      _iniciarTimeout();
    } catch (e) {
      setState(() {
        _state = PaymentState.failed;
        _erro = 'Erro ao gerar PIX. Verifique sua conexão e tente novamente.';
      });
    }
  }

  void _iniciarPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      Duration(seconds: _kPollingIntervalSeg),
      (_) => _verificarStatus(),
    );
  }

  void _iniciarTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(
      Duration(minutes: _kTimeoutMinutos),
      () {
        if (_state == PaymentState.awaiting || _state == PaymentState.polling) {
          _pollingTimer?.cancel();
          if (mounted) setState(() => _state = PaymentState.timeout);
        }
      },
    );
  }

  Future<void> _verificarStatus() async {
    if (_paymentId == null || !mounted) return;
    if (mounted) {
      setState(() {
      _state = PaymentState.polling;
      _pollingCount++;
    });
    }

    try {
      final status = await PaymentService.consultarStatus(_paymentId!);
      _falhasRedeConsecutivas = 0; // conexão ok, reseta contador

      if (!mounted) return;

      if (status == 'approved') {
        _pollingTimer?.cancel();
        _timeoutTimer?.cancel();

        // Tenta creditar — o backend tem retry interno, e o app tem retry aqui também
        try {
          await PaymentService.creditarUsuario(
            userId: _userId,
            paymentId: _paymentId!,
            plano: _planoSelecionado!,
          );
          if (mounted) {
            setState(() => _state = PaymentState.confirmed);
            _successCtrl.forward();
          }
        } catch (creditErr) {
          // Pagamento aprovado mas crédito falhou após retries.
          // Mostra mensagem especial — o usuário não perdeu o dinheiro,
          // pois o backend tem a fila de recuperação.
          if (mounted) {
            setState(() {
              _state = PaymentState.failed;
              _erro = 'Pagamento confirmado! Houve um problema técnico ao registrar os créditos. '
                      'Anote seu ID: $_paymentId e entre em contato com o suporte.';
            });
          }
        }

      } else if (status == 'rejected' || status == 'cancelled') {
        _pollingTimer?.cancel();
        _timeoutTimer?.cancel();
        if (mounted) {
          setState(() {
            _state = PaymentState.failed;
            _erro = 'Pagamento $status pelo banco. Tente novamente.';
          });
        }
      } else {
        // pending — volta a aguardando
        if (mounted) setState(() => _state = PaymentState.awaiting);
      }

    } catch (_) {
      // Falha de rede — incrementa contador mas não para o polling
      _falhasRedeConsecutivas++;
      if (mounted) {
        setState(() => _state = PaymentState.awaiting);
        // Após muitas falhas consecutivas, avisa o usuário sem cancelar o processo
        if (_falhasRedeConsecutivas >= _kMaxFalhasRede) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verificando conexão... O pagamento continua ativo.'),
              backgroundColor: Color(0xFFF59E0B),
              duration: Duration(seconds: 4),
            ),
          );
          _falhasRedeConsecutivas = 0; // reseta para não spam de mensagens
        }
      }
    }
  }

  void _copiarCodigo() {
    if (_pixCode == null) return;
    Clipboard.setData(ClipboardData(text: _pixCode!));
    setState(() => _copiado = true);
    Future.delayed(const Duration(seconds: 3),
        () { if (mounted) setState(() => _copiado = false); });
  }

  void _reiniciar() {
    _pollingTimer?.cancel();
    _timeoutTimer?.cancel();
    _successCtrl.reset();
    setState(() {
      _state = PaymentState.idle;
      _planoSelecionado = null;
      _paymentId  = null;
      _pixCode    = null;
      _pixQrBase64 = null;
      _erro = '';
      _pollingCount = 0;
      _falhasRedeConsecutivas = 0;
      _copiado = false;
    });
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: _CColors.bg,
      appBar: _buildAppBar(isMobile),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.06),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _buildBody(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(bool isMobile) {
    return AppBar(
      /*title: const Text(
        'Adquirir Créditos',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      backgroundColor: _CColors.appBar,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _CColors.border),
      ),*/
      automaticallyImplyLeading: false,
      backgroundColor: Color(0xFF131E30),
      elevation: 0,
      centerTitle: isMobile,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.credit_card_rounded, color: Color(0xFF38BDF8), size: 18),
          SizedBox(width: 8),
          Text('Adquirir Créditos',
              style: TextStyle(color: Color(0xFFF1F5F9), fontSize: 17)),
        ],
      ),
      actions: isMobile
          ? null
          : [
              ...[
              _NavBtn('Home',    0, widget.onMenuItemSelected),
              _NavBtn('Mapa',    1, widget.onMenuItemSelected),
              _NavBtn('Perfil',  2, widget.onMenuItemSelected),
              _NavBtn('Credito', 3, widget.onMenuItemSelected, active: true,),
              _NavBtn('Sair', -1, widget.onMenuItemSelected),
            ],
              const SizedBox(width: 12),
            ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color:  Color(0xFF1E3A5F)),
        ),

    );
  }

  Widget _buildBody() {
    switch (_state) {
      case PaymentState.confirmed:
        return _buildSuccess();
      case PaymentState.timeout:
        return _buildTimeout();
      case PaymentState.failed:
        return _buildError();
      case PaymentState.awaiting:
      case PaymentState.polling:
        return _buildPix();
      default:
        return _buildSelector();
    }
  }

  // ── TELA 1: Seleção de plano ──────────────────────────────────

  Widget _buildSelector() {
    return Column(
      key: const ValueKey('selector'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: 28),
        _buildPlanCard(),
        const SizedBox(height: 20),
        if (_planoSelecionado != null) _buildResumoPlano(),
        const SizedBox(height: 20),
        _buildPixInfo(),
        const SizedBox(height: 28),
        _buildBotaoGerar(),
        const SizedBox(height: 16),
        _buildSeguranca(),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00B37E), Color(0xFF00875A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00B37E).withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.pix, color: Colors.white, size: 34),
        ),
        const SizedBox(height: 16),
        const Text(
          'Adquirir Créditos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Escolha seu plano e pague via PIX em segundos',
          textAlign: TextAlign.center,
          style: TextStyle(color: _CColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildPlanCard() {
    return _card(
      title: 'Escolha o Plano',
      icon: Icons.star_outline_rounded,
      iconColor: const Color(0xFFF59E0B),
      children: [
        DropdownButtonFormField<Plano>(
          initialValue: _planoSelecionado,
          decoration: _inputDec('Selecione um plano', Icons.calendar_today_outlined),
          dropdownColor: _CColors.cardBg,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          hint: const Text(
            'Selecione um plano',
            style: TextStyle(color: _CColors.textSecondary, fontSize: 14),
          ),
          items: planos.map((p) {
            return DropdownMenuItem<Plano>(
              value: p,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B37E).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${p.anos}a',
                      style: const TextStyle(
                        color: Color(0xFF00B37E),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(p.label,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14)),
                ],
              ),
            );
          }).toList(),
          onChanged: (p) => setState(() => _planoSelecionado = p),
        ),
      ],
    );
  }

  Widget _buildResumoPlano() {
    final p = _planoSelecionado!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00B37E).withOpacity(0.12),
            const Color(0xFF00875A).withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF00B37E).withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Resumo do pedido',
                    style: TextStyle(
                        color: _CColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 4),
                Text(
                  p.descricao,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Total', style: TextStyle(
                  color: _CColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 4),
              Text(
                'R\$ ${p.valor.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF00B37E),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPixInfo() {
    return _card(
      title: 'Como funciona o PIX',
      icon: Icons.info_outline_rounded,
      iconColor: _CColors.accent,
      children: [
        _step('1', 'Toque em "Gerar PIX"', 'Um QR Code será criado para você'),
        const SizedBox(height: 10),
        _step('2', 'Abra seu banco', 'Escaneie o QR ou cole o código PIX'),
        const SizedBox(height: 10),
        _step('3', 'Confirme o pagamento', 'Aprovação em segundos, 24h por dia'),
        const SizedBox(height: 10),
        _step('4', 'Créditos liberados', 'Atualização automática na sua conta'),
      ],
    );
  }

  Widget _step(String num, String titulo, String sub) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: _CColors.accent.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: _CColors.accent.withOpacity(0.4)),
          ),
          child: Center(
            child: Text(num,
                style: const TextStyle(
                    color: _CColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              if (sub.isNotEmpty)
                Text(sub,
                    style: const TextStyle(
                        color: _CColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBotaoGerar() {
    final habilitado = _planoSelecionado != null &&
        _state != PaymentState.loading;

    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: habilitado ? _gerarPix : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00B37E),
          disabledBackgroundColor: _CColors.border,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: habilitado ? 4 : 0,
          shadowColor: const Color(0xFF00B37E).withOpacity(0.4),
        ),
        child: _state == PaymentState.loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pix, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Gerar PIX',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSeguranca() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline,
            size: 13, color: _CColors.textSecondary.withOpacity(0.7)),
        const SizedBox(width: 6),
        Text(
          'Pagamento seguro via Mercado Pago',
          style: TextStyle(
              color: _CColors.textSecondary.withOpacity(0.7), fontSize: 11),
        ),
      ],
    );
  }

  // ── TELA 2: QR Code + aguardando ────────────────────────────

  Widget _buildPix() {
    final isPoll = _state == PaymentState.polling;

    return Column(
      key: const ValueKey('pix'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white70, size: 18),
              onPressed: _reiniciar,
            ),
            const Expanded(
              child: Text(
                'Aguardando Pagamento',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
        const SizedBox(height: 20),

        // Resumo do valor
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF00B37E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFF00B37E).withOpacity(0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _planoSelecionado?.descricao ?? '',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                'R\$ ${_planoSelecionado?.valor.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF00B37E),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // QR Code
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _CColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _CColors.border),
          ),
          child: Column(
            children: [
              _buildStatusBadge(isPoll),
              const SizedBox(height: 20),
              ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _buildQrWidget(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Escaneie o QR Code no seu banco',
                style: TextStyle(color: _CColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (_pixCode != null) _buildCopiaECola(),
        const SizedBox(height: 20),

        _card(
          title: 'Como pagar',
          icon: Icons.smartphone_outlined,
          iconColor: _CColors.accent,
          children: [
            _step('1', 'Abra o app do seu banco', ''),
            const SizedBox(height: 8),
            _step('2', 'Escolha pagar via PIX', 'Use "Pix Copia e Cola" ou QR Code'),
            const SizedBox(height: 8),
            _step('3', 'Cole o código ou escaneie', 'Confira o valor antes de confirmar'),
            const SizedBox(height: 8),
            _step('4', 'Pronto!', 'Confirmamos automaticamente em segundos'),
          ],
        ),
        const SizedBox(height: 12),

        OutlinedButton(
          onPressed: _reiniciar,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.redAccent.withOpacity(0.4)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Cancelar e escolher outro plano',
              style: TextStyle(color: Colors.redAccent, fontSize: 13)),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatusBadge(bool isPoll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isPoll) ...[
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
                color: Color(0xFFF59E0B), strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          const Text('Verificando pagamento...',
              style: TextStyle(color: Color(0xFFF59E0B), fontSize: 13)),
        ] else ...[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withOpacity(0.5),
                  blurRadius: 8,
                )
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Aguardando pagamento...',
            style: TextStyle(color: Color(0xFFF59E0B), fontSize: 13),
          ),
        ],
      ],
    );
  }

  /// Prioriza a imagem base64 do MP; se não tiver, usa qr_flutter com o código copia-e-cola
  Widget _buildQrWidget() {
    if (_pixQrBase64 != null) {
      try {
        return Image.memory(base64Decode(_pixQrBase64!), width: 200, height: 200);
      } catch (_) {
        // base64 inválido — cai para qr_flutter
      }
    }
    if (_pixCode != null) {
      return QrImageView(
        data: _pixCode!,
        size: 200,
        backgroundColor: Colors.white,
      );
    }
    // Nenhum dado disponível ainda
    return const SizedBox(
      width: 200,
      height: 200,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildCopiaECola() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _CColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _CColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _pixCode!.length > 50
                  ? '${_pixCode!.substring(0, 50)}...'
                  : _pixCode!,
              style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _copiarCodigo,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _copiado
                    ? const Color(0xFF00B37E).withOpacity(0.2)
                    : _CColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _copiado
                      ? const Color(0xFF00B37E)
                      : _CColors.accent.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _copiado ? Icons.check : Icons.copy_outlined,
                    size: 14,
                    color: _copiado ? const Color(0xFF00B37E) : _CColors.accent,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _copiado ? 'Copiado!' : 'Copiar',
                    style: TextStyle(
                      color: _copiado ? const Color(0xFF00B37E) : _CColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TELA 3: Sucesso ───────────────────────────────────────────

  Widget _buildSuccess() {
    return ScaleTransition(
      scale: _successAnim,
      child: Column(
        key: const ValueKey('success'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00B37E).withOpacity(0.15),
              border: Border.all(
                  color: const Color(0xFF00B37E).withOpacity(0.5), width: 2),
            ),
            child: const Icon(Icons.check_circle_outline_rounded,
                color: Color(0xFF00B37E), size: 52),
          ),
          const SizedBox(height: 24),
          const Text(
            'Pagamento Confirmado!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Plano ${_planoSelecionado?.descricao ?? ''} ativado com sucesso.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: _CColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${_planoSelecionado?.valor.toStringAsFixed(2) ?? ''}',
            style: const TextStyle(
              color: Color(0xFF00B37E),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _CColors.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _CColors.border),
            ),
            child: Column(
              children: [
                _infoRow('ID do pagamento', _paymentId ?? '—'),
                const Divider(color: _CColors.border, height: 20),
                _infoRow('Plano', _planoSelecionado?.label ?? '—'),
                const Divider(color: _CColors.border, height: 20),
                _infoRow('Status', '✅ Aprovado'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _reiniciar,
              style: ElevatedButton.styleFrom(
                backgroundColor: _CColors.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Voltar ao início',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── TELA 4: Erro ──────────────────────────────────────────────

  Widget _buildError() {
    // Detecta se é o caso especial de "pagamento ok mas crédito falhou"
    final bool pagamentoConfirmado = _erro.contains('Pagamento confirmado');

    return Column(
      key: const ValueKey('error'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pagamentoConfirmado
                ? const Color(0xFFF59E0B).withOpacity(0.12)
                : Colors.redAccent.withOpacity(0.12),
            border: Border.all(
                color: pagamentoConfirmado
                    ? const Color(0xFFF59E0B).withOpacity(0.4)
                    : Colors.redAccent.withOpacity(0.4),
                width: 1.5),
          ),
          child: Icon(
            pagamentoConfirmado
                ? Icons.warning_amber_outlined
                : Icons.error_outline_rounded,
            color: pagamentoConfirmado
                ? const Color(0xFFF59E0B)
                : Colors.redAccent,
            size: 44,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          pagamentoConfirmado ? 'Atenção' : 'Ops! Algo deu errado',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _erro,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _CColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 32),
        if (!pagamentoConfirmado)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _reiniciar,
              icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
              label: const Text('Tentar novamente',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B37E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        const SizedBox(height: 40),
      ],
    );
  }

  // ── TELA 5: Timeout ───────────────────────────────────────────

  Widget _buildTimeout() {
    return Column(
      key: const ValueKey('timeout'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF59E0B).withOpacity(0.12),
            border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.4), width: 1.5),
          ),
          child: const Icon(Icons.timer_off_outlined,
              color: Color(0xFFF59E0B), size: 44),
        ),
        const SizedBox(height: 20),
        const Text('PIX expirado',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'O tempo de $_kTimeoutMinutos minutos para pagamento expirou.\n'
          'Gere um novo PIX para continuar.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: _CColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _reiniciar,
            icon: const Icon(Icons.pix, color: Colors.white, size: 18),
            label: const Text('Gerar novo PIX',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B37E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // ── Utilitários de UI ─────────────────────────────────────────

  Widget _card({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _CColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _CColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 7),
            Text(title,
                style: TextStyle(
                    color: iconColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8)),
          ]),
          const SizedBox(height: 12),
          const Divider(color: _CColors.border, height: 1),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: _CColors.textSecondary, fontSize: 13)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  InputDecoration _inputDec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          const TextStyle(color: _CColors.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: _CColors.textSecondary, size: 20),
      filled: true,
      fillColor: _CColors.inputFill,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _CColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _CColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _CColors.accent, width: 1.5),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ───────────────────────────────────────────────────────────────

abstract class _CColors {
  static const bg          = Color(0xFF0A0F1E);
  static const appBar      = Color(0xFF0D1426);
  static const cardBg      = Color(0xFF111827);
  static const border      = Color(0xFF1E2A40);
  static const inputFill   = Color(0xFF0D1426);
  static const accent      = Color(0xFF3B82F6);
  static const textSecondary = Color(0xFF6B7280);
}

// ───────────────────────────────────────────────────────────────
//  NAV BUTTON
// ───────────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final String label;
  final int index;
  final Function(int) onTap;
  final bool active;

  const _NavBtn(this.label, this.index, this.onTap, {this.active=false});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onTap(index),
      style: TextButton.styleFrom(
        foregroundColor: active ? Color(0xFF38BDF8) : Color(0xFF94A3B8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),      

      /*child: Text(label,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500)),
              */
    );
  }
}
