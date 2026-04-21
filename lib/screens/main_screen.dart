import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistrade/pages/mapa_completo_page.dart';
import 'package:sistrade/pages/meumapa_page.dart';
import 'package:sistrade/pages/profile_page.dart';
import 'package:sistrade/pages/credito_page.dart';
import 'package:sistrade/screens/dashboard/home_screen.dart';
import 'dart:async';
import '../components/side_menu.dart';
import '../screens/dashboard/dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  String nome = 'Usuário';

  // ==========================================
  // 🔥 DADOS DO MAPA (DINÂMICO)
  // ==========================================
  String? dataNascimentoMapa;
  String? dataFinalMapa;
  String? sexoMapa;
  bool? mapaActiveMapa;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nome = prefs.getString('nome') ?? 'Usuário';
    });
  }

  void _onMenuItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // ==========================================
  // 🔥 ABRIR MAPA COMPLETO (PROFISSIONAL)
  // ==========================================
  void abrirMapaCompleto({
    required String dataNascimento,
    required String dataFinal,
    required String sexo,
    required bool mapaActive,
  }) {
    setState(() {
      dataNascimentoMapa = dataNascimento;
      dataFinalMapa = dataFinal;
      sexoMapa = sexo;
      mapaActiveMapa = mapaActive;
      selectedIndex = 4; // 🔥 abre tela do mapa completo
    });
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  // ==========================================
  // 🔥 TELAS
  // ==========================================
  Widget _getScreen(bool isMobile) {
    // DASHBOARD
    if (selectedIndex == 0) {
      return DashboardScreen(
        onMenuItemSelected: _onMenuItemSelected,
      );
    }

    // MEU MAPA
    if (selectedIndex == 1) {
      return MeuMapaPage(
        onMenuItemSelected: _onMenuItemSelected,
        // 🔥 IMPORTANTE: PASSANDO FUNÇÃO PARA ABRIR O MAPA
        abrirMapaCompleto: abrirMapaCompleto,
      );
    }

    // PERFIL
    if (selectedIndex == 2) {
      return ProfilePage(
        onMenuItemSelected: _onMenuItemSelected,
      );
    }

    // CRÉDITO
    if (selectedIndex == 3) {
      return CreditoPage(
        onMenuItemSelected: _onMenuItemSelected,
      );
    }

    // ==========================================
    // 🔥 MAPA COMPLETO (NOVA TELA)
    // ==========================================
    if (selectedIndex == 4) {
      return MapaCompletoPage(
        dataNascimento: dataNascimentoMapa ?? "2000-01-01",
        dataFinal: dataFinalMapa ?? "2080-12-31",
        sexo: sexoMapa ?? "M",
        mapaActive: mapaActiveMapa ?? false,
        onMenuItemSelected: _onMenuItemSelected,
      );
    }

    if (selectedIndex == -1) {
       _logout(context);
    }

    return const Center(child: Text("Tela não encontrada"));
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      drawer: isMobile
          ? null
          : SideMenu(
              onMenuItemSelected: (index) {
                _onMenuItemSelected(index);
                Navigator.pop(context);
              },
            ),

      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueGrey[900],
        title: Text(          
          "Olá, $nome 👋",
          style: const TextStyle(fontSize: 16),
        ),
        centerTitle: false,
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _getScreen(isMobile),
      ),

      // ==========================================
      // 🔥 BOTTOM NAV
      // ==========================================
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: selectedIndex > 3 ? 0 : selectedIndex,
              onTap: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              backgroundColor: const Color(0xFF1E293B),
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.white54,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: "Mapa",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Perfil",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.credit_card_rounded),
                  label: "Credito",
                ),
              ],
            )
          : null,
    );
  }

}















