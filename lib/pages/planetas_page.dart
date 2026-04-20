import 'package:flutter/material.dart';
import '../models/planeta_model.dart';
import '../services/planeta_service.dart';

class PlanetasScreen extends StatefulWidget {
  const PlanetasScreen({super.key});

  @override
  State<PlanetasScreen> createState() => _PlanetasScreenState();
}

class _PlanetasScreenState extends State<PlanetasScreen> {
 List<Planeta> planetas = [];
  bool loading = true;
  String erro = '';

  final TextEditingController buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarPlanetas();
  }

  Future<void> carregarPlanetas({String? nome}) async {
    setState(() {
      loading = true;
      erro = '';
    });

    try {
      final data = await PlanetaService.getPlanetas(nome: nome);
      setState(() {
        planetas = data;
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

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        title: const Text("Planetas"),
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
                carregarPlanetas(nome: value);
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
      itemCount: planetas.length,
      itemBuilder: (context, index) {
        final p = planetas[index];

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
              "Código: ${p.codciclo ?? ''}",
              style: const TextStyle(color: Colors.white54),
            ),
          ),
        );
      },
    );
  }

  // ================= TABELA DESKTOP =================
  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            Colors.blueGrey.shade800,
          ),
          columns: const [
            DataColumn(
              label: Text("Código",
                  style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text("Nome",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
          rows: planetas.map((p) {
            return DataRow(cells: [
              DataCell(Text(
                p.codciclo?.toString() ?? '',
                style: const TextStyle(color: Colors.white),
              )),
              DataCell(Text(
                p.nome ?? '',
                style: const TextStyle(color: Colors.white),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
  
}