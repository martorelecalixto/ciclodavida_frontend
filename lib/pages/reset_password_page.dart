import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../constants.dart';
import 'login_page.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _senhaVisivel = false;
  bool _confirmVisivel = false;
  bool _loading = false;

  String? _token;
  String _erro = '';

  @override
  void initState() {
    super.initState();
    // Captura o token da URL - compatível com WASM
    final params = Uri.base.queryParameters;
    _token = params['token'];
  }

  bool validarSenha(
    String senha, {
    bool verificarMinimo8 = true,
    bool verificarEspecial = true,
    bool verificarNumero = true,
    bool verificarMaiuscula = true,
  }) {
    if (verificarMinimo8 && senha.length < 8) return false;
    if (verificarEspecial && !RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=/\\]').hasMatch(senha)) {
      return false;
    }
    if (verificarNumero && !RegExp(r'\d').hasMatch(senha)) return false;
    if (verificarMaiuscula && !RegExp(r'[A-Z]').hasMatch(senha)) return false;

    return true;
  }

  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();

    if (_token == null || _token!.isEmpty) {
      setState(() => _erro = 'Token ausente ou inválido. Abra o link do e-mail novamente.');
      return;
    }

    final senha = _senhaController.text.trim();
    final confirm = _confirmController.text.trim();

    if (senha.isEmpty || confirm.isEmpty) {
      setState(() => _erro = 'Informe e confirme a nova senha.');
      return;
    }

    if (senha != confirm) {
      setState(() => _erro = 'As senhas não conferem.');
      return;
    }

    if (!validarSenha(senha)) {
      setState(() => _erro = 'A senha deve conter no mínimo 8 caracteres, \n1 caracter especial, 1 número e 1 letra maiúscula.');
      return;
    }

    setState(() {
      _loading = true;
      _erro = '';
    });

    final resp = await AuthService.resetPassword(_token!, senha);

    setState(() => _loading = false);

    if (resp['success'] == true) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp['message'] ?? 'Senha redefinida com sucesso.')),
      );

      // Redireciona e limpa o histórico — sem dart:html
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      setState(() => _erro = resp['message'] ?? 'Falha ao redefinir a senha.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'A senha deve conter no mínimo 8 caracteres, 1 caracter \nespecial, 1 número e 1 letra maiúscula.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.redAccent,
                      ),
                      maxLines: null,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Redefinir senha',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _senhaController,
                      obscureText: !_senhaVisivel,
                      decoration: InputDecoration(
                        labelText: 'Nova senha',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_senhaVisivel ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: _confirmController,
                      obscureText: !_confirmVisivel,
                      decoration: InputDecoration(
                        labelText: 'Confirmar nova senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_confirmVisivel ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _confirmVisivel = !_confirmVisivel),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (_erro.isNotEmpty)
                      Text(
                        _erro,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        onPressed: _loading ? null : _enviar,
                        child: _loading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Salvar nova senha',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    bool semBorda = false,
    double borderWidth = 1.0,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: null,
      style: const TextStyle(
        fontSize: 12,
        fontFamily: 'Poppins',
        color: Colors.redAccent,
      ),
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontFamily: 'Poppins',
          color: Colors.redAccent,
        ),
        border: semBorda
            ? InputBorder.none
            : OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: borderWidth),
              ),
        enabledBorder: semBorda
            ? InputBorder.none
            : OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: borderWidth),
              ),
        focusedBorder: semBorda
            ? InputBorder.none
            : OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: borderWidth),
              ),
      ),
    );
  }
}






/*
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../constants.dart';
import 'login_page.dart';
import 'dart:html' as html; // apenas web
import 'package:shared_preferences/shared_preferences.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _senhaVisivel = false;
  bool _confirmVisivel = false;
  bool _loading = false;
  String? _token;
  String _erro = '';

  @override
  void initState() {
    super.initState();
    // Captura o token da URL (Flutter Web)
    final params = Uri.base.queryParameters;
    _token = params['token'];
  }

  bool validarSenha(
    String senha, {
    bool verificarMinimo8 = true,
    bool verificarEspecial = true,
    bool verificarNumero = true,
    bool verificarMaiuscula = true,
  }) {
    // 1 - Mínimo 8 caracteres
    if (verificarMinimo8 && senha.length < 8) return false;

    // 2 - Pelo menos 1 caracter especial
    if (verificarEspecial && !RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=/\\]').hasMatch(senha)) {
      return false;
    }

    // 3 - Pelo menos 1 número
    if (verificarNumero && !RegExp(r'\d').hasMatch(senha)) return false;

    // 4 - Pelo menos 1 maiúscula
    if (verificarMaiuscula && !RegExp(r'[A-Z]').hasMatch(senha)) return false;

    return true;
  }

  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();

    if (_token == null || _token!.isEmpty) {
      setState(() => _erro = 'Token ausente ou inválido. Abra o link do e-mail novamente.');
      return;
    }

    final senha = _senhaController.text.trim();
    final confirm = _confirmController.text.trim();

    if (senha.isEmpty || confirm.isEmpty) {
      setState(() => _erro = 'Informe e confirme a nova senha.');
      return;
    }
    //if (senha.length < 6) {
    //  setState(() => _erro = 'A senha deve ter pelo menos 6 caracteres.');
    //  return;
   // }
    if (senha != confirm) {
      setState(() => _erro = 'As senhas não conferem.');
      return;
    }
    if (!validarSenha(senha)) {
      setState(() => _erro = 'A senha deve conter no mínimo 8(oito) caracteres, \n1(um) caracter especial, 1(um) número e 1(uma) letra maiuscula.');
      return;
    }

    setState(() {
      _loading = true;
      _erro = '';
    });

    final resp = await AuthService.resetPassword(_token!, senha);

    setState(() => _loading = false);

    if (resp['success'] == true) {
      if (!mounted) return;

      // Limpa a URL para evitar que o reset reapareça
      html.window.history.replaceState(null, 'Login', '/');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp['message'] ?? 'Senha redefinida com sucesso.')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      setState(() => _erro = resp['message'] ?? 'Falha ao redefinir a senha.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'A senha deve conter no mínimo 8(oito) caracteres, 1(um) \ncaracter especial, 1(um) número e 1(uma) letra maiuscula.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.redAccent,
                      ),
                      maxLines: null,
                    ),
                    const Text(
                      'Redefinir senha',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _senhaController,
                      obscureText: !_senhaVisivel,
                      decoration: InputDecoration(
                        labelText: 'Nova senha',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_senhaVisivel ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _confirmController,
                      obscureText: !_confirmVisivel,
                      decoration: InputDecoration(
                        labelText: 'Confirmar nova senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_confirmVisivel ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _confirmVisivel = !_confirmVisivel),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_erro.isNotEmpty)
                      Text(_erro, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        onPressed: _loading ? null : _enviar,
                        child: _loading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Salvar nova senha',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    bool semBorda = false, //  controla se some a borda
    double borderWidth = 1.0,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: null,
      style: const TextStyle(
        fontSize: 12,
        fontFamily: 'Poppins',
        color: Colors.redAccent,
      ),
      readOnly: readOnly,
      //inputFormatters: [CentavosInputFormatter()],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontFamily: 'Poppins',
          color: Colors.redAccent,
        ),
        counterText: '',
        border: semBorda
            ? InputBorder.none
            : OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: borderWidth),
              ),
        enabledBorder: semBorda
            ? InputBorder.none
            : OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: borderWidth),
              ),
        focusedBorder: semBorda
            ? InputBorder.none
            : OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: borderWidth),
              ),
      ),
    );
  }

}
*/