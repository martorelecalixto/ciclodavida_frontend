import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistrade/screens/dashboard/home_screen.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  final Function(int) onMenuItemSelected;

  const ProfilePage({super.key, required this.onMenuItemSelected});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // ── State ─────────────────────────────────────────────────────
  DateTime? _dataNascimento;
  String _sexo = '';
  bool _loading = true;
  bool _salvando = false;
  String _erro = '';
  String _sucesso = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // ── Lifecycle ─────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _carregarUsuario();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── Data ──────────────────────────────────────────────────────
  Future<void> _carregarUsuario() async {
    setState(() => _loading = true);
    try {
      final user = await AuthService.getUserData();
      _nomeController.text = user['nome'] ?? '';
      _emailController.text = user['email'] ?? '';
      _enderecoController.text = user['endereco'] ?? '';
      _sexo = user['sexo'] ?? '';
      if (user['data_nascimento'] != null) {
        _dataNascimento = DateTime.tryParse(user['data_nascimento']);
      }
      _fadeController.forward();
    } catch (_) {
      setState(() => _erro = 'Erro ao carregar dados do usuário.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _salvar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _salvando = true;
      _erro = '';
      _sucesso = '';
    });

    try {
      // TODO: await AuthService.updateUser(...)
      await Future.delayed(const Duration(milliseconds: 800)); // simulação
      setState(() => _sucesso = 'Dados atualizados com sucesso!');
    } catch (_) {
      setState(() => _erro = 'Erro ao salvar dados. Tente novamente.');
    } finally {
      setState(() => _salvando = false);
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

  Future<void> _confirmarLogout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sair da conta',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Tem certeza que deseja sair?',
            style: TextStyle(color: _AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: _AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child:
                const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
       _logout(context);
      //await AuthService.logout();
      //Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false); 
    }
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────
  String get _inicialNome {
    final nome = _nomeController.text.trim();
    return nome.isNotEmpty ? nome[0].toUpperCase() : 'U';
  }

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
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: _AppColors.bg,
      appBar: _buildAppBar(isMobile),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _AppColors.accent))
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: _buildForm(),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  AppBar _buildAppBar(bool isMobile) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Color(0xFF131E30),
      elevation: 0,
      centerTitle: isMobile,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.person, color: Color(0xFF38BDF8), size: 18),
          SizedBox(width: 8),
          Text('Meu Perfil',
              style: TextStyle(color: Color(0xFFF1F5F9), fontSize: 17)),
        ],
      ),

      actions: isMobile
          ? null
          : [
              _NavButton('Home', 0, widget.onMenuItemSelected),
              _NavButton('Mapa', 1, widget.onMenuItemSelected),
              _NavButton('Perfil', 2, widget.onMenuItemSelected, active: true,),
              _NavButton('Credito', 3, widget.onMenuItemSelected),
              _NavButton('Sair', -1, widget.onMenuItemSelected),
              const SizedBox(width: 12),
            ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color:  Color(0xFF1E3A5F)),
        ),

    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAvatar(),
          const SizedBox(height: 8),
          const Text(
            'Meu Perfil',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gerencie suas informações pessoais',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 28),
          _buildFeedback(),
          _buildCard(
            title: 'Informações Pessoais',
            icon: Icons.person_outline,
            children: [
              _buildTextField(
                controller: _nomeController,
                label: 'Nome completo',
                icon: Icons.person_outline,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                enabled: false,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _emailController,
                label: 'E-mail',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                  if (!v.contains('@')) return 'E-mail inválido';
                  return null;
                },
                enabled: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: 'Dados Complementares',
            icon: Icons.assignment_ind_outlined,
            children: [
              _buildDateField(enabled: false,),
              const SizedBox(height: 14),
              _buildSexoField(enabled: false,),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _enderecoController,
                label: 'Endereço',
                icon: Icons.home_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSaveButton(),
          const SizedBox(height: 12),
          _buildLogoutButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Componentes ───────────────────────────────────────────────

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_AppColors.accent, Color(0xFF0EA5E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _AppColors.accent.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _inicialNome,
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _AppColors.cardBg,
              ),
              child: const Icon(Icons.edit, size: 14, color: _AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback() {
    if (_erro.isEmpty && _sucesso.isEmpty) return const SizedBox.shrink();

    final isErro = _erro.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isErro
            ? Colors.red.withOpacity(0.12)
            : Colors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isErro
              ? Colors.redAccent.withOpacity(0.5)
              : Colors.greenAccent.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isErro ? Icons.error_outline : Icons.check_circle_outline,
            color: isErro ? Colors.redAccent : Colors.greenAccent,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isErro ? _erro : _sucesso,
              style: TextStyle(
                color: isErro ? Colors.redAccent : Colors.greenAccent,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.cardBorder),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _AppColors.accent),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: _AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: _AppColors.cardBorder, height: 1),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

/*
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration(label, icon),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selecionarData,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: _inputDecoration('Data de Nascimento', Icons.cake_outlined),
        child: Text(
          _dataFormatada,
          style: TextStyle(
            color:
                _dataNascimento != null ? Colors.white : _AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSexoField() {
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true, // ✅ novo
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled, // ✅ aplicado
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration(label, icon),
    );
  }

  Widget _buildDateField({bool enabled = true}) {
    return InkWell(
      onTap: enabled ? _selecionarData : null, // ✅ bloqueia clique
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: _inputDecoration(
          'Data de Nascimento',
          Icons.cake_outlined,
        ).copyWith(
          enabled: enabled, // ✅ visual desabilitado
        ),
        child: Text(
          _dataFormatada,
          style: TextStyle(
            color: !enabled
                ? Colors.grey // 🔥 desabilitado
                : _dataNascimento != null
                    ? Colors.white
                    : _AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSexoField({bool enabled = true}) {
    return DropdownButtonFormField<String>(
      initialValue: _sexo.isEmpty ? null : _sexo,
      decoration: _inputDecoration(
        'Sexo biológico',
        Icons.people_outline,
      ).copyWith(
        enabled: enabled, // ✅ visual
      ),
      dropdownColor: _AppColors.cardBg,
      style: TextStyle(
        color: enabled ? Colors.white : Colors.grey, // 🔥 visual
        fontSize: 14,
      ),
      items: const [
        DropdownMenuItem(value: 'M', child: Text('Masculino')),
        DropdownMenuItem(value: 'F', child: Text('Feminino')),
      ],
      onChanged: enabled
          ? (value) => setState(() => _sexo = value ?? '')
          : null, // ✅ bloqueia interação
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _salvando ? null : _salvar,
        style: ElevatedButton.styleFrom(
          backgroundColor: _AppColors.accent,
          disabledBackgroundColor: _AppColors.accent.withOpacity(0.4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _salvando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_outlined, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Salvar Alterações',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      onPressed: _confirmarLogout,
      icon: const Icon(Icons.logout, size: 16, color: Colors.redAccent),
      label: const Text(
        'Sair da conta',
        style: TextStyle(color: Colors.redAccent, fontSize: 14),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.redAccent.withOpacity(0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _AppColors.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: _AppColors.textSecondary, size: 20),
      filled: true,
      fillColor: _AppColors.inputFill,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: _AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}

// ── Nav Button ────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final String label;
  final int index;
  final Function(int) onTap;
  final bool active;

  const _NavButton(this.label, this.index, this.onTap, {this.active=false});

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
              fontWeight: FontWeight.w500
              )),
              */
    );
  }
}

// ── Design Tokens ─────────────────────────────────────────────
abstract class _AppColors {
  static const bg = Color(0xFF0A0F1E);
  static const appBar = Color(0xFF0D1426);
  static const cardBg = Color(0xFF111827);
  static const cardBorder = Color(0xFF1E2A40);
  static const inputFill = Color(0xFF0D1426);
  //static const accent = Color(0xFF3B82F6);
  static const textSecondary = Color(0xFF6B7280);
  static const accent      = Color(0xFF38BDF8);
  static const accentDark  = Color(0xFF0EA5E9);
  static const textPrimary   = Color(0xFFF1F5F9);

}










/*
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  final Function(int) onMenuItemSelected;
  const ProfilePage({super.key, required this.onMenuItemSelected,});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final enderecoController = TextEditingController();
  int _pagina = 0;
  int selectedIndex = 0;
  bool processando = false;

  DateTime? dataNascimento;
  String sexo = '';

  bool loading = true;
  bool salvando = false;
  String erro = '';
  String sucesso = '';

  @override
  void initState() {
    super.initState();
    carregarUsuario();
  }

  // ==============================
  // CARREGAR DADOS
  // ==============================
  Future<void> carregarUsuario() async {
    setState(() {
      loading = true;
    });

    try {
      final user = await AuthService.getUserData();
//print('user data: $user');
      nomeController.text = user['nome'] ?? '';
      emailController.text = user['email'] ?? '';
      enderecoController.text = user['endereco'] ?? '';
      sexo = user['sexo'] ?? '';

       if (user['data_nascimento'] != null) {
        dataNascimento = DateTime.tryParse(user['data_nascimento']);
      }

    } catch (e) {
      erro = 'Erro ao carregar usuário';
    }

    setState(() {
      loading = false;
    });
  }

  // ==============================
  // SALVAR DADOS
  // ==============================
  Future<void> salvar() async {
    setState(() {
      salvando = true;
      erro = '';
      sucesso = '';
    });

    try {
      // 🔥 Aqui você pode futuramente chamar API
      // await AuthService.updateUser(...);

      // 👉 por enquanto salva local
      final prefs = await AuthService.getUserData();

      sucesso = "Dados atualizados com sucesso";

    } catch (e) {
      erro = "Erro ao salvar dados";
    }

    setState(() {
      salvando = false;
    });
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

  Widget _menuButton(String title, int index) {
    return TextButton(
      onPressed: () => _selectItem(index),// setState(() => _pagina = index),
      child: Text(title, style: const TextStyle(color: Colors.white)),
    );
 
  }

  void _selectItem(int index) {
    setState(() {
      processando = true;
      selectedIndex = index;
    });
    widget.onMenuItemSelected(index);

    setState(() => processando = false);

   // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(


/*
      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        title: const Text("Meu Perfil"),
        backgroundColor: Colors.blueGrey[900],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.all(16),

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

                          // ==============================
                          // AVATAR
                          // ==============================
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blue,
                            child: Text(
                              nomeController.text.isNotEmpty
                                  ? nomeController.text[0].toUpperCase()
                                  : "U",
                              style: const TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            "Meu Perfil",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ==============================
                          // ERRO / SUCESSO
                          // ==============================
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

                          if (sucesso.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                sucesso,
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),

                          // ==============================
                          // CAMPOS
                          // ==============================
                          TextField(
                            controller: nomeController,
                            decoration: _input("Nome", Icons.person),
                          ),

                          const SizedBox(height: 12),

                          TextField(
                            controller: emailController,
                            decoration: _input("Email", Icons.email),
                          ),

                          const SizedBox(height: 20),

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
                                      ? Colors.white
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

                          // ==============================
                          // BOTÃO SALVAR
                          // ==============================
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: salvando ? null : salvar,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: Colors.blue,
                              ),
                              child: salvando
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("Salvar Alterações"),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // ==============================
                          // LOGOUT
                          // ==============================
                          TextButton(
                            onPressed: () async {
                              await AuthService.logout();

                              if (mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/login',
                                  (route) => false,
                                );
                              }
                            },
                            child: const Text(
                              "Sair da conta",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    
 */

      appBar: AppBar(
        title: const Text("Meu Perfil"),
        centerTitle: true,
        actions: isMobile
            ? null
            : [
                _menuButton("Home", 0),
                _menuButton("Mapa", 1),
                _menuButton("Perfil", 2),
                const SizedBox(width: 10),
              ],
      ),


      backgroundColor: const Color(0xFF0F172A),

      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
             // padding: const EdgeInsets.all(16),

              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // 🔥 ESSENCIAL
                children: [

                  // ================= VOLTAR =================
                  /*
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: null,//onVoltar,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Voltar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  */

                  // ================= ÍCONE =================
                  // ==============================
                  // AVATAR
                  // ==============================
                  
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Text(
                      nomeController.text.isNotEmpty
                          ? nomeController.text[0].toUpperCase()
                          : "U",
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  
                  /*const Icon(
                    Icons.loop,
                    size: 80,
                    color: Colors.cyan,
                  ),*/
                  

                  const SizedBox(height: 16),

                  // ================= TÍTULO =================
                  const Text(
                    "Meu Perfil",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= IMAGEM =================
                  /*
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee",
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 24),
                  */

                  /*
                  const Text(
                    "Meu Perfil",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),
                  */

                  // ==============================
                  // ERRO / SUCESSO
                  // ==============================
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

                  if (sucesso.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sucesso,
                        style: const TextStyle(color: Colors.green),

                      ),


                    ),

                  // ==============================
                  // CAMPOS
                  // ==============================
                  TextField(
                    controller: nomeController,
                    decoration: _input("Nome", Icons.person),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: emailController,
                    decoration: _input("Email", Icons.email),
                  ),

                  const SizedBox(height: 20),

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
                              ? Colors.white
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

                  // ==============================
                  // BOTÃO SALVAR
                  // ==============================
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: salvando ? null : salvar,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue,
                      ),
                      child: salvando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Salvar Alterações"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ==============================
                  // LOGOUT
                  // ==============================
                  TextButton(
                    onPressed: () async {
                      await AuthService.logout();

                      if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    },
                    child: const Text(
                      "Sair da conta",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              
                ],

              ),

            ),

          ),

        ),

      ),


    );

  }

  // ==============================
  // INPUT PADRÃO
  // ==============================
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