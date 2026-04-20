import 'package:flutter/material.dart';
import '../models/grauplaneta_model.dart';
import '../services/grauplaneta_service.dart';

class GrausPlanetasDataSource extends DataTableSource {
  final List<dynamic> dados;

  GrausPlanetasDataSource(this.dados);

  @override
  DataRow? getRow(int index) {
    if (index >= dados.length) return null;

    final p = dados[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(p.nome ?? '')),
        DataCell(Text(p.grau?.toString() ?? '')),
        DataCell(Text(
          p.data != null ? p.data!.toIso8601String() : '',
        )),
      ],
    );
  }

  @override
  int get rowCount => dados.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

/*
class PlanetasDataSource extends DataTableSource {
  final List<dynamic> dados;

  PlanetasDataSource(this.dados);

  @override
  DataRow? getRow(int index) {
    if (index >= dados.length) return null;

    final p = dados[index];

    return DataRow(cells: [
      DataCell(Text(p.nome ?? '')),
      DataCell(Text(p.grau?.toString() ?? '')),
      DataCell(Text(
        p.data != null ? p.data!.toIso8601String() : '',
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => dados.length;

  @override
  int get selectedRowCount => 0;
}
*/

class GrausPlanetasScreen extends StatefulWidget {
  const GrausPlanetasScreen({super.key});

  @override
  State<GrausPlanetasScreen> createState() => _GrausPlanetasScreenState();
}

class _GrausPlanetasScreenState extends State<GrausPlanetasScreen> {
 List<GrauPlaneta> grausplanetas = [];
  bool loading = true;
  String erro = '';
  bool? ultimoModoMobile;

  final ScrollController _scrollController = ScrollController();

  List grausExibidos = [];
  int pagina = 0;
  final int limite = 30;

  bool carregando = false;
  bool temMais = true;

  final TextEditingController buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarGrausPlanetas();
    _carregarMais();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !carregando &&
          temMais) {
        _carregarMais();
      }
    });
        
  }

  Future<void> carregarGrausPlanetas({String? codciclo}) async {
    setState(() {
      loading = true;
      erro = '';
    });

    try {
      final data = await GrauPlanetaService.getGrausPlanetas(codciclo: codciclo);
      setState(() {
        grausplanetas = data;
      });
    } catch (e) {
      setState(() {
        erro = 'Erro ao carregar dados';
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    // 🔥 DETECTA TROCA DE LAYOUT (AQUI ESTÁ A CORREÇÃO)
    if (ultimoModoMobile != isMobile) {
      ultimoModoMobile = isMobile;

      // Se mudou para mobile → garante que lista carregue
      if (isMobile && grausplanetas.isNotEmpty) {
        _resetarPaginacao();
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        title: const Text("Graus dos Planetas"),
        backgroundColor: Colors.blueGrey[900],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= BUSCA =================
            TextField(
              controller: buscaController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Buscar por nome...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.blueGrey.shade800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                carregarGrausPlanetas(codciclo: value);

                // 🔥 IMPORTANTE: reseta paginação ao buscar
                if (isMobile) {
                  _resetarPaginacao();
                }
              },
            ),

            const SizedBox(height: 16),

            // ================= ESTADOS =================
            if (loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (erro.isNotEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    erro,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else
              Expanded(
                child: isMobile
                    ? _buildListView()
                    : _buildTable(),
              ),
          ],
        ),
      ),
    );
  }

  // ================= LISTA MOBILE =================
  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: grausExibidos.length + (temMais ? 1 : 0),

      itemBuilder: (context, index) {
        // 🔥 LOADING NO FINAL
        if (index >= grausExibidos.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final p = grausExibidos[index];

        return Card(
          color: Colors.blueGrey.shade900,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                p.nome != null && p.nome!.isNotEmpty
                    ? p.nome![0].toUpperCase()
                    : "?",
                style: const TextStyle(color: Colors.white),
              ),
            ),

            title: Text(
              p.nome ?? '',
              style: const TextStyle(color: Colors.white),
            ),

            subtitle: Text(
              "Grau: ${p.grau ?? ''}",
              style: const TextStyle(color: Colors.white54),
            ),
          ),
        );
      },
    );
  }

  // ================= TABELA DESKTOP =================
  Widget _buildTable() {
    final source = GrausPlanetasDataSource(grausplanetas);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: PaginatedDataTable(
              header: const Text(
                "Lista de Graus dos Planetas",
                style: TextStyle(color: Colors.white),
              ),

              headingRowColor: WidgetStateProperty.all(
                Colors.blueGrey.shade800,
              ),

              columns: const [
                DataColumn(label: Text("Nome")),
                DataColumn(label: Text("Grau")),
                DataColumn(label: Text("Data")),
              ],

              source: source,

              rowsPerPage: 20,
              availableRowsPerPage: const [10, 20, 50, 100],

              columnSpacing: 20,
              horizontalMargin: 12,

              showFirstLastButtons: true, // 🔥 resolve navegação
            ),
          ),
        );
      },
    );
  }
 
  void _carregarMais() {
    setState(() => carregando = true);

    Future.delayed(const Duration(milliseconds: 300), () {
      final inicio = pagina * limite;
      final fim = inicio + limite;

      final novos = grausplanetas.skip(inicio).take(limite).toList();

      setState(() {
        pagina++;
        carregando = false;

        if (novos.isEmpty) {
          temMais = false;
        } else {
          grausExibidos.addAll(novos);
        }
      });
    });
  }

  void _resetarPaginacao() {
    pagina = 0;
    grausExibidos.clear();
    temMais = true;

    _carregarMais();
  }


}