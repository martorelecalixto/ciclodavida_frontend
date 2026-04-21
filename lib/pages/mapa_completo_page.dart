import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import '../config.dart'; 
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';

// ─────────────────────────────────────────────
// DESIGN TOKENS (alinhados ao DashboardScreen)
// ─────────────────────────────────────────────
const _bg          = Color(0xFF0B1120);
const _surface     = Color(0xFF131E30);
const _surface2    = Color(0xFF1A2740);
const _accent      = Color(0xFF38BDF8);
const _accentDark  = Color(0xFF0EA5E9);
const _textPrimary   = Color(0xFFF1F5F9);
const _textSecondary = Color(0xFF94A3B8);
const _border      = Color(0xFF1E3A5F);


class MapaCompletoPage extends StatefulWidget {
  final Function(int)? onMenuItemSelected;

  // 🔥 NOVOS PARÂMETROS
  final String dataNascimento;
  final String dataFinal;
  final String sexo;
  final bool mapaActive;

  const MapaCompletoPage({
    super.key,
    this.onMenuItemSelected,
    required this.dataNascimento,
    required this.dataFinal,
    required this.sexo,
    required this.mapaActive,
  });

  @override
  State<MapaCompletoPage> createState() => _MapaCompletoPageState();
}

class _MapaCompletoPageState extends State<MapaCompletoPage> {
  bool loading = true;
  static const String Url = '${AppConfig.baseUrl}/api/mapa-completo';  
  final GlobalKey graficoKey = GlobalKey();

  List<dynamic> anos = [];
  int? anoSelecionado;
  bool gerandoPdf = false;

  // ==========================================
  // ⚙️ CONTROLE DAS LEGENDAS (PODE ALTERAR AQUI)
  // ==========================================
  bool showLeft = true;
  bool showRight = false;
  bool showTop = false;
  bool showBottom = false;

  int windowStart = 0;
  int windowSize = 10; // será recalculado dinamicamente

  @override
  void initState() {
    super.initState();
    carregarMapa();
  }

