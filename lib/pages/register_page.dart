import 'package:flutter/material.dart';
import 'package:sistrade/models/usuario_model.dart';
import 'package:sistrade/pages/login_page.dart';
import 'package:sistrade/screens/dashboard/home_screen.dart';
import 'package:sistrade/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmSenhaController = TextEditingController();
  final _enderecoController = TextEditingController();

  // ── State ─────────────────────────────────────────────────────
  DateTime? _dataNascimento;
  String _sexo = '';
  bool _loading = false;
  bool _senhaVisivel = false;
  bool _confirmSenhaVisivel = false;
  String _erro = '';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Lifecycle ─────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmSenhaController.dispose();
    _enderecoController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Usuario _montarItem() {
        //print('02.01');

    return Usuario(
      codusuario:          0,
      nome: _nomeController.text,
      email: _emailController.text.trim(),
      senha: _senhaController.text,
      data_nascimento:  _dataNascimento,
      sexo: _sexo,
      endereco: _enderecoController.text.trim(),
    );

  }
  
  // ── Actions ───────────────────────────────────────────────────
  Future<void> _cadastrar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    //print('01');

    setState(() {
      _loading = true;
      _erro = '';
    });

    try {
      /*final data = {
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'senha': _senhaController.text,
        'dataNascimento': _dataNascimento?.toIso8601String(),
        'sexo': _sexo,
        'endereco': _enderecoController.text.trim(),
      };*/


      final email = await AuthService.getEmail(email: _emailController.text);
      if ((email != null) && (email != '')) {
          final confirmar = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Atenção!'),
              content: const Text('Email (Login) já cadastrado.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('OK')),
              ],
            ),
          );
          
          return;
      }


    //print('02');
      final itemParaSalvar = _montarItem();
    //print('03');

      final result = await AuthService.createUsuarios(itemParaSalvar);
    //print('04');

      await Future.delayed(const Duration(milliseconds: 800)); // simulação

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _erro = 'Erro ao cadastrar. Tente novamente.$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _AppColors.accent,
            onPrimary: Colors.white,
            surface: _AppColors.cardBg,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dataNascimento = picked);
  }

  // ── Helpers ───────────────────────────────────────────────────
  String get _dataFormatada {
    if (_dataNascimento == null) return 'Selecione a data';
    final d = _dataNascimento!;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  // ── UI ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.bg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_AppColors.bg, Color(0xFF0D1426)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: _buildCard(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: _AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 28),
            if (_erro.isNotEmpty) ...[
              _buildErro(),
              const SizedBox(height: 16),
            ],
            _buildSectionLabel('Dados Pessoais', Icons.person_outline),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _nomeController,
              label: 'Nome completo',
              icon: Icons.person_outline,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _emailController,
              label: 'E-mail',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                if (!v.contains('@') || !v.contains('.')) {
                  return 'E-mail inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildSectionLabel('Segurança', Icons.lock_outline),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _senhaController,
              label: 'Senha',
              icon: Icons.lock_outline,
              obscure: !_senhaVisivel,
              suffixIcon: IconButton(
                icon: Icon(
                  _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                  color: _AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _senhaVisivel = !_senhaVisivel),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe a senha';
                if (v.length < 6) return 'Mínimo de 6 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _confirmSenhaController,
              label: 'Confirmar senha',
              icon: Icons.lock_outline,
              obscure: !_confirmSenhaVisivel,
              suffixIcon: IconButton(
                icon: Icon(
                  _confirmSenhaVisivel
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: _AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(
                    () => _confirmSenhaVisivel = !_confirmSenhaVisivel),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirme a senha';
                if (v != _senhaController.text) {
                  return 'As senhas não coincidem';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildSectionLabel('Informações Adicionais', Icons.assignment_ind_outlined),
            const SizedBox(height: 12),
            /*
            _buildDateField(
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe a data de nascimento' : null,
            ),
            */
            _buildDateField(
              validator: (value) {
                if (_dataNascimento == null) {
                  return 'Informe a data de nascimento';
                }
                return null;
              },
            ),            
            const SizedBox(height: 12),
            /*
            _buildSexoField(
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe sexo biologico' : null,

            ),*/

            _buildSexoField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Selecione o sexo';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _enderecoController,
              label: 'Endereço',
              icon: Icons.home_outlined,
            ),
            const SizedBox(height: 28),
            _buildCadastrarButton(),
            const SizedBox(height: 20),
            _buildLoginLink(),
          ],
        ),
      ),
    );
  }

  // ── Componentes ───────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [_AppColors.accent, Color(0xFF0EA5E9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _AppColors.accent.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.person_add_outlined,
              color: Colors.white, size: 28),
        ),
        const SizedBox(height: 16),
        const Text(
          'Criar conta',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Preencha os dados para se cadastrar',
          style: TextStyle(color: _AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _AppColors.accent),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: _AppColors.accent,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: _AppColors.cardBorder)),
      ],
    );
  }

  Widget _buildErro() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _erro,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration(label, icon, suffixIcon: suffixIcon),
    );
  }

