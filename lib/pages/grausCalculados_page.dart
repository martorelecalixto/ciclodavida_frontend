import 'package:flutter/material.dart';
import '../models/graucalculado_model.dart';
import '../services/graucalculado_service.dart';

class GrausCalculadosScreen extends StatefulWidget {
  const GrausCalculadosScreen({super.key});

  @override
  State<GrausCalculadosScreen> createState() => _GrausCalculadosScreenState();
}

class _GrausCalculadosScreenState extends State<GrausCalculadosScreen> {
 List<GrauCalculado> grauscalculados = [];
  bool loading = true;
  String erro = '';

  final TextEditingController buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarGrausCalculados();
  }

  Future<void> carregarGrausCalculados({String? grau_a}) async {
    setState(() {
      loading = true;
      erro = '';
    });

    try {
      final data = await GrauCalculadoService.getGrausCalculados(grau_a: grau_a);
      setState(() {
        grauscalculados = data;
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
        title: const Text("Graus Calculados"),
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
                carregarGrausCalculados(grau_a: value);
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
      itemCount: grauscalculados.length,
      itemBuilder: (context, index) {
        final p = grauscalculados[index];

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
                p.grau_a != null && p.grau_a!.toString().isNotEmpty
                    ? p.grau_a!.toString()[0].toUpperCase()
                    : "?",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              p.grau_a.toString() ?? '',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "grau: ${p.grau_b?.toString() ?? ''}, ${p.grau_c?.toString() ?? ''}, ${p.grau_x1?.toString() ?? ''}, ${p.grau_d?.toString() ?? ''}, ${p.grau_e?.toString() ?? ''}, ${p.grau_f?.toString() ?? ''}, ${p.grau_x2?.toString() ?? ''}, ${p.grau_g?.toString() ?? ''}, ${p.grau_h?.toString() ?? ''}",
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
              label: Text("Grau_A",
                  style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text("Grau_B",
                  style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text("Grau_C",
                  style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text("Grau_X1",
                  style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text("Grau_D",
                  style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text("Grau_E",
                  style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text("Grau_F",
                  style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text("Grau_X2",
                  style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text("Grau_G",
                  style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text("Grau_H",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
          rows: grauscalculados.map((p) {
            return DataRow(cells: [
              DataCell(Text(
                p.grau_a?.toString() ?? '',
                style: const TextStyle(color: Colors.white),
              )),
              DataCell(Text(
                p.grau_b?.toString() ?? '',
                style: const TextStyle(color: Colors.white),
              )),
              DataCell(Text(
                p.grau_c?.toString() ?? '',
                style: const TextStyle(color: Colors.white),
              )),
              DataCell(Text(
                p.grau_x1?.toString() ?? '',
                style: const TextStyle(color: Colors.white),
              )),
              DataCell(Text(
                p.grau_d?.toString() ?? '',
                style: const TextStyle(color: Colors.white),
              )),
              DataCell(Text(
                p.grau_e?.toString() ?? '',
                style: const TextStyle(color: Colors.white),
              )),
              DataCell(Text(
                p.grau_f?.toString() ?? '',
                style: const TextStyle(color: Colors.white),
              )),
              DataCell(Text(
                p.grau_x2?.toString() ?? '',
                style: const TextStyle(color: Colors.white),
              )),
              DataCell(Text(
                p.grau_g?.toString() ?? '',
                style: const TextStyle(color: Colors.white),
              )),
              DataCell(Text(
                p.grau_h?.toString() ?? '',
                style: const TextStyle(color: Colors.white),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
  
}