/*

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistrade/pages/mapa_completo_page.dart';
import 'package:sistrade/pages/meumapa_page.dart';
import 'package:sistrade/pages/profile_page.dart';
import 'package:sistrade/pages/credito_page.dart';
import 'dart:async';
import '../components/side_menu.dart';
import '../screens/dashboard/dashboard_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  String nome = 'Usuário';

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nome = prefs.getString('nome') ?? 'Usuário';
    });
  }

  void _onMenuItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // 🔥 TELAS PRINCIPAIS MOBILE
  List<Widget> mobileScreens() => [
        DashboardScreen(onMenuItemSelected: _onMenuItemSelected), // 0
        const Center(child: Text("Mapa")), // 1
        //MeuMapaPage(onMenuItemSelected: _onMenuItemSelected),//1

        ProfilePage(onMenuItemSelected: _onMenuItemSelected),//2
        const Center(child: Text("Perfil")), // 2

        CreditoPage(onMenuItemSelected: _onMenuItemSelected),//3
        const Center(child: Text("Credito")), // 3
      ];

  Widget _getScreen(bool isMobile) {
    if (isMobile) {
      //print('ENTROU isMobile' + selectedIndex.toString());
      //return mobileScreens()[selectedIndex];
      if (selectedIndex == 0) {
        return DashboardScreen(
          onMenuItemSelected: _onMenuItemSelected,
        );
      }
      if (selectedIndex == 1) {
        return MeuMapaPage(
          onMenuItemSelected: _onMenuItemSelected,
        );

      }
      if (selectedIndex == 2) {
        return ProfilePage(
          onMenuItemSelected: _onMenuItemSelected,
        );

      }
      if (selectedIndex == 3) {
        return CreditoPage(
          onMenuItemSelected: _onMenuItemSelected,
        );

      }

      return const Center(child: Text("Tela Desktop"));

    } else {
      // desktop continua com seu sistema antigo
      //print('ENTROU not isMobile' + selectedIndex.toString());
      if (selectedIndex == 0) {
        return DashboardScreen(
          onMenuItemSelected: _onMenuItemSelected,
        );
      }
      if (selectedIndex == 1) {
        return MeuMapaPage(
          onMenuItemSelected: _onMenuItemSelected,
        );
        //return MapaCompletoPage(
       //   onMenuItemSelected: _onMenuItemSelected,
       // );
      }
      if (selectedIndex == 2) {
        return ProfilePage(
          onMenuItemSelected: _onMenuItemSelected,
        );

      }
      if (selectedIndex == 3) {
        return CreditoPage(
          onMenuItemSelected: _onMenuItemSelected,
        );
      }

      return const Center(child: Text("Tela Desktop"));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      drawer: isMobile
          ? null
          : SideMenu(
              onMenuItemSelected: (index) {
                _onMenuItemSelected(index);
                Navigator.pop(context);
              },
            ),

      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: Text(
          "Olá, $nome 👋",
          style: const TextStyle(fontSize: 16),
        ),
        centerTitle: false,
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _getScreen(isMobile),
      ),

      // 🔥 BOTTOM NAV (SÓ MOBILE)
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              backgroundColor: const Color(0xFF1E293B),
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.white54,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: "Mapa",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Perfil",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.credit_card_rounded),
                  label: "Credito",
                ),
              ],
            )
          : null,
    );
  }
}


*/



















/*
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../components/side_menu.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../pages/login_page.dart';
import '../pages/reset_password_page.dart';
import '../pages/atividade_page.dart';
import '../pages/acomodacao_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  String nome = 'Usuário';
  String email = '';
  StreamSubscription? _linkSub;

  // ✅ CALLBACK CENTRAL DO MENU (SideMenu + Dashboard)
  void _onMenuItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // ⚠️ NÃO COLOQUE DashboardScreen na lista fixa!
  final List<Widget> screens = [
    const SizedBox(), // placeholder para index 0 (Dashboard)
    AtividadeScreen(), //1
    AcomodacaoScreen(), //2
    LoginScreen(), //3
    const SizedBox(), // placeholder para index 14 (Dashboard)
    ResetPasswordScreen(), //21
  ];

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
    _checkWebToken();
  }

  Future<void> _carregarDadosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nome = prefs.getString('nome') ?? 'Usuário';
      email = prefs.getString('email') ?? '';
    });
  }

  String? _extractTokenFromUri(Uri uri) {
    if (uri.queryParameters.containsKey('token')) {
      return uri.queryParameters['token'];
    }

    final frag = uri.fragment;
    if (frag.isEmpty) return null;

    try {
      if (frag.contains('?')) {
        final fragUri = Uri.parse('http://dummy${frag.startsWith('/') ? '' : '/'}$frag');
        if (fragUri.queryParameters.containsKey('token')) {
          return fragUri.queryParameters['token'];
        }
      } else {
        final fragUri = Uri.parse('http://dummy/?$frag');
        if (fragUri.queryParameters.containsKey('token')) {
          return fragUri.queryParameters['token'];
        }
      }
    } catch (_) {}
    return null;
  }

  void _checkWebToken() {
    final token = _extractTokenFromUri(Uri.base);
    if (token != null && token.isNotEmpty) {
      setState(() {
        selectedIndex = 21;
      });
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  // ✅ função que decide qual tela mostrar
  Widget _getScreen() {
    if (selectedIndex == 0 || selectedIndex == 14) {
      return DashboardScreen(
        onMenuItemSelected: _onMenuItemSelected,
      );
    }
    return screens[selectedIndex];
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF2563EB); // azul SaaS

    return Scaffold(
      drawer: SideMenu(
        onMenuItemSelected: (index) {
          _onMenuItemSelected(index);
          Navigator.pop(context);
        },
      ),
      backgroundColor:  const Color(0xFF0F172A), // const Color(0xFFF8FAFC), // fundo SaaS claro
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.blueGrey[500], //Colors.white
          foregroundColor: Colors.black87,
          centerTitle: false,
          titleSpacing: 0,
          title: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _onMenuItemSelected(0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.dashboard_rounded, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Sistrade',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: themeColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 4,
                    backgroundColor: themeColor,
                    //backgroundImage: AssetImage("assets/images/logo.png"),
                    child: Text(
                      '',//nome.isNotEmpty ? nome[0].toUpperCase() : '@',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: Colors.black12,
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _getScreen(),
      ),
    );
  }


}

*/