/*
  Widget _buildDateField({String? Function(String?)? validator,}) {
    return InkWell(
      onTap: _selecionarData,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: _inputDecoration('Data de nascimento', Icons.cake_outlined),
        child: Text(
          _dataFormatada,
          style: TextStyle(
            color: _dataNascimento != null
                ? Colors.white
                : _AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSexoField({String? Function(String?)? validator,}) {
    return DropdownButtonFormField<String>(
      initialValue: _sexo.isEmpty ? null : _sexo,
      decoration: _inputDecoration('Sexo biológico', Icons.people_outline),
      dropdownColor: _AppColors.cardBg,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      items: const [
        DropdownMenuItem(value: 'M', child: Text('Masculino')),
        DropdownMenuItem(value: 'F', child: Text('Feminino')),
      ],
      onChanged: (value) => setState(() => _sexo = value ?? ''),
    );
  }
*/

Widget _buildSexoField({String? Function(String?)? validator}) {
  return DropdownButtonFormField<String>(
    initialValue: _sexo.isEmpty ? null : _sexo,
    decoration: _inputDecoration('Sexo biológico', Icons.people_outline),
    dropdownColor: _AppColors.cardBg,
    style: const TextStyle(color: Colors.white, fontSize: 14),
    items: const [
      DropdownMenuItem(value: 'M', child: Text('Masculino')),
      DropdownMenuItem(value: 'F', child: Text('Feminino')),
    ],
    onChanged: (value) => setState(() => _sexo = value ?? ''),
    validator: validator, // ✅ AQUI
  );
}

