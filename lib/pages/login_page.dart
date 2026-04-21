import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistrade/screens/dashboard/home_screen.dart';
import '../services/auth_service.dart';
import '../screens/main_screen.dart';
import 'register_page.dart';

// ─────────────────────────────────────────────
// DESIGN TOKENS (alinhados ao sistema)
// ─────────────────────────────────────────────
const _bg          = Color(0xFF0B1120);
const _surface     = Color(0xFF131E30);
const _surface2    = Color(0xFF1A2740);
const _accent      = Color(0xFF38BDF8);
const _accentDark  = Color(0xFF0EA5E9);
const _textPrimary   = Color(0xFFF1F5F9);
const _textSecondary = Color(0xFF94A3B8);
const _border      = Color(0xFF1E3A5F);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
 // int _pagina = 0;
 // String _nome = 'Usuário';


  bool _senhaVisivel = false;
  bool _carregando   = false;
  String _erro       = '';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  /*
  void _ir(int pagina) => setState(() => _pagina = pagina);

  // ── AppBar ──
  AppBar _buildAppBar(bool isMobile) {
    return AppBar(
      backgroundColor: _surface,
      elevation: 0,
      centerTitle: isMobile,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(
              color: _accentDark, shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _nome.isNotEmpty ? _nome[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Ciclo da Vida',
            style: TextStyle(
              color: _textPrimary, fontSize: 17, fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: isMobile
          ? null
          : [
              _navBtn('Home',   0),
              _navBtn('Login',   1),
              const SizedBox(width: 8),
            ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _border),
      ),
    );
  }

  Widget _navBtn(String label, int index) {
    final active = _pagina == index;
    return TextButton(
      onPressed: () => _ir(index),
      style: TextButton.styleFrom(
        foregroundColor: active ? _accent : _textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }
*/
  // ─────────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────────
  Future<void> _fazerLogin() async {
    setState(() { _carregando = true; _erro = ''; });

    // ⚠️ REMOVER ANTES DE PRODUÇÃO
    _emailCtrl.text = 'martorele@gmail.com';
    _senhaCtrl.text = '12345678';

    try {
      final resultado = await AuthService.login(
        _emailCtrl.text.trim(),
        _senhaCtrl.text,
      );

      if (!mounted) return;

      if (resultado['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final user  = resultado['user'] ?? {};

        await prefs.setInt('codusuario',     user['codusuario'] ?? 0);
        await prefs.setString('nome',           user['nome']           ?? '');
        await prefs.setString('email',          user['email']          ?? '');
        await prefs.setString('endereco',       user['endereco']       ?? '');
        await prefs.setString('sexo',           user['sexo']           ?? '');
        await prefs.setString('dataNascimento', user['data_nascimento'] ?? '');
        await prefs.setString('dataInicial',    user['datainicial'] ?? '');
        await prefs.setInt('anos',           user['anos'] ?? 0);
        await prefs.setString('fctoken',        resultado['token']     ?? '');

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        setState(() => _erro = resultado['message'] ?? 'Erro ao fazer login.');
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 700;

    return Scaffold(
      backgroundColor: _bg,
      //appBar: _buildAppBar(isMobile),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogo(),
                const SizedBox(height: 32),
                _buildCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Logo + título ──
  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: _accentDark.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: _accentDark.withOpacity(0.4), width: 1.5),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.loop, color: _accent, size: 36),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Ciclo da Vida',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Acesse sua conta',
          style: TextStyle(color: _textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  // ── Card principal ──
  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // Erro
          if (_erro.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF3F1515),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF7F1D1D)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFFCA5A5), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _erro,
                      style: const TextStyle(
                          color: Color(0xFFFCA5A5), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Email
          _buildInput(
            controller: _emailCtrl,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 14),

          // Senha
          _buildInput(
            controller: _senhaCtrl,
            label: 'Senha',
            icon: Icons.lock_outline,
            obscure: !_senhaVisivel,
            suffix: IconButton(
              icon: Icon(
                _senhaVisivel
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: _textSecondary,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _senhaVisivel = !_senhaVisivel),
            ),
          ),

          const SizedBox(height: 24),

          // Botão entrar
          _buildBotaoEntrar(),

          const SizedBox(height: 20),

          // Link cadastro
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Não tem uma conta? ',
                style: TextStyle(color: _textSecondary, fontSize: 13),
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RegisterScreen()),
                ),
                mouseCursor: SystemMouseCursors.click,
                child: const Text(
                  'Cadastre-se',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

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
                    color: _accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),


            ],
          ),
        ],
      ),
    );
  }

  // ── Input padrão ──
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: _textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textSecondary, fontSize: 14),
        prefixIcon: Icon(icon, color: _accent, size: 18),
        suffixIcon: suffix,
        filled: true,
        fillColor: _surface2,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ── Botão entrar ──
  Widget _buildBotaoEntrar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _carregando ? null : _fazerLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentDark,
          disabledBackgroundColor: _surface2,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _carregando
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Text(
                'Entrar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}











/*
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/main_screen.dart';
import 'register_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool _senhaVisivel = false;
  bool carregando = false;
  String mensagemErro = '';

  void fazerLogin() async {
    setState(() {
      carregando = true;
      mensagemErro = '';
    });

    /*ESSAS LINHAS DEVEM SER COMENTADAS ANTES DE ENVIAR PARA PRODUÇÃO*/
      emailController.text = 'martorele@gmail.com';
      senhaController.text = '12345678';

    final resultado = await AuthService.login(
      emailController.text,
      senhaController.text,
    );

    setState(() {
      carregando = false;
    });

    if (resultado['success']) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('nome', resultado['user']['nome'] ?? '');
      await prefs.setString('email', resultado['user']['email'] ?? '');
      await prefs.setString('endereco', resultado['user']['endereco'] ?? '');
      await prefs.setString('sexo', resultado['user']['sexo'] ?? '');
      //if (resultado['dataNascimento'] != null) {
        await prefs.setString('dataNascimento', resultado['user']['data_nascimento'] ?? '');
      //}
      await prefs.setString('fctoken', resultado['token'] ?? '');
      //print('Token salvo: ${resultado['token']}');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } else {
      setState(() {
        mensagemErro = resultado['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // 🎨 Gradiente igual React
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
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

                      // ================= LOGO =================
                      Image.asset(
                        'assets/images/logo.png',
                        width: 80,
                        height: 80,
                      ),

                      const SizedBox(height: 16),

                      // ================= TITULO =================
                      const Text(
                        'Ciclo da Vida',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Acesse sua conta',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ================= ERRO =================
                      if (mensagemErro.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            mensagemErro,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      // ================= EMAIL =================
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ================= SENHA =================
                      TextField(
                        controller: senhaController,
                        obscureText: !_senhaVisivel,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _senhaVisivel
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _senhaVisivel = !_senhaVisivel;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= BOTÃO =================
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: carregando ? null : fazerLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.blue,
                          ),
                          child: carregando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Entrar',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ================= LINK =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Não tem uma conta? '),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Cadastre-se',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      )                      
                      

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
}

*/













/*
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/main_screen.dart';
import '../../constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  bool _senhaVisivel = false;

  String mensagemErro = '';
  bool carregando = false;

  void fazerLogin() async {
    setState(() {
      carregando = true;
      mensagemErro = '';
    });
    
    /*ESSAS LINHAS DEVEM SER COMENTADAS ANTES DE ENVIAR PARA PRODUÇÃO*/
      emailController.text = 'usuario00@empresa01.com';
      senhaController.text = '12345678';
    /**/


    final resultado = await AuthService.login(
      emailController.text,
      senhaController.text,
    );

    setState(() {
      carregando = false;
    });

    if (resultado['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nome', resultado['user']['nome'] ?? 'Usuário');
      await prefs.setString('email', resultado['user']['email'] ?? '');
      await prefs.setString('fctoken', resultado['token'] ?? '');
      await prefs.setString('empresa', resultado['user']['empresa'] ?? '');

      if (resultado['idvendedor'] != null) {
        await prefs.setInt(
          'idvendedor',
          int.tryParse(resultado['idvendedor'].toString()) ?? 0,
        );
      }

      if (resultado['idusuario'] != null) {
        await prefs.setInt(
          'idusuario',
          int.tryParse(resultado['idusuario'].toString()) ?? 0,
        );
      }

      if (resultado['idempresa'] != null) {
        await prefs.setInt(
          'idempresa',
          int.tryParse(resultado['idempresa'].toString()) ?? 0,
        );
      }

      // 🔹 Converte listas para List<String> antes de salvar
      final rawPermissoes = resultado['permissoes'] ?? [];
      final rawGrupos = resultado['grupos'] ?? [];

      final permissoesList = (rawPermissoes as List)
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();

      final gruposList = (rawGrupos as List)
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();

      await prefs.setStringList('permissoes', permissoesList);
      await prefs.setStringList('grupos', gruposList);


      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    }    
    else {
      setState(() {
        mensagemErro = resultado['message'];
      });
    }

  }

  // === NOVO: método para exibir dialog de recuperação de senha ===
  void _mostrarDialogEsqueciSenha() {
    final TextEditingController emailResetController = TextEditingController();

    // Salva o contexto da tela pai
    final scaffoldContext = context;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Recuperar senha",
            style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Digite seu e-mail cadastrado. Você receberá instruções para redefinir sua senha.",
                style: TextStyle(fontSize: 14, fontFamily: "Poppins"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailResetController,
                decoration: const InputDecoration(
                  labelText: "E-mail",
                  prefixIcon: Icon(Icons.email),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Enviar",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                final email = emailResetController.text.trim();
                if (email.isEmpty) return;

                Navigator.pop(context); // fecha o dialog

                // Mostra o SnackBar de "Enviando"
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  const SnackBar(content: Text("Enviando solicitação...")),
                );

                try {
                  final resultado = await AuthService.forgotPassword(email);
                  //print(resultado);

                  // Mostra o SnackBar com o resultado
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        resultado['message'] ?? 'Verifique seu e-mail.',
                      ),
                    ),
                  );
                } catch (e) {
                  // Caso dê erro na requisição
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    SnackBar(content: Text('Erro ao enviar solicitação: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 600 ? 550 : double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: const AssetImage('assets/images/logo.png'),
                        ),
                      ),
                      // Card login
                      Card(
                        elevation: 20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  labelText: 'E-mail',
                                  prefixIcon: Icon(Icons.email),
                                  labelStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: senhaController,
                                obscureText: !_senhaVisivel,
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  labelStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _senhaVisivel
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _senhaVisivel = !_senhaVisivel;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _mostrarDialogEsqueciSenha,
                                  child: const Text(
                                    'Esqueci a senha',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                              if (mensagemErro.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  mensagemErro,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                              const SizedBox(height: 16),

                              SizedBox(

                                width: double.infinity,
                                child: 
                              _MenuButton(
                                title: "Entrar",
                                icon: Icons.lock_open,
                                color: Colors.blue,
                                onTap: fazerLogin,
                                isLoading: carregando,
                              ),
                          
                          
                          ),



                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ====================================
  // WIDGET BOTÃO MODERNO
  // ====================================
  Widget _MenuButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool enabled = true,
    bool isLoading = false, 
  }) {
    final bool isDisabled = !enabled || isLoading;
    final Color effectiveColor = isDisabled ? Colors.grey : color;

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isDisabled ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: 120,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: effectiveColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: effectiveColor.withOpacity(0.3)),
            boxShadow: !isDisabled
                ? [
                    BoxShadow(
                      color: effectiveColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// 🔄 Ícone ↔ Loader com animação
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: isLoading
                    ? SizedBox(
                        key: const ValueKey('loader'),
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(effectiveColor),
                        ),
                      )
                    : Icon(
                        icon,
                        key: const ValueKey('icon'),
                        color: effectiveColor,
                        size: 15,
                      ),
              ),

              const SizedBox(width: 8),

              /// 📝 Texto com animação suave
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    isLoading ? 'Processando...' : title,
                    key: ValueKey(isLoading),
                    style: TextStyle(
                      color: effectiveColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}


*/


