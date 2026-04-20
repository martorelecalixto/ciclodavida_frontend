import 'package:flutter/material.dart';
import '../models/graupermanente_model.dart';
import '../services/auth_service.dart';
import '../services/graupermanente_service.dart';

class GrausPermanentesScreen extends StatefulWidget {
  const GrausPermanentesScreen({super.key});

  @override
  State<GrausPermanentesScreen> createState() => _GrausPermanentesScreenState();
}

class _GrausPermanentesScreenState extends State<GrausPermanentesScreen> {
 List<GrauPermanente> grauspermanentes = [];
  bool loading = true;
  String erro = '';
  DateTime? dataNascimento;
  int? dia;
  int? mes;

  final TextEditingController buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarGrausPermanentes();
  }

  Future<void> carregarGrausPermanentes({int? dia, int? mes}) async {
    setState(() {
      loading = true;
      erro = '';
    });

    try {

    final user = await AuthService.getUserData();
    dataNascimento = user['data_nascimento'] != null
          ? DateTime.parse(user['data_nascimento'])
          : DateTime(2000, 1, 1);

      mes = dataNascimento?.month;
      dia = dataNascimento?.day;

      final data = await GrauPermanenteService.getGrausPermanentes(dia: dia, mes: mes);
      setState(() {
        grauspermanentes = data;
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
                carregarGrausPermanentes(dia: int.tryParse(value), mes: int.tryParse(value));
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
      itemCount: grauspermanentes.length,
      itemBuilder: (context, index) {
        final p = grauspermanentes[index];

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
                p.grau != null && p.grau!.toString().isNotEmpty
                    ? p.grau!.toString()[0].toUpperCase()
                    : "?",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              p.grau.toString() ?? '',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "grau: ${p.dia?.toString() ?? ''}, ${p.dia?.toString() ?? ''}, ${p.mes?.toString() ?? ''}",
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
              label: Text("Grau",
                  style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text("Dia",
                  style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text("Mes",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
          rows: grauspermanentes.map((p) {
            return DataRow(cells: [
              DataCell(Text(
                p.grau?.toString() ?? '',
                style: const TextStyle(color: Colors.white),
              )),
              DataCell(Text(
                p.dia?.toString() ?? '',
                style: const TextStyle(color: Colors.white),
              )),
              DataCell(Text(
                p.mes?.toString() ?? '',
                style: const TextStyle(color: Colors.white),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
  
}