Widget _buildDateField({String? Function(String?)? validator}) {
  return FormField<String>(
    validator: (value) {
      if (validator != null) {
        return validator(_dataNascimento?.toIso8601String());
      }
      return null;
    },
    builder: (field) {
      return InkWell(
        onTap: () async {
          await _selecionarData();
          field.didChange(_dataNascimento?.toIso8601String());
        },
        borderRadius: BorderRadius.circular(10),
        child: InputDecorator(
          decoration: _inputDecoration(
            'Data de nascimento',
            Icons.cake_outlined,
          ).copyWith(
            errorText: field.errorText, // 🔥 mostra erro
          ),
          child: Text(
            _dataFormatada,
            style: TextStyle(
              color: _dataNascimento != null
                  ? Colors.white
                  : _AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildCadastrarButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _loading ? null : _cadastrar,
        style: ElevatedButton.styleFrom(
          backgroundColor: _AppColors.accent,
          disabledBackgroundColor: _AppColors.accent.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Criar conta',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Já tem uma conta? ',
          style: TextStyle(color: _AppColors.textSecondary, fontSize: 13),
        ),

        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const LoginScreen()),
          ),
          mouseCursor: SystemMouseCursors.click,
          child: const Text(
            'Fazer login',
            style: TextStyle(
              color: _AppColors.accent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

/*
        InkWell(
          onTap: () => Navigator.pop(context),
          mouseCursor: SystemMouseCursors.click,
          child: const Text(
            'Fazer login',
            style: TextStyle(
              color: _AppColors.accent,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
*/
        const SizedBox(width: 32),

        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const HomeScreen()),
          ),
          mouseCursor: SystemMouseCursors.click,
          child: const Text(
            'Voltar',
            style: TextStyle(
              color: _AppColors.accent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),


      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          const TextStyle(color: _AppColors.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: _AppColors.textSecondary, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _AppColors.inputFill,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}

// ── Design Tokens ─────────────────────────────────────────────
abstract class _AppColors {
  static const bg = Color(0xFF0A0F1E);
  static const cardBg = Color(0xFF111827);
  static const cardBorder = Color(0xFF1E2A40);
  static const inputFill = Color(0xFF0D1426);
  static const accent = Color(0xFF3B82F6);
  static const textSecondary = Color(0xFF6B7280);
}
















/*
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmSenhaController = TextEditingController();
  final enderecoController = TextEditingController();

  DateTime? dataNascimento;
  String sexo = '';

  bool loading = false;
  String erro = '';

  void cadastrar() async {
    setState(() {
      loading = true;
      erro = '';
    });

    // ================= VALIDAÇÕES =================
    if (senhaController.text != confirmSenhaController.text) {
      setState(() {
        erro = 'As senhas não coincidem';
        loading = false;
      });
      return;
    }

    if (senhaController.text.length < 6) {
      setState(() {
        erro = 'A senha deve ter no mínimo 6 caracteres';
        loading = false;
      });
      return;
    }

    final data = {
      'nome': nomeController.text,
      'email': emailController.text,
      'senha': senhaController.text,
      'dataNascimento': dataNascimento?.toIso8601String(),
      'sexo': sexo,
      'endereco': enderecoController.text,
    };

    //final result = await AuthService.register(data);

    setState(() {
      loading = false;
    });

    /*if (!result['success']) {
      setState(() {
        erro = result['message'];
      });
      return;
    }*/

    // 🔥 Volta pro login
    if (mounted) {
      Navigator.pop(context);
    }
  }

  // ================= DATE PICKER =================
  Future<void> selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        dataNascimento = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // 🎨 mesmo estilo do login
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              padding: const EdgeInsets.all(20),

              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(24),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      const Text(
                        'Cadastro',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (erro.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            erro,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      // ================= CAMPOS =================

                      TextField(
                        controller: nomeController,
                        decoration: _input('Nome', Icons.person),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: emailController,
                        decoration: _input('Email', Icons.email),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: senhaController,
                        obscureText: true,
                        decoration: _input('Senha', Icons.lock),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: confirmSenhaController,
                        obscureText: true,
                        decoration: _input('Confirmar Senha', Icons.lock_outline),
                      ),

                      const SizedBox(height: 12),

                      // ================= DATA =================
                      InkWell(
                        onTap: selecionarData,
                        child: InputDecorator(
                          decoration: _input('Data de Nascimento', Icons.calendar_today),
                          child: Text(
                            dataNascimento != null
                                ? "${dataNascimento!.day}/${dataNascimento!.month}/${dataNascimento!.year}"
                                : 'Selecione a data',
                            style: TextStyle(
                              color: dataNascimento != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================= SEXO =================
                      DropdownButtonFormField<String>(
                        initialValue: sexo.isEmpty ? null : sexo,
                        decoration: _input('Sexo', Icons.people),
                        items: const [
                          DropdownMenuItem(value: 'M', child: Text('Masculino')),
                          DropdownMenuItem(value: 'F', child: Text('Feminino')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            sexo = value ?? '';
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: enderecoController,
                        decoration: _input('Endereço', Icons.home),
                      ),

                      const SizedBox(height: 20),

                      // ================= BOTÃO =================
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading ? null : cadastrar,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.blue,
                          ),
                          child: loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Cadastrar'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ================= VOLTAR LOGIN =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Já tem uma conta? '),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Faça login',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= ESTILO INPUT =================
  InputDecoration _input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
*/
