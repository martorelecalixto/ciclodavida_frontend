import 'package:sistrade/screens/dashboard/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SideMenu extends StatefulWidget {
  final Function(int) onMenuItemSelected;

  const SideMenu({
    super.key,
    required this.onMenuItemSelected,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  List<String> permissoes = [];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('permissoes') ?? [];
    setState(() {
      permissoes = list;
    });
  }

  bool hasPerm(String nome) => permissoes.contains(nome);

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }


  void _selectItem(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onMenuItemSelected(index);
   // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A), // dark SaaS
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [

                _menuItem(
                  title: "Home",
                  icon: "assets/icons/menu_dashboard.svg",
                  index: 0,
                ),

                _menuItem(
                  title: "Mapa",
                  icon: "assets/icons/warehouse.svg",
                  index: 1,
                ),

                _menuItem(
                  title: "Perfil",
                  icon: "assets/icons/users.svg",
                  index: 2,
                ),

                _menuItem(
                  title: "Credito",
                  icon: "assets/icons/invoice.svg",
                  index: 3,
                ),

                const SizedBox(height: 12),

                _menuItem(
                  title: "Sair",
                  icon: "assets/icons/sign-out.svg",
                  index: -1,
                  onTap: () => _logout(context),
                  danger: true,
                ),

                const SizedBox(height: 40),

                _version("✔2604.08"),

              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Center(
            child: Image.asset(
              "assets/images/logo.png",
              height: 48,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "SISTRADE",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Sistema Corporativo",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }


  // ================= UI HELPERS =================

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 16, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 10,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _version(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 16, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 7,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _menuItem({
    required String title,
    required String icon,
    required int index,
    VoidCallback? onTap,
    bool danger = false,
  }) {
    final bool selected = false;//selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: selected
            ? Colors.blue.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        onTap:  onTap ??  () => _selectItem(index), //onTap ?? 
        leading: SvgPicture.asset(
          icon,
          height: 18,
          colorFilter: ColorFilter.mode(
            danger
                ? Colors.redAccent
                : selected
                    ? Colors.white
                    : Colors.white54,
            BlendMode.srcIn,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: danger
                ? Colors.redAccent
                : selected
                    ? Colors.white
                    : Colors.white70,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _submenu({
    required String title,
    required String icon,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        collapsedIconColor: Colors.white54,
        iconColor: Colors.white,
        leading: SvgPicture.asset(
          icon,
          height: 18,
          colorFilter: const ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        children: children,
      ),
    );
  }

  Widget _subItem(String title, int index) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 48, right: 16),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white60, fontSize: 12),
      ),
      onTap: () => _selectItem(index),
    );
  }
}