  // ==========================================
  // 🔥 CHAMADA DO BACKEND
  // ==========================================
  Future<void> carregarMapa() async {
    try {
      //print('nascimento::' + widget.dataNascimento);
      //print('datafinal::' + widget.dataFinal);
      //print('sexo::' + widget.sexo);
      final response = await http.post(
        Uri.parse(Url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "dataNascimento": widget.dataNascimento,
          "sexo": widget.sexo,
          "dataFinal": widget.dataFinal,
        }),
      );

      final data = jsonDecode(response.body);

      setState(() {
        anos = data['anos'];
        anoSelecionado = anos.isNotEmpty ? anos.first['ano'] : null;
        loading = false;
      });

    } catch (e) {
      debugPrint("Erro ao carregar mapa: $e");
    }
  }

  /*Future<void> carregarMapa() async {
    try {
      final response = await http.post(
        Uri.parse(Url).replace(),
        //Uri.parse('http://SEU_IP:3000/mapa-completo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "dataNascimento": "1974-06-22",
          "sexo": "M",
          "dataFinal": "2084-12-31"
        }),
      );

      final data = jsonDecode(response.body);

      setState(() {
        anos = data['anos'];
        anoSelecionado = anos.first['ano'];
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }*/

  // ==========================================
  // 📊 GERAR PONTOS DO GRÁFICO
  // ==========================================
  List<FlSpot> gerarSpots() {
    return anos.map((a) {
      return FlSpot(
        (a['ano']).toDouble(),
        (a['score']).toDouble(),
      );
    }).toList();
  }

  // ==========================================
  // 🎯 PEGAR ANO SELECIONADO
  // ==========================================
  Map<String, dynamic>? getAnoSelecionado() {
    final result = anos.firstWhere(
      (a) => a['ano'] == anoSelecionado,
      orElse: () => null,
    );

    if (result == null) return null;

    return Map<String, dynamic>.from(result);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final anoData = getAnoSelecionado();
    //final largura = MediaQuery.of(context).size.width;
    final windowEnd = (windowStart + windowSize).clamp(0, anos.length);
    final anosVisiveis = anos.sublist(windowStart, windowEnd);

    // largura total disponível
    final largura = MediaQuery.of(context).size.width;

    // calcula largura de cada item dinamicamente
    final itemWidth = (largura - 32) / windowSize; // 32 = padding geral

    // cada quadrado ~70px
    windowSize = (largura / 70).floor();

    // limites mínimos e máximos
    if (windowSize < 5) windowSize = 5;
    if (windowSize > 20) windowSize = 20;

    return Scaffold(
        appBar: 
          AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: _surface,
            elevation: 0,
            centerTitle: isMobile,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children:  [
                Icon(Icons.map_outlined, color: _accent, size: 18),
                SizedBox(width: 8),
                Text('Mapa Astrológico',
                    style: TextStyle(color: _textPrimary, fontSize: 17)),
                SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed:  gerandoPdf ? null : gerarPDF,
                ),
              ],
            ),
            actions: isMobile
                ? null
                : [
                    /*IconButton(
                      icon: const Icon(Icons.picture_as_pdf),
                      onPressed:  gerandoPdf ? null : gerarPDF,
                    ),*/
                    const SizedBox(width: 8),
                    _navBtn('Home',   0),
                    _navBtn('Mapa',   1),
                    _navBtn('Perfil', 2),
                    _navBtn('Credito',  3),
                    _navBtn('Sair',  -1),
                    const SizedBox(width: 8),
                  ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: _border),
            ),
          ),

      body: 
      Stack(
        children: [     
            
            loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
  
                      SizedBox(
                        height: 260,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Stack(
                            children: [

                              // ==========================================
                              // 📊 GRÁFICO
                              // ==========================================
                              RepaintBoundary(
                                key: graficoKey,
                                child: LineChart(
                                  LineChartData(
                                    minY: -100,
                                    maxY: 100,

                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: gerarSpots(),
                                        isCurved: true,
                                        barWidth: 3,
                                        dotData: const FlDotData(show: false),
                                      )
                                    ],

                                    // 👉 INTERAÇÃO
                                    lineTouchData: LineTouchData(

                                      touchCallback: (event, response) {
                                        if (response != null &&
                                            response.lineBarSpots != null &&
                                            response.lineBarSpots!.isNotEmpty) {
                                          final spot = response.lineBarSpots!.first;

                                          final ano = spot.x.toInt();

                                          setState(() {
                                            anoSelecionado = ano;
                                          });

                                          atualizarJanela(ano); // 🔥 AQUI A MÁGICA
                                        }
                                      },                                      

                                    ),

                                    // ==========================================
                                    // 🧠 LEGENDAS CUSTOMIZADAS
                                    // ==========================================
                                    titlesData: FlTitlesData(

                                      // LEFT (COM EMOJIS)
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: showLeft,
                                          interval: 100,
                                          getTitlesWidget: (value, meta) {
                                            if (value == 100) {
                                              return const Text("🚀", style: TextStyle(fontSize: 16));
                                            }
                                            if (value == 0) {
                                              return const Text("⚖️", style: TextStyle(fontSize: 16));
                                            }
                                            if (value == -100) {
                                              return const Text("💀", style: TextStyle(fontSize: 16));//⚠️
                                            }
                                            return const SizedBox();
                                          },
                                        ),
                                      ),

                                      rightTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: showRight),
                                      ),

                                      topTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: showTop),
                                      ),

                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: showBottom,
                                          interval: 10,
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              value.toInt().toString(),
                                              style: const TextStyle(fontSize: 10),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // ==========================================
                              // ⚖️ EMOJI CENTRAL FIXO (ESTABILIDADE)
                              // ==========================================
                              const Positioned.fill(
                                child: Center(
                                  child: Text(
                                    "⚖️",
                                    style: TextStyle(fontSize: 22, color: Colors.white24),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ==========================================
                      // 📄 DETALHES DO ANO
                      // ==========================================
                      if (anoData != null && anoData.isNotEmpty)
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                // 🔥 TÍTULO
                                Text(
                                  'Ano ${anoData['ano']} (Idade ${anoData['idade']})',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Intensidade do ciclo'),

                                    const SizedBox(height: 6),

                                    LinearProgressIndicator(
                                      value: ((anoData['score'] + 100) / 200),
                                      minHeight: 8,
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor: AlwaysStoppedAnimation(
                                        _getCorTendencia(anoData['tendencia']),
                                      ),
                                    ),
                                  ],
                                ),                          

                                const SizedBox(height: 10),

                                // 🎯 TENDÊNCIA
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getCorTendencia(anoData['tendencia']).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    anoData['tendencia'],
                                    style: TextStyle(
                                      color: _getCorTendencia(anoData['tendencia']),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),                          

                                const SizedBox(height: 10),

                                // 📖 TEXTO
                                SizedBox(
                                  height: 70,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final largura = constraints.maxWidth;

                                      // 🔥 largura mínima por item (responsivo)
                                      final itemWidth = largura < 500 ? 40.0 : 50.0;

                                      // 🔥 quantos cabem na tela
                                      final itensVisiveis = (largura / itemWidth).floor().clamp(3, 20);

                                      final indexAtual = anos.indexWhere((a) => a['ano'] == anoSelecionado);

                                      // 🔥 centraliza o ano selecionado
                                      int start = indexAtual - (itensVisiveis ~/ 2);
                                      if (start < 0) start = 0;

                                      int end = start + itensVisiveis;
                                      if (end > anos.length) {
                                        end = anos.length;
                                        start = (end - itensVisiveis).clamp(0, anos.length);
                                      }

                                      final slice = anos.sublist(start, end);

                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: slice.map((a) {
                                          final selecionado = a['ano'] == anoSelecionado;

                                          return AnimatedContainer(
                                            duration: const Duration(milliseconds: 250),
                                            margin: const EdgeInsets.symmetric(horizontal: 4),
                                            width: itemWidth - 8,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: selecionado ? _accent : _surface2,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: _border),
                                            ),
                                            child: Center(
                                              child: Text(
                                                a['ano'].toString(),
                                                style: TextStyle(
                                                  fontSize: largura < 500 ? 10 : 12,
                                                  color: selecionado ? Colors.white : _textSecondary,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ),

                                Text(
                                  anoData['texto'] ?? '',
                                  style: const TextStyle(fontSize: 15),
                                ),

                                const SizedBox(height: 20),

                                // 💡 FRASES HUMANAS
                                const Text(
                                  'Recomendações:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold, 
                                  ),
                                ),

                                const SizedBox(height: 10),

                                ...(anoData['frases'] as List<dynamic>)
                                    .map((f) => Padding(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          child: 
                                              Container(
                                                margin: const EdgeInsets.only(bottom: 8),
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.lightbulb_outline, size: 18),
                                                    const SizedBox(width: 8),
                                                    //Expanded(child: Text(f)),
                                                    Expanded(
                                                      child: Text(
                                                        f,
                                                        style: const TextStyle(
                                                          color: Colors.black87, // 🔥 FORÇA COR
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),

                                                  ],
                                                ),
                                              ),

                                        ))
                                    ,
                              ],
                            ),
                          ),
                        ),
                    
                    ],
                  ),
        ],),
    
    );
  }

  void _selectItem(int index) {
    widget.onMenuItemSelected!(index);
  }

  Widget _navBtn(String label, int index) {
    return TextButton(
      onPressed: () => _selectItem(index),
      style: TextButton.styleFrom(
        foregroundColor: label == 'Mapa' ? _accent : _textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),      
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }

  void atualizarJanela(int anoSelecionado) {
    if (anos.isEmpty) return;

    final index = anos.indexWhere((a) => a['ano'] == anoSelecionado);
    if (index == -1) return;

    // Centraliza o ano selecionado
    int novoInicio = index - (windowSize ~/ 2);

    if (novoInicio < 0) novoInicio = 0;
    if (novoInicio > anos.length - windowSize) {
      novoInicio = anos.length - windowSize;
    }

    setState(() {
      windowStart = novoInicio;
    });
  }

  // ==========================================
  // 🎨 COR DO APP (FLUTTER)
  // ==========================================
  Color _getCorTendencia(String t) {
    switch (t) {
      case 'Crescimento':
        return Colors.green;
      case 'Desafio':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<void> gerarPDF() async {
    setState(() => gerandoPdf = true);
    _mostrarLoading(context);
    // 🔥 FORÇA O FLUTTER A DESENHAR A TELA ANTES
    //await Future.delayed(const Duration(milliseconds: 100));
    try{
      final pdf = pw.Document();
      final font = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
      final fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

      final graficoBytes = await capturarGrafico();

      pdf.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.all(24),
          build: (context) => [

            // ==========================================
            // 🟣 CAPA
            // ==========================================
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'MAPA ASTROLÓGICO',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Análise completa dos seus ciclos de vida',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // ==========================================
            // 📊 GRÁFICO
            // ==========================================
            if (graficoBytes != null)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Visão Geral dos Ciclos',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Image(pw.MemoryImage(graficoBytes)),
                  pw.SizedBox(height: 20),
                ],
              ),

            // ==========================================
            // 📄 ANOS
            // ==========================================
            ...anos.map((a) {
              final cor = getCorPdf(a['tendencia']);

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 14),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: cor, width: 1.5),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    // 🔥 HEADER
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Ano ${a['ano']}',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: cor,
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          child: pw.Text(
                            a['tendencia'],
                            style: const pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 10,
                            ),
                          ),
                        )
                      ],
                    ),

                    pw.SizedBox(height: 6),

                    pw.Text('Idade: ${a['idade']}'),

                    pw.SizedBox(height: 6),

                    // TEXTO PRINCIPAL
                    pw.Text(
                      a['texto'] ?? '',
                      style: const pw.TextStyle(fontSize: 12),
                    ),

                    pw.SizedBox(height: 8),

                    // FRASES (SEM CARACTERE PROBLEMÁTICO)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: (a['frases'] as List<dynamic>).map((f) {
                        return pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 4),
                          child: pw.Text('• $f', style: pw.TextStyle(font: font),),//pw.Text('- $f'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );

      //final bytes = await pdf.save();

      // ==========================================
      // 🌐 ABRIR EM NOVA ABA (SEM FECHAR APP)
      // ==========================================
        await Printing.sharePdf(
          bytes: await pdf.save(),
          filename: 'mapa_ciclo.pdf',
        ); 

        //final blob = html.Blob([bytes], 'application/pdf');
        //final url = html.Url.createObjectUrlFromBlob(blob);
        //html.window.open(url, '_blank');

    } catch (e) {
      debugPrint('Erro ao gerar PDF: $e');
    } finally {
      setState(() => gerandoPdf = false);
      _fecharLoading(context);
    }

  }

  Future<Uint8List?> capturarGrafico() async {
    try {
      final boundary =
          graficoKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData!.buffer.asUint8List();
    } catch (e) {
      debugPrint("Erro ao capturar gráfico: $e");
      return null;
    }
  }

  PdfColor getCorPdf(String t) {
    if (t == 'Crescimento') return PdfColors.green;
    if (t == 'Desafio') return PdfColors.red;
    return PdfColors.orange;
  }

  void _mostrarLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: BoxDecoration(
            color: Color(0xFF131E30),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFF1E3A5F)),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF38BDF8), strokeWidth: 2),
              SizedBox(height: 16),
              Text('Gerando PDF...',
                  style: TextStyle(color:  Color(0xFFF1F5F9), fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  void _fecharLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }


}
