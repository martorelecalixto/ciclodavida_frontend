//import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sistrade/models/usuario_model.dart';
import 'package:sistrade/pages/mapa_completo_page.dart';

import '../models/graucalculado_model.dart';
import '../models/grauplaneta_model.dart';
import '../models/meuciclo_model.dart';
import '../models/meugrafico_model.dart';
import '../services/auth_service.dart';
import '../services/graupermanente_service.dart';
import '../services/graucalculado_service.dart';
import '../services/grauplaneta_service.dart';

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

// ─────────────────────────────────────────────
// CONFIG DE CADA PLANETA
// ─────────────────────────────────────────────
class _PlanetaCfg {
  final String letra;
  final String codciclo;
  final int meses;
  const _PlanetaCfg(this.letra, this.codciclo, this.meses);
}

const _planetas = [
  _PlanetaCfg('S', '5', 11),
  _PlanetaCfg('V', '3', 6),
  _PlanetaCfg('M', '2', 11),
  _PlanetaCfg('J', '1', 12),
  _PlanetaCfg('U', '6', 120),
  _PlanetaCfg('N', '7', 120),
  _PlanetaCfg('P', '4', 240),
];

// ─────────────────────────────────────────────
// TELA GRÁFICO
// ─────────────────────────────────────────────

// ───────────────────────────────────────────────────────────────
//  BLOCO 1 — Tipos auxiliares
//  ONDE: fora da classe, no topo do arquivo (junto aos outros
//        modelos/enums que você já tiver)
// ───────────────────────────────────────────────────────────────
enum Polaridade { positivo, negativo }

class ClickSnapshot {
  final String grafico;
  final Polaridade polaridade;
  final double x;
  final String datastring;
  final Map<String, Polaridade?> estadoTodos;

  const ClickSnapshot({
    required this.grafico,
    required this.polaridade,
    required this.x,
    required this.datastring,
    required this.estadoTodos,
  });
}

// ───────────────────────────────────────────────────────────────
//  BLOCO 2 — Flag do Card 2 e textos
//  ONDE: fora da classe, no topo do arquivo (junto aos consts)
// ───────────────────────────────────────────────────────────────

/// true  → usa textos pré-escritos
/// false → usa lógica local dinâmica
const bool usarCard2PreEscrito = true;

/// Card 1 — texto específico por gráfico e polaridade
/// ✏️ PREENCHA com seus textos
const Map<String, Map<Polaridade, String>> textoCard1 = {
  'S': {
    Polaridade.positivo: 
      'Seu mapa é a representação visual da sua jornada completa. ' 'Ele reúne todos os dados coletados e os organiza de forma ' +
      'geográfica e temporal, oferecendo uma visão ampla do seu percurso.' +
      'Por meio do mapa você identifica padrões pessoais que seriam ' +
      'invisíveis em tabelas ou listas. A distribuição espacial dos ' +
      'eventos revela conexões entre momentos aparentemente isolados.' +
      'Cada ponto no mapa é único e reflete um aspecto da sua realidade. ' +
      'A ferramenta foi projetada para ser sua principal referência na ' +
      'tomada de decisões importantes.' +
      'Com o mapa ativo, a análise se torna profunda e intuitiva. ' +
      'Você passa a entender não apenas o que aconteceu, mas como ' +
      'cada evento se conecta ao próximo dentro da sua trajetória.',
    
    //'Gráfico S — pico positivo: preencha aqui.',
    Polaridade.negativo: 
      'A vida é construída sobre ciclos que se repetem constantemente ' 'ao longo do tempo. Esses ciclos não são aleatórios — eles seguem ' +
      'padrões organizados que podem ser observados com atenção e método.' +
      'Quando você começa a perceber esses padrões, passa a entender ' +
      'melhor os momentos de crescimento, pausa e transformação. ' +
      'Nada acontece de forma isolada; tudo faz parte de um fluxo ' +
      'contínuo que se repete com pequenas variações a cada volta.' +
      'Os ciclos também explicam por que certas situações voltam a ' +
      'acontecer na sua vida. Isso não significa erro — significa ' +
      'oportunidade de aprendizado e evolução pessoal profunda.' +
      'Ao compreender os ciclos, você ganha clareza sobre decisões ' +
      'importantes e evita agir por impulso. Passa a respeitar o ' +
      'momento certo de avançar, pausar ou recuar.' +
      'Existe um tempo para plantar, um tempo para crescer e um ' +
      'tempo para colher. Ignorar essa lógica gera frustração; ' +
      'respeitá-la gera resultados mais consistentes e duradouros.' +
      'No final, entender os ciclos significa dominar a si mesmo, ' +
      'trazendo mais segurança, confiança e direção para cada ' +
      'aspecto da sua trajetória pessoal e profissional.',

    //'Gráfico S — pico negativo: preencha aqui.',
  },
  'V': {
    Polaridade.positivo: 'Gráfico V — pico positivo: preencha aqui.',
    Polaridade.negativo: 'Gráfico V — pico negativo: preencha aqui.',
  },
  'M': {
    Polaridade.positivo: 'Gráfico M — pico positivo: preencha aqui.',
    Polaridade.negativo: 'Gráfico M — pico negativo: preencha aqui.',
  },
  'J': {
    Polaridade.positivo: 'Gráfico J — pico positivo: preencha aqui.',
    Polaridade.negativo: 'Gráfico J — pico negativo: preencha aqui.',
  },
  'U': {
    Polaridade.positivo: 'Gráfico U — pico positivo: preencha aqui.',
    Polaridade.negativo: 'Gráfico U — pico negativo: preencha aqui.',
  },
  'N': {
    Polaridade.positivo: 'Gráfico N — pico positivo: preencha aqui.',
    Polaridade.negativo: 'Gráfico N — pico negativo: preencha aqui.',
  },
  'P': {
    Polaridade.positivo: 'Gráfico P — pico positivo: preencha aqui.',
    Polaridade.negativo: 'Gráfico P — pico negativo: preencha aqui.',
  },
};

/// Card 2 — Modalidade A: textos pré-escritos por cenário combinado
///
/// A chave é gerada automaticamente no formato:
///   '<graficoClicado><pol>_S<pol>_V<pol>_M<pol>_J<pol>_U<pol>_N<pol>_P<pol>'
/// onde pol = '+' (positivo) | '-' (negativo) | '0' (neutro)
///
/// Exemplo de chave: 'S+_S+_V-_M0_J+_U-_N0_P+'
/// Você não precisa cobrir todas — '_fallback_' cobre os não cadastrados.
/// ✏️ PREENCHA com seus textos síntese
const Map<String, String> textoCard2PreEscrito = {
  // 'S+_S+_V-_M0_J+_U-_N0_P+': 'Síntese para este cenário...',
  '_fallback_': 'Cenário combinado sem descrição cadastrada.',
};

/// Card 2 — Modalidade B: lógica local dinâmica
/// ✏️ IMPLEMENTE suas regras aqui
String gerarTextoCard2Dinamico(ClickSnapshot snap) {
  final estados = snap.estadoTodos;
  final pos = estados.values.where((p) => p == Polaridade.positivo).length;
  final neg = estados.values.where((p) => p == Polaridade.negativo).length;

  if (pos >= 5) return '🌟 Maioria positiva ($pos gráficos em alta). Preencha aqui.';
  if (neg >= 5) return '⚠️ Maioria negativa ($neg gráficos em baixa). Preencha aqui.';
  if (pos > neg) return '📈 Levemente positivo ($pos×$neg). Preencha aqui.';
  if (neg > pos) return '📉 Levemente negativo ($neg×$pos). Preencha aqui.';
  return '⚖️ Cenário equilibrado. Preencha aqui.';
}


class TelaGrafico extends StatefulWidget {
  final List<MeuGrafico> lista;
  final usuario;

  const TelaGrafico({super.key, required this.lista, required this.usuario});

  @override
  State<TelaGrafico> createState() => _TelaGraficoState();
}

class _TelaGraficoState extends State<TelaGrafico> {
  Set<String> planetasSelecionados = {'S', 'V', 'M', 'J', 'U', 'N', 'P'};
  final List<String> todosPlanetas  = ['S', 'V', 'M', 'J', 'U', 'N', 'P'];
  final GlobalKey _chartKey = GlobalKey();

  // cores fixas por planeta — legível em fundo escuro
  static const Map<String, Color> _cores = {
    'S': Color(0xFF38BDF8), // sky
    'V': Color(0xFFF472B6), // pink
    'M': Color(0xFFFF6B6B), // red
    'J': Color(0xFFFBBF24), // amber
    'U': Color(0xFF34D399), // green
    'N': Color(0xFFA78BFA), // purple
    'P': Color(0xFFFB923C), // orange
  };



  // ───────────────────────────────────────────────────────────────
  //  BLOCO 3 — Novas variáveis de estado
  //  ONDE: dentro de _TelaGraficoState, junto às variáveis
  //        que já existem (planetasSelecionados, _chartKey, etc.)
  // ───────────────────────────────────────────────────────────────

  // ── estado dos cards ──
  ClickSnapshot? _snapshot;
  // spots originais por gráfico — necessários para interpolação do Card 2
  final Map<String, List<FlSpot>> _spotsPorGrafico = {};

//===================================================================================


// ───────────────────────────────────────────────────────────────
//  BLOCO 4 — Helpers internos
//  ONDE: dentro de _TelaGraficoState, antes de _gerarGraficoMeuCiclo
// ───────────────────────────────────────────────────────────────

  Polaridade? _toPolaridade(double y) {
    if (y > 0) return Polaridade.positivo;
    if (y < 0) return Polaridade.negativo;
    return null; // y == 0 → ignora clique
  }

  double? _interpolarY(double x, List<FlSpot> spots) {
    if (spots.isEmpty) return null;
    if (x <= spots.first.x) return spots.first.y;
    if (x >= spots.last.x) return spots.last.y;
    for (int i = 0; i < spots.length - 1; i++) {
      if (x >= spots[i].x && x <= spots[i + 1].x) {
        final t = (x - spots[i].x) / (spots[i + 1].x - spots[i].x);
        return spots[i].y + t * (spots[i + 1].y - spots[i].y);
      }
    }
    return null;
  }

  Map<String, Polaridade?> _estadoTodosEmX(double x) {
    final result = <String, Polaridade?>{};
    _spotsPorGrafico.forEach((nome, spots) {
      final y = _interpolarY(x, spots);
      result[nome] = y != null ? _toPolaridade(y) : null;
    });
    return result;
  }

  String _montarChaveCard2(ClickSnapshot snap) {
    const graficos = ['S', 'V', 'M', 'J', 'U', 'N', 'P'];
    String pol(Polaridade? p) =>
        p == Polaridade.positivo ? '+' : p == Polaridade.negativo ? '-' : '0';
    final clicado = '${snap.grafico}${pol(snap.polaridade)}';
    final outros = graficos.map((g) => '$g${pol(snap.estadoTodos[g])}').join('_');
    return '${clicado}_$outros';
  }

  Widget _buildCard1(ClickSnapshot snap) {
    final texto = textoCard1[snap.grafico]?[snap.polaridade]
        ?? '⚠️ Sem texto para "${snap.grafico}" '
           '${snap.polaridade == Polaridade.positivo ? "positivo" : "negativo"}.';
    final corBorda = snap.polaridade == Polaridade.positivo
        ? Colors.green.shade700
        : Colors.red.shade700;
    final corGrafico = _cores[snap.grafico] ?? _accent;

    return Card(
      color: _surface2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: corBorda, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _chip('Gráfico ${snap.grafico}', corGrafico),
              const SizedBox(width: 8),
              _chip(
                snap.polaridade == Polaridade.positivo
                    ? '🚀 Pico positivo'
                    : '💀 Pico negativo',
                corBorda,
              ),
              const Spacer(),
              if (snap.datastring.isNotEmpty)
                Text(snap.datastring,
                    style: const TextStyle(color: _textSecondary, fontSize: 11)),
            ]),
            const SizedBox(height: 10),
            Text(texto,
                style: const TextStyle(color: _textPrimary, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard2(ClickSnapshot snap) {
    final String texto;
    if (usarCard2PreEscrito) {
      final chave = _montarChaveCard2(snap);
      texto = textoCard2PreEscrito[chave]
          ?? textoCard2PreEscrito['_fallback_']!;
    } else {
      texto = gerarTextoCard2Dinamico(snap);
    }

    final legenda = snap.estadoTodos.entries.map((e) {
      final icon = e.value == Polaridade.positivo ? '🟢'
          : e.value == Polaridade.negativo ? '🔴' : '⚪';
      return '$icon ${e.key}';
    }).join('  ');

    return Card(
      color: _surface2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF4A4A7C), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text('🔮  Cenário combinado',
                  style: TextStyle(
                      color: _textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
              const Spacer(),
              _chip(
                usarCard2PreEscrito ? 'Pré-escrito' : 'Dinâmico',
                usarCard2PreEscrito ? Colors.blueAccent : Colors.deepPurpleAccent,
              ),
            ]),
            const SizedBox(height: 6),
            Text(legenda,
                style: const TextStyle(color: _textSecondary, fontSize: 11)),
            const SizedBox(height: 10),
            Text(texto,
                style: const TextStyle(color: _textPrimary, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color cor) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cor.withOpacity(0.7)),
        ),
        child: Text(label,
            style: TextStyle(
                color: cor, fontWeight: FontWeight.bold, fontSize: 12)),
      );

  //===================================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _surface,
        elevation: 0,
        title: Text(
          'Ciclo de ${widget.usuario}',
          style: const TextStyle(color: _textPrimary, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: _textSecondary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Column(
          children: [
            _buildFiltrosPlanetas(),
            const SizedBox(height: 10),
            Expanded(
              child: _buildGrafico(),
            ),

            //  BLOCO 5 — Alteração no build()
            //  ONDE: no seu build() existente, substitua apenas o trecho
            //        do Expanded que chama _buildGrafico()
            // ── Cards aparecem só após clique num pico ──
            if (_snapshot != null) ...[
              const SizedBox(height: 10),
              _buildCard1(_snapshot!),
              const SizedBox(height: 8),
              _buildCard2(_snapshot!),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() => _snapshot = null),
                  icon: const Icon(Icons.close, size: 14, color: _textSecondary),
                  label: const Text('Fechar',
                      style: TextStyle(color: _textSecondary, fontSize: 12)),
                ),
              ),
            ],

            const SizedBox(height: 10),
            _buildBotaoExportar(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Filtros ──
  Widget _buildFiltrosPlanetas() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: todosPlanetas.map((p) {
          final ativo = planetasSelecionados.contains(p);
          final cor = _cores[p] ?? _accent;
          return GestureDetector(
            onTap: () => setState(() {
              ativo
                  ? planetasSelecionados.remove(p)
                  : planetasSelecionados.add(p);
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ativo ? cor.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ativo ? cor.withOpacity(0.6) : _border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: ativo ? cor : _textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    p,
                    style: TextStyle(
                      color: ativo ? cor : _textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Gráfico ──
  Widget _buildGrafico() {
    return _gerarGraficoMeuCiclo(
      context,
      widget.lista,
      chartKey: _chartKey,
      altura: double.infinity,
      planetasVisiveis: planetasSelecionados,
      espessuraLinha: 2.5,
      mostrarEixoDireito: false,
      mostrarEixoSuperior: false,
      tamanhoFonte: 12,
      corFonte: _textSecondary,
    );
  }

  // ── Botão exportar ──
  Widget _buildBotaoExportar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _gerarPdfComGrafico,
        icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
        label: const Text('Exportar PDF'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF166534),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // GERADOR DE GRÁFICO
  // ─────────────────────────────────────────────
  Widget _gerarGraficoMeuCiclo(
    BuildContext context,
    List<MeuGrafico> lista, {
    GlobalKey? chartKey,
    double altura = 300,
    double tamanhoFonte = 14,
    double tamanhoFonteEmoji = 25,
    double tamanhoFonteBottom = 11,
    Color corFonte = Colors.white,
    double espessuraLinha = 2,
    bool mostrarEixoEsquerdo = true,
    bool mostrarEixoDireito = false,
    bool mostrarEixoInferior = true,
    bool mostrarEixoSuperior = false,
    Set<String>? planetasVisiveis,
  }) {
    List<FlSpot> downsample(List<FlSpot> pontos, int max) {
      if (pontos.length <= max) return pontos;
      final bucket = (pontos.length / max).ceil();
      final result = <FlSpot>[];
      for (int i = 0; i < pontos.length; i += bucket) {
        final end = (i + bucket).clamp(0, pontos.length);
        final slice = pontos.sublist(i, end);
        FlSpot mn = slice.first, mx = slice.first;
        for (var p in slice) {
          if (p.y < mn.y) mn = p;
          if (p.y > mx.y) mx = p;
        }
        result..add(mn)..add(mx);
      }
      return result..sort((a, b) => a.x.compareTo(b.x));
    }

    final Map<String, List<MeuGrafico>> grupos = {};
    for (var item in lista) {
      final nome = item.nome ?? 'Sem nome';
      grupos.putIfAbsent(nome, () => []).add(item);
    }

    final linhas = <LineChartBarData>[];
    final Map<double, List<MeuGrafico>> mapaX = {};
    double? minX, maxX;

    grupos.forEach((nome, dados) {
      if (planetasVisiveis != null && !planetasVisiveis.contains(nome)) return;
      dados.sort((a, b) => (a.eixo_x ?? 0).compareTo(b.eixo_x ?? 0));

      var spots = <FlSpot>[];
      for (var e in dados) {
        final x = (e.eixo_x ?? 0).toDouble();
        final y = (e.eixo_y ?? 0).toDouble();
        spots.add(FlSpot(x, y));
        mapaX.putIfAbsent(x, () => []).add(e);
        if (minX == null || x < minX!) minX = x;
        if (maxX == null || x > maxX!) maxX = x;
      }

      // ───────────────────────────────────────────────────────────────
      //  BLOCO 6 — Alterações dentro de _gerarGraficoMeuCiclo
      //  São 2 adições cirúrgicas, nada mais.
      // ───────────────────────────────────────────────────────────────
      //  ADIÇÃO 6-A
      // ── NOVO: guarda spots originais para interpolação ──
      _spotsPorGrafico[nome] = List.from(spots);
      // ────────────────────────────────────────────────────

      spots = downsample(spots, 400);
      linhas.add(LineChartBarData(
        spots: spots,
        isCurved: false,
        color: _cores[nome] ?? _accent,
        barWidth: espessuraLinha,
        dotData: FlDotData(show: false),
      ));
    });

    final range = (minX != null && maxX != null) ? (maxX! - minX!) : 0.0;
    final margem = range * 0.02;
    final largura = MediaQuery.of(context).size.width;

    return RepaintBoundary(
      key: chartKey,
      child: SizedBox(
        height: altura,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            minScale: 1,
            maxScale: 5,
            constrained: true,
            child: SizedBox(
              width: largura * 2,
              child: LineChart(LineChartData(
                backgroundColor: _surface,
                lineBarsData: linhas,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: _border, strokeWidth: 0.5),
                  getDrawingVerticalLine: (_) =>
                      FlLine(color: _border, strokeWidth: 0.5),
                ),
                minY: -2.5,
                maxY: 2.5,
                minX: (minX ?? 0) - margem,
                maxX: (maxX ?? 0) + margem,
                extraLinesData: ExtraLinesData(verticalLines: []),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: mostrarEixoEsquerdo,
                      interval: 1,
                      reservedSize: 50,
                      getTitlesWidget: (value, _) {
                        const emojis = {
                           2: '🚀', 1: '🙂', 0: '⚖️', -1: '🙁', -2: '💀',
                        };
                        final e = emojis[value.toInt()];
                        if (e == null) return const SizedBox();
                        return Center(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(e,
                                style: TextStyle(fontSize: tamanhoFonteEmoji)),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: mostrarEixoDireito)),
                  topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: mostrarEixoSuperior)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: mostrarEixoInferior,
                      reservedSize: 50,
                      interval: 31536000000,
                      getTitlesWidget: (value, _) {
                        final d = DateTime.fromMillisecondsSinceEpoch(
                            value.toInt());
                        return Transform.rotate(
                          angle: -0.5,
                          child: Text(
                            '${d.month}/${d.year}      ',
                            style: TextStyle(
                              color: corFonte,
                              fontSize: tamanhoFonteBottom,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => _surface2,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (spots) => spots.map((spot) {
                      final itens = mapaX[spot.x];
                      if (itens == null || itens.isEmpty) return null;
                      final texto = itens
                          .map((i) => '${i.nome}: ${i.datastring}')
                          .join('\n');
                      return LineTooltipItem(
                        texto,
                        const TextStyle(color: _textPrimary, fontSize: 12),
                      );
                    }).toList(),
                  ),


                  // ───────────────────────────────────────────────────────────────
                  //  BLOCO 6 — Alterações dentro de _gerarGraficoMeuCiclo
                  //  São 2 adições cirúrgicas, nada mais.
                  // ───────────────────────────────────────────────────────────────
                  //  ADIÇÃO 6-B
                  // ── NOVO: detecta clique em pico ─────────
                  touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                    if (event is! FlTapUpEvent) return;
                    if (response?.lineBarSpots == null ||
                        response!.lineBarSpots!.isEmpty) {
                      return;
                    }

                    final spot = response.lineBarSpots!.first;
                    final pol = _toPolaridade(spot.y);
                    if (pol == null) return; // y == 0 → ignora

                    // descobre o nome do gráfico pelo índice da barra
                    final nomesOrdenados = grupos.keys
                        .where((n) => planetasVisiveis == null ||
                            planetasVisiveis.contains(n))
                        .toList();
                    final idx = spot.barIndex;
                    if (idx < 0 || idx >= nomesOrdenados.length) return;
                    final nomeGrafico = nomesOrdenados[idx];

                    final x = spot.x;
                    final itensX = mapaX[x];
                    final ds = itensX
                            ?.firstWhere(
                              (i) => i.nome == nomeGrafico,
                              orElse: () => itensX.first,
                            )
                            .datastring ?? '';

                    setState(() {
                      _snapshot = ClickSnapshot(
                        grafico: nomeGrafico,
                        polaridade: pol,
                        x: x,
                        datastring: ds,
                        estadoTodos: _estadoTodosEmX(x),
                      );
                    });
                  },
                  // ─────────────────────────────────────────



                ),
              )),
            ),
          ),
        ),
      ),
    );
  }

  // ── Captura e PDF ──
  Future<Uint8List?> _capturarGrafico() async {
    final ctx = _chartKey.currentContext;
    if (ctx == null) return null;
    final boundary = ctx.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return null;
    await Future.delayed(const Duration(milliseconds: 300));
    final image = await boundary.toImage(pixelRatio: 3.0);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }


/*
  Future<void> _gerarPdfComGrafico() async {
    await SchedulerBinding.instance.endOfFrame;
    _mostrarLoading(context);
    try {
      final bytes = await _capturarGrafico();
      if (bytes == null) return;
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(build: (_) => pw.Image(pw.MemoryImage(bytes))),
      );
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Grafico_Ciclo.pdf',
      );
    } finally {
      _fecharLoading(context);
    }
  }
*/


Future<void> _gerarPdfComGrafico() async {
    await SchedulerBinding.instance.endOfFrame;
    _mostrarLoading(context);
    try {
      // ── Captura do gráfico (idêntico ao original) ──────────
      final bytes = await _capturarGrafico();
      if (bytes == null) return;

      final pdf = pw.Document();

      // ── Monta os textos dos cards (só se houver snapshot) ──
      final snap = _snapshot; // pode ser null se nenhum pico foi clicado

      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [

                // ── Gráfico (igual ao original) ─────────────
                pw.Image(pw.MemoryImage(bytes)),

                // ── Cards (só aparecem se um pico foi clicado)
                if (snap != null) ...[
                  pw.SizedBox(height: 16),

                  // ── Card 1 ─────────────────────────────────
                  _pdfCard(
                    titulo: 'Gráfico ${snap.grafico} — '
                        '${snap.polaridade == Polaridade.positivo ? "Pico positivo 🚀" : "Pico negativo 💀"}',
                    subtitulo: snap.datastring,
                    corpo: textoCard1[snap.grafico]?[snap.polaridade]
                        ?? 'Sem texto cadastrado.',
                    corBorda: snap.polaridade == Polaridade.positivo
                        ? PdfColors.green700
                        : PdfColors.red700,
                  ),

                  pw.SizedBox(height: 10),

                  // ── Card 2 ─────────────────────────────────
                  _pdfCard(
                    titulo: '🔮 Cenário combinado'
                        ' (${usarCard2PreEscrito ? "pré-escrito" : "dinâmico"})',
                    subtitulo: _legendaCard2(snap),
                    corpo: usarCard2PreEscrito
                        ? (textoCard2PreEscrito[_montarChaveCard2(snap)]
                            ?? textoCard2PreEscrito['_fallback_']!)
                        : gerarTextoCard2Dinamico(snap),
                    corBorda: PdfColors.indigo300,
                  ),
                ],
              ],
            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Grafico_Ciclo.pdf',
      );
    } finally {
      _fecharLoading(context);
    }
  }

// ───────────────────────────────────────────────────────────────
//  HELPERS PDF — adicione junto ao método acima (mesma classe)
// ───────────────────────────────────────────────────────────────

  /// Monta um card visual no PDF
  pw.Widget _pdfCard({
    required String titulo,
    required String subtitulo,
    required String corpo,
    required PdfColor corBorda,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: corBorda, width: 1.5),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.grey900,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // cabeçalho
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                titulo,
                style: pw.TextStyle(
                  color: corBorda,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (subtitulo.isNotEmpty)
                pw.Text(
                  subtitulo,
                  style: const pw.TextStyle(
                    color: PdfColors.grey400,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Divider(color: corBorda, thickness: 0.5),
          pw.SizedBox(height: 6),
          // corpo
          pw.Text(
            corpo,
            style: const pw.TextStyle(
              color: PdfColors.white,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// Gera a legenda de polaridades para o subtítulo do Card 2
  String _legendaCard2(ClickSnapshot snap) {
    return snap.estadoTodos.entries.map((e) {
      final icon = e.value == Polaridade.positivo ? '(+)'
          : e.value == Polaridade.negativo ? '(-)'
          : '(0)';
      return '${e.key}$icon';
    }).join('  ');
  }


  void _mostrarLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: _accent, strokeWidth: 2),
              SizedBox(height: 16),
              Text('Gerando PDF...',
                  style: TextStyle(color: _textPrimary, fontSize: 14)),
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

//
//=========================================================================
//

// ─────────────────────────────────────────────
// MEU MAPA PAGE
// ─────────────────────────────────────────────
class MeuMapaPage extends StatefulWidget {
  //final Function(int) onMenuItemSelected;
  //const MeuMapaPage({super.key, required this.onMenuItemSelected});
  final Function(int) onMenuItemSelected;

  final Function({
    required String dataNascimento,
    required String dataFinal,
    required String sexo,
    required bool mapaActive,
  }) abrirMapaCompleto;

  const MeuMapaPage({
    super.key,
    required this.onMenuItemSelected,
    required this.abrirMapaCompleto,
  });

  @override
  State<MeuMapaPage> createState() => _MeuMapaPageState();
}

class _MeuMapaPageState extends State<MeuMapaPage> {
  String nome = '';
  String sexo = '';
  DateTime? dataNascimento;
  DateTime? dataInicial;
  String? dataFinal;
  bool? mapaActive;
  int? codusuario = 0;
  int? anosComprados = 0;

  int? anoInicial;
  int? anoFinal;
  bool loading = true;
  bool processando = false;

  // Graus dos planetas — indexados pela letra
  final Map<String, List<GrauPlaneta>> _grausPorPlaneta = {
    'S': [], 'V': [], 'M': [], 'J': [], 'U': [], 'N': [], 'P': [],
  };

  // Ciclos por planeta — indexados pela letra
  final Map<String, List<MeuCiclo>> _cicloPorPlaneta = {
    'S': [], 'V': [], 'M': [], 'J': [], 'U': [], 'N': [], 'P': [],
  };

  List<MeuGrafico> meuGrafico = [];
  List<int> anos = [];

  int _norm(int g) => g <= 0 ? 360 + g : (g > 360 ? g - 360 : g);

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  void _selectItem(int index) {
    widget.onMenuItemSelected(index);
  }

  // ─────────────────────────────────────────────
  // CARREGAR USUÁRIO
  // ─────────────────────────────────────────────
  Future<void> _carregarUsuario() async {
    //debugPrint('ENTROU _carregarUsuario');

    final user = await AuthService.getUserData();

    final now = DateTime.now();

    // -------------------------
    // 🔢 Inteiros seguros
    // -------------------------
    codusuario = user['codusuario'] is int
        ? user['codusuario']
        : int.tryParse('${user['codusuario']}') ?? 0;


    /*esse trecho foi comentado porque pega os anos comprados 
    do token e não está atualizando o token quando faz uma compra
    
    anosComprados = user['anos'] is int
        ? user['anos']
        : int.tryParse('${user['anos']}') ?? 0;

    dataInicial = _parseDate(user['datainicial']);

    */

    final Usuario usuario = await AuthService.getUsuarioById(codusuario.toString());
    anosComprados = usuario.anos;
    dataInicial = usuario.datainicial;

    //debugPrint('ANOS COMPRADOS' + anosComprados.toString());
    // -------------------------
    // 🧍 Dados básicos
    // -------------------------
    nome = user['nome'] ?? '';

    final s = user['sexo'] ?? '';
    sexo = s == 'M'
        ? 'Masculino'
        : s == 'F'
            ? 'Feminino'
            : s;

    // -------------------------
    // 📅 Datas seguras
    // -------------------------
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    dataNascimento = parseDate(user['data_nascimento']);

    // -------------------------
    // 🎯 REGRA 1 - anoInicial
    // -------------------------
    if (dataNascimento == null ||
        dataNascimento!.year > now.year) {
      anoInicial = now.year;
    } else {
      anoInicial = dataNascimento!.year;
    }

    // -------------------------
    // 🎯 REGRA 2 - anoFinal
    // -------------------------
    if (dataInicial == null || anosComprados == 0) {
      anoFinal = now.year;
    } else {
      anoFinal = dataInicial!.year + anosComprados!;
    }

    // -------------------------
    // 🛡️ Garantia extra (evita lista invertida)
    // -------------------------
    if (anoFinal! < anoInicial!) {
      anoFinal = anoInicial;
    }

    dataFinal = '${anoFinal.toString()}-12-31';

    // -------------------------
    // 📊 Lista de anos
    // -------------------------
    final diff = anoFinal! - anoInicial! + 1;

    anos = List.generate(diff, (i) => anoInicial! + i);

    // -------------------------
    //debugPrint('codusuario: $codusuario');
    //debugPrint('anosComprados: $anosComprados');
    //debugPrint('anoInicial: $anoInicial');
    //debugPrint('anoFinal: $anoFinal');

    setState(() => loading = false);
  }


  // ─────────────────────────────────────────────
  // CONSULTAR
  // ─────────────────────────────────────────────
  Future<void> _consultar() async {
    if (anoInicial! > anoFinal!) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Atenção',
              style: TextStyle(color: _textPrimary)),
          content: const Text(
              'Ano inicial não pode ser maior que ano final.',
              style: TextStyle(color: _textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK',
                  style: TextStyle(color: _accent)),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => processando = true);

    try {
      final grauBase = await _buscarGrauPermanente(
        dia: dataNascimento?.day,
        mes: dataNascimento?.month,
      );
      final grauCalc = await _buscarGrauCalculado(grau_a: grauBase.toString());

      // Busca graus de todos os planetas em paralelo
      await Future.wait(_planetas.map((cfg) async {
        _grausPorPlaneta[cfg.letra] =
            await GrauPlanetaService.getGrausPlanetas(codciclo: cfg.codciclo);
      }));

      final dn = dataNascimento!;

      // Monta ciclo de cada planeta
      for (final cfg in _planetas) {
        final isPluton = cfg.letra == 'P';
        final dataIni = isPluton
            ? DateTime(dn.year - 5, dn.month, dn.day)
            : DateTime(dn.year, dn.month - 6, dn.day);
        final dataFim = isPluton
            ? DateTime(anoFinal! + 5, dn.month, dn.day)
            : DateTime(anoFinal!, dn.month + 6, dn.day);

        await _montarCicloPlaneta(
          grauCalc,
          cfg: cfg,
          dataInicial: dataIni,
          dataFinal: dataFim,
        );
        await refinarMeuCiclo(
            grauCalc, _cicloPorPlaneta[cfg.letra]!, cfg.letra);
      }

      await _montarGrafico(grauCalc);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              TelaGrafico(lista: meuGrafico, usuario: nome),
        ),
      );
    } finally {
      if (mounted) setState(() => processando = false);
    }
  }

  // ─────────────────────────────────────────────
  // MÉTODO GENÉRICO — substitui os 7 montarCicloXxx
  // ─────────────────────────────────────────────
  Future<void> _montarCicloPlaneta(
    GrauCalculado g, {
    required _PlanetaCfg cfg,
    DateTime? dataInicial,
    DateTime? dataFinal,
  }) async {
    final lista = _grausPorPlaneta[cfg.letra]!;
    final destino = <MeuCiclo>[];
    final grausAlvo = _montarListaGraus(g);

    lista.sort((a, b) => a.data!.compareTo(b.data!));

    final filtrada = lista.where((e) {
      if (e.data == null) return false;
      if (dataInicial != null && e.data!.isBefore(dataInicial)) return false;
      if (dataFinal   != null && e.data!.isAfter(dataFinal))    return false;
      return true;
    }).toList();

    if (filtrada.length < 2) return;

    for (int i = 0; i < filtrada.length - 1; i++) {
      final a  = filtrada[i];
      final b  = filtrada[i + 1];
      final g1 = a.grau!;
      final g2 = b.grau!;

      if (grausAlvo.contains(g1)) {
        destino.add(MeuCiclo(data: a.data!, grau: g1, nome: cfg.letra));
      }
      for (var alvo in grausAlvo) {
        if (_cruza(g1, g2, alvo)) {
          destino.add(MeuCiclo(
            data: _interpolar(a.data!, b.data!, g1, g2, alvo),
            grau: alvo,
            nome: cfg.letra,
          ));
        }
      }
    }

    _cicloPorPlaneta[cfg.letra] =
        _filtrarUltimosPorPeriodo(destino, meses: cfg.meses);
  }

  // ─────────────────────────────────────────────
  // MONTAR GRÁFICO
  // ─────────────────────────────────────────────
  Future<void> _montarGrafico(GrauCalculado g) async {
    meuGrafico.clear();
    for (final cfg in _planetas) {
      final lista = _cicloPorPlaneta[cfg.letra]!;
      if (lista.isEmpty) continue;
      final linha = await _montarLinhaGrafico(lista, g);
      meuGrafico.addAll(linha);
    }
    //debugPrint("Dados para o gráfico: ${meuGrafico.map((e) => "(${e.letra}, ${e.eixo_x}, ${e.eixo_y}, ${e.datastring}, ${e.nome})").toList()}");
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: _bg,
      appBar: 
      AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _surface,
        elevation: 0,
        centerTitle: isMobile,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.map_outlined, color: _accent, size: 18),
            SizedBox(width: 8),
            Text('Meu Mapa',
                style: TextStyle(color: _textPrimary, fontSize: 17)),
          ],
        ),
        actions: isMobile
            ? null
            : [
                _navBtn('Home',   0),
                _navBtn('Mapa',   1, active: true),
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
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: _accent, strokeWidth: 2))
          : SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeroMapa(),
                        const SizedBox(height: 32),
                        _buildSecaoUsuario(),
                        const SizedBox(height: 24),
                        _buildSecaoPeriodo(),
                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: () {
                            widget.abrirMapaCompleto(
                              dataNascimento: dataNascimento.toString(),
                              dataFinal: dataFinal.toString(),
                              sexo: sexo,
                              mapaActive: true, 
                            );
                          },
                          child: const Text("Gerar Mapa Completo"),
                        ),                                             //_buildBotaoConsultar(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _navBtn(String label, int index, {active=false}) {
    return TextButton(
      onPressed: () => _selectItem(index),
      //style: TextButton.styleFrom(foregroundColor: _textSecondary),
      style: TextButton.styleFrom(
        foregroundColor: active ? _accent : _textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),      
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }

  // ── Hero ──
  Widget _buildHeroMapa() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: _accentDark.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: _accentDark.withOpacity(0.4), width: 1.5),
            ),
            child: const Icon(Icons.loop, color: _accent, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Gerar meu Mapa',
            style: TextStyle(
              color: _textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Selecione o período e consulte os ciclos planetários',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Seção dados do usuário ──
  Widget _buildSecaoUsuario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Minhas informações'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              _infoRow(Icons.person_outline, 'Nome', nome),
              const SizedBox(height: 12),
              _infoRow(Icons.wc_outlined, 'Sexo', sexo),
              const SizedBox(height: 12),
              _infoRow(
                Icons.cake_outlined,
                'Nascimento',
                dataNascimento != null
                    ? '${dataNascimento!.day.toString().padLeft(2, '0')}/'
                      '${dataNascimento!.month.toString().padLeft(2, '0')}/'
                      '${dataNascimento!.year}'
                    : '—',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _accent, size: 18),
        const SizedBox(width: 10),
        Text('$label: ',
            style: const TextStyle(
                color: _textSecondary, fontSize: 14)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                color: _textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ── Seção período ──
  Widget _buildSecaoPeriodo() {
    final dropStyle = DropdownButtonFormField<int>(
      // só para referenciar o estilo — não usado diretamente
      items: const [],
      onChanged: null,
      decoration: const InputDecoration(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Período'),
        const SizedBox(height: 12),
        _dropdown(
          label: 'Ano inicial',
          value: anoInicial,
          icon: Icons.calendar_today_outlined,
          onChanged: (v) => setState(() => anoInicial = v),
        ),
        const SizedBox(height: 12),
        _dropdown(
          label: 'Ano final',
          value: anoFinal,
          icon: Icons.event_outlined,
          onChanged: (v) {
            setState(() {
              anoFinal = v;
              dataFinal = '${v.toString()}-12-31'; // 🔥 padrão backend
            });
          },          
          //onChanged: (v) => setState(() => anoFinal = v),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required int? value,
    required IconData icon,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      dropdownColor: _surface2,
      style: const TextStyle(color: _textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textSecondary),
        prefixIcon: Icon(icon, color: _accent, size: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent),
        ),
        filled: true,
        fillColor: _surface,
      ),
      items: anos
          .map((a) => DropdownMenuItem(
                value: a,
                child: Text('$a'),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  // ── Botão consultar ──
  Widget _buildBotaoConsultar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: processando ? null :_abrirFormulario ,//_consultar
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentDark,
          disabledBackgroundColor: _surface2,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: processando
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Text('Processando...',
                      style: TextStyle(color: Colors.white)),
                ],
              )
            : const Text(
                'Consultar',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(width: 3, height: 18, color: _accent,
            margin: const EdgeInsets.only(right: 10)),
        Text(label,
            style: const TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // LÓGICA DE CICLOS — preservada intacta
  // ─────────────────────────────────────────────
  bool _cruza(int g1, int g2, int alvo) {
    if ((g1 - g2).abs() > 300) {
      if (g1 > g2) {
        g2 += 360;
      } else {
        g1 += 360;
      }
      if (alvo < 50) alvo += 360;
    }
    return (alvo > min(g1, g2) && alvo < max(g1, g2));
  }

  DateTime _interpolar(DateTime d1, DateTime d2, int g1, int g2, int alvo) {
    final total   = (g2 - g1).abs();
    final parcial = (alvo - g1).abs();
    final fator   = total == 0 ? 0.0 : parcial / total;
    final diff    = d2.difference(d1).inMilliseconds;
    return d1.add(Duration(milliseconds: (diff * fator).round()));
  }

  List<MeuCiclo> _filtrarUltimosPorPeriodo(
      List<MeuCiclo> lista, {required int meses}) {
    lista.sort((a, b) => a.data!.compareTo(b.data!));
    final map = <int, List<MeuCiclo>>{};
    for (var e in lista) {
      map.putIfAbsent(e.grau!, () => []).add(e);
    }

    final result = <MeuCiclo>[];
    map.forEach((_, eventos) {
      DateTime? inicio;
      MeuCiclo? ultimo;
      for (var e in eventos) {
        if (inicio == null) { inicio = e.data; ultimo = e; continue; }
        final diff = (e.data!.year - inicio.year) * 12 +
                     (e.data!.month - inicio.month);
        if (diff <= meses) {
          ultimo = e;
        } else {
          result.add(ultimo!);
          inicio = e.data;
          ultimo = e;
        }
      }
      if (ultimo != null) result.add(ultimo);
    });
    return result..sort((a, b) => a.data!.compareTo(b.data!));
  }

  Set<int> _montarListaGraus(GrauCalculado g) {
    final lista = [
      g.grau_a, g.grau_b, g.grau_c, g.grau_d,
      g.grau_e, g.grau_f, g.grau_g, g.grau_h,
    ];
    final result = <int>{};
    for (var v in lista) {
      result.addAll([_norm(v! - 5), _norm(v), _norm(v + 5)]);
    }
    return result;
  }

  Future<String> obterFase(GrauCalculado g, int grau) async {
    final lista = [
      {'letra': 'A', 'valor': g.grau_a},
      {'letra': 'B', 'valor': g.grau_b},
      {'letra': 'C', 'valor': g.grau_c},
      {'letra': 'D', 'valor': g.grau_d},
      {'letra': 'E', 'valor': g.grau_e},
      {'letra': 'F', 'valor': g.grau_f},
      {'letra': 'G', 'valor': g.grau_g},
      {'letra': 'H', 'valor': g.grau_h},
    ];
    for (int i = 0; i < lista.length; i++) {
      final atual  = lista[i];
      final proximo = lista[(i + 1) % lista.length];
      final gAtual = atual['valor'] as int;
      final gProx  = proximo['valor'] as int;
      if (grau == gAtual) return atual['letra'] as String;
      if (gAtual < gProx) {
        if (grau > gAtual && grau < gProx) {
          return '${atual['letra']}${proximo['letra']}';
        }
      } else {
        if (grau > gAtual || grau < gProx) {
          return '${atual['letra']}${proximo['letra']}';
        }
      }
    }
    return '';
  }

  // refinarMeuCiclo, _montarLinhaGrafico, ajustarStringPeriodo,
  // _formatDataBR, adicionarMeses, adicionarAnos — preservados sem alteração
  Future<void> refinarMeuCiclo(
      GrauCalculado g, List<MeuCiclo> ciclo, String planeta) async {
    final principais = [
      g.grau_a, g.grau_b, g.grau_c, g.grau_d,
      g.grau_e, g.grau_f, g.grau_x1, g.grau_x2,
      g.grau_g, g.grau_h,
    ];
    List<MeuCiclo> resultado = [];
    List<MeuCiclo> resultadoFinal = [];

    for (int i = 0; i < ciclo.length; i++) {
      final atual = ciclo[i];
      if (atual.grau == null || atual.data == null) continue;
      final grau = atual.grau!;
      if (!principais.contains(grau)) continue;

      String? dataAnterior = '';
      String dataPrincipal = _formatDataBR(atual.data!);
      String? dataPosterior = '';
      DateTime dataAnteriorCiclo =
          DateTime(anoInicial!, dataNascimento!.month, dataNascimento!.day);
      DateTime dataPosteriorCiclo =
          DateTime(anoInicial!, dataNascimento!.month, dataNascimento!.day);

      if (i > 0) {
        final prev = ciclo[i - 1];
        if (prev.grau != null &&
            ((prev.grau! + 5) % 360 == grau) &&
            prev.data != null) {
          dataAnterior = _formatDataBR(prev.data!);
          dataAnteriorCiclo = prev.data!;
        }
      }
      if (i < ciclo.length - 1) {
        final next = ciclo[i + 1];
        if (next.grau != null &&
            ((next.grau! - 5 + 360) % 360 == grau) &&
            next.data != null) {
          dataPosterior = _formatDataBR(next.data!);
          dataPosteriorCiclo = next.data!;
        }
      }

      String datas = '';
      if (dataAnterior != '') datas += '$dataAnterior → ';
      datas += dataPrincipal;
      if (dataPosterior != '') datas += ' → $dataPosterior';

      resultado.add(MeuCiclo(
        nome: planeta,
        data: atual.data!,
        data_0: dataAnteriorCiclo,
        data_1: dataPosteriorCiclo,
        grau: grau,
      )..datastring = datas);
    }

    DateTime dataComparacaoAnterior = DateTime.now();

    for (int i = 0; i < resultado.length; i++) {
      String dataAnteriorFinal = '';
      String dataPrincipalFinal = '';
      String dataPosteriorFinal = '';
      DateTime dataPrincipalCicloFinal = resultado[i].data!;
      final limiteIni = DateTime(anoInicial!, dataNascimento!.month, 1);
      final limiteFim = DateTime(anoFinal!,   dataNascimento!.month, 1);

      if (i == 0) {
        String datasFinal = '';
        if (resultado[i].data!.isBefore(limiteIni)) {
          if (resultado[i].data_1!.isBefore(limiteIni)) {
            dataPosteriorFinal = _formatDataBR(limiteIni);
            dataPrincipalCicloFinal = limiteIni;
            datasFinal = ' → $dataPosteriorFinal';
          } else if (resultado[i].data_1!.isAfter(limiteIni)) {
            if (resultado[i].data_1!.difference(limiteIni).inDays >=
                limiteIni.difference(resultado[i].data!).inDays) {
              dataPrincipalFinal = _formatDataBR(limiteIni);
              dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
              dataPrincipalCicloFinal = limiteIni;
              datasFinal = '$dataPrincipalFinal → $dataPosteriorFinal';
            } else {
              dataPosteriorFinal = _formatDataBR(limiteIni);
              dataPrincipalCicloFinal = limiteIni;
              datasFinal = ' → $dataPosteriorFinal';
            }
          } else {
            dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
            dataPrincipalCicloFinal = resultado[i].data_1!;
            datasFinal = ' → $dataPosteriorFinal';
          }
        } else if (resultado[i].data!.isAfter(limiteIni)) {
          if (resultado[i].data_0!.isBefore(limiteIni)) {
            if (resultado[i].data_0!.difference(limiteIni).inDays >=
                limiteIni.difference(resultado[i].data!).inDays) {
              dataPrincipalFinal = _formatDataBR(limiteIni);
              dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
              dataPrincipalCicloFinal = limiteIni;
              datasFinal = ' → $dataPrincipalFinal → $dataPosteriorFinal';
            } else {
              dataAnteriorFinal = _formatDataBR(limiteIni);
              dataPrincipalFinal = _formatDataBR(resultado[i].data!);
              dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
              dataPrincipalCicloFinal = limiteIni;
              datasFinal =
                  '$dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal';
            }
          } else if (resultado[i].data_0!.isAfter(limiteIni)) {
            dataAnteriorFinal = _formatDataBR(limiteIni);
            dataPrincipalFinal = _formatDataBR(resultado[i].data!);
            dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
            dataPrincipalCicloFinal = limiteIni;
            datasFinal =
                '$dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal';
          } else {
            dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
            dataPrincipalFinal = _formatDataBR(resultado[i].data!);
            dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
            dataPrincipalCicloFinal = resultado[i].data_0!;
            datasFinal =
                '$dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal';
          }
        } else {
          dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
          dataPrincipalFinal = _formatDataBR(resultado[i].data!);
          dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
          dataPrincipalCicloFinal = resultado[i].data!;
          datasFinal =
              '$dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal';
        }
        resultadoFinal.add(MeuCiclo(
          nome: planeta,
          data: dataPrincipalCicloFinal,
          grau: resultado[i].grau!,
        )..datastring = ajustarStringPeriodo(datasFinal));
      } else if (i == resultado.length - 1) {
        String datasFinal = '';
        if (resultado[i].data!.isBefore(limiteFim)) {
          if (resultado[i].data_1!.isBefore(limiteFim)) {
            dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
            dataPrincipalFinal = _formatDataBR(resultado[i].data!);
            dataPosteriorFinal = _formatDataBR(limiteFim);
            dataPrincipalCicloFinal = limiteFim;
            datasFinal =
                ' $dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal';
          } else if (resultado[i].data_1!.isAfter(limiteFim)) {
            if (resultado[i].data_1!.difference(limiteFim).inDays >=
                limiteFim.difference(resultado[i].data!).inDays) {
              dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
              dataPrincipalFinal = _formatDataBR(limiteFim);
              dataPrincipalCicloFinal = limiteFim;
              datasFinal = ' $dataAnteriorFinal → $dataPrincipalFinal → ';
            } else {
              dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
              dataPrincipalFinal = _formatDataBR(resultado[i].data!);
              dataPosteriorFinal = _formatDataBR(limiteFim);
              dataPrincipalCicloFinal = limiteFim;
              datasFinal =
                  ' $dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal';
            }
          } else {
            dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
            dataPrincipalFinal = _formatDataBR(resultado[i].data!);
            dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
            dataPrincipalCicloFinal = resultado[i].data_1!;
            datasFinal =
                ' $dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal';
          }
        } else if (resultado[i].data!.isAfter(limiteFim)) {
          if (resultado[i].data_0!.isBefore(limiteFim)) {
            if (resultado[i].data_0!.difference(limiteFim).inDays >=
                limiteFim.difference(resultado[i].data!).inDays) {
              dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
              dataPrincipalFinal = _formatDataBR(limiteFim);
              dataPrincipalCicloFinal = limiteFim;
              datasFinal = '$dataAnteriorFinal → $dataPrincipalFinal → ';
            } else {
              dataAnteriorFinal = _formatDataBR(limiteFim);
              dataPrincipalCicloFinal = limiteFim;
              datasFinal = '$dataAnteriorFinal →  ';
            }
          } else if (resultado[i].data_0!.isAfter(limiteFim)) {
            dataAnteriorFinal = _formatDataBR(limiteFim);
            dataPrincipalCicloFinal = limiteFim;
            datasFinal = '$dataAnteriorFinal → ';
          } else {
            dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
            dataPrincipalCicloFinal = resultado[i].data_0!;
            datasFinal = '$dataAnteriorFinal → ';
          }
        } else {
          dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
          dataPrincipalFinal = _formatDataBR(resultado[i].data!);
          dataPrincipalCicloFinal = resultado[i].data!;
          datasFinal = '$dataAnteriorFinal → $dataPrincipalFinal → ';
        }

        if (dataComparacaoAnterior.isAfter(dataPrincipalCicloFinal) ||
            dataComparacaoAnterior
                .isAtSameMomentAs(dataPrincipalCicloFinal)) {
          dataPrincipalCicloFinal =
              adicionarMeses(dataComparacaoAnterior, 1);
        }
        resultadoFinal.add(MeuCiclo(
          nome: planeta,
          data: dataPrincipalCicloFinal,
          grau: resultado[i].grau!,
        )..datastring = ajustarStringPeriodo(datasFinal));
      } else {
        resultadoFinal.add(MeuCiclo(
          nome: resultado[i].nome,
          data: resultado[i].data!,
          grau: resultado[i].grau!,
        )..datastring =
            ajustarStringPeriodo(resultado[i].datastring!));
      }
      dataComparacaoAnterior = resultado[i].data!;
    }

    _cicloPorPlaneta[planeta] = resultadoFinal;
  }

  Future<List<MeuGrafico>> _montarLinhaGrafico(
      List<MeuCiclo> lista, GrauCalculado g) async {
    final linha = <MeuGrafico>[];
    if (lista.isEmpty) return linha;

    // tabela de fases → y para Masculino e Feminino
    const fasesM = {
      'A': 0,  'AB': -1, 'B': -2, 'BC': -1, 'C': 0,  'CD': 1,
      'D': 2,  'DE': 1,  'E': 0,  'EF': -1, 'F': -2, 'FG': -1,
      'G': 0,  'GH': 1,  'H': 2,  'HA': 1,
    };
    const fasesF = {
      'A': 0,  'AB': 1,  'B': 2,  'BC': 1,  'C': 0,  'CD': -1,
      'D': -2, 'DE': -1, 'E': 0,  'EF': 1,  'F': 2,  'FG': 1,
      'G': 0,  'GH': -1, 'H': -2, 'HA': -1,
    };
    final tabela = sexo == 'Feminino' ? fasesF : fasesM;

    for (final item in lista) {
      if (item.grau == null) continue;
      final faseAtual = await obterFase(g, item.grau!);
      final data = DateTime.parse(item.data.toString());

      linha.add(MeuGrafico(
        eixo_x: data.millisecondsSinceEpoch,
        eixo_y: tabela[faseAtual] ?? 0,
        datastring: item.datastring,
        letra: faseAtual,
        nome: item.nome ?? '',
      ));
    }
    return linha;
  }

  // ─────────────────────────────────────────────
  // HELPERS — preservados intactos
  // ─────────────────────────────────────────────
  String _formatDataBR(DateTime data) =>
      '${data.month.toString().padLeft(2, '0')}/'
      '${data.year.toString().padLeft(4, '0')}';

  String ajustarStringPeriodo(String input) {
    if (input.isEmpty) return '';
    final partes = input.split('→');
    final unicas = <String>[];
    for (var p in partes.map((e) => e.trim()).where(
        (e) => e.isNotEmpty && e.toLowerCase() != 'null')) {
      if (!unicas.contains(p)) unicas.add(p);
    }
    return unicas.join(' → ');
  }

  DateTime adicionarMeses(DateTime data, int meses) {
    int novoMes = data.month + meses;
    int novoAno = data.year + ((novoMes - 1) ~/ 12);
    novoMes     = ((novoMes - 1) % 12) + 1;
    final ultimoDia = DateTime(novoAno, novoMes + 1, 0).day;
    return DateTime(novoAno, novoMes,
        data.day > ultimoDia ? ultimoDia : data.day);
  }

  DateTime adicionarAnos(DateTime data, int anos) =>
      DateTime(data.year + anos, data.month, data.day);

  // ─────────────────────────────────────────────
  // SERVICES — preservados intactos
  // ─────────────────────────────────────────────
  Future<int> _buscarGrauPermanente({int? dia, int? mes}) async {
    final data =
        await GrauPermanenteService.getGrausPermanentes(dia: dia, mes: mes);
    return data.isEmpty ? 0 : data.first.grau ?? 0;
  }

  Future<GrauCalculado> _buscarGrauCalculado({String? grau_a}) async {
    final data =
        await GrauCalculadoService.getGrausCalculados(grau_a: grau_a);
    return data.isEmpty
        ? GrauCalculado(
            grau_a: 0, grau_b: 0, grau_c: 0, grau_x1: 0,
            grau_d: 0, grau_e: 0, grau_f: 0, grau_x2: 0,
            grau_g: 0, grau_h: 0,
          )
        : data.first;
  }

  Future<void> gerarPDF(GrauCalculado gc) async {
    setState(() => processando = true);
    final pdf = pw.Document();
    final cicloTotal = _cicloPorPlaneta.values.expand((l) => l).toList()
      ..sort((a, b) => a.data!.compareTo(b.data!));

    pdf.addPage(pw.Page(
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Mapa de Ciclo',
              style: pw.TextStyle(fontSize: 20)),
          pw.SizedBox(height: 20),
          ...cicloTotal.map((e) {
            final f = getFase(e.grau!, gc);
            return pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(f),
                  pw.Text('${e.grau}'),
                  pw.Text(
                      '${e.data!.day}/${e.data!.month}/${e.data!.year}'),
                ],
              ),
            );
          }),
        ],
      ),
    ));

    await Printing.layoutPdf(
        onLayout: (format) async => pdf.save());
    setState(() => processando = false);
  }

  String getFase(int grau, GrauCalculado gc) {
    final mapa = {
      'A': gc.grau_a, 'B': gc.grau_b, 'C': gc.grau_c,
      'X1': gc.grau_x1, 'D': gc.grau_d, 'E': gc.grau_e,
      'F': gc.grau_f, 'X2': gc.grau_x2, 'G': gc.grau_g,
      'H': gc.grau_h,
    };
    for (var entry in mapa.entries) {
      final base = entry.value!;
      if (grau == base)           return entry.key;
      if (grau == _norm(base - 5)) return '${entry.key}-5';
      if (grau == _norm(base + 5)) return '${entry.key}+5';
    }
    return '';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FORMULÁRIO (novo / editar)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _abrirFormulario({Map<String, dynamic>? item}) async {
    try {
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: 1200,
            height: 830,
            child: MapaCompletoPage(
              onMenuItemSelected: (int i) {}, // 🔥 OBRIGATÓRIO
              dataNascimento: anoInicial.toString(),
              dataFinal: anoFinal.toString(),
              sexo: sexo,
              mapaActive: true,
            ),
          ),
        ),
      );
    } finally {}
  }



}













/*ultima versao funcionando
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/graucalculado_model.dart';
import '../models/grauplaneta_model.dart';
import '../models/meuciclo_model.dart';
import '../models/meugrafico_model.dart';
import '../services/auth_service.dart';
import '../services/graupermanente_service.dart';
import '../services/graucalculado_service.dart';
import '../services/grauplaneta_service.dart';

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

// ─────────────────────────────────────────────
// CONFIG DE CADA PLANETA
// ─────────────────────────────────────────────
class _PlanetaCfg {
  final String letra;
  final String codciclo;
  final int meses;
  const _PlanetaCfg(this.letra, this.codciclo, this.meses);
}

const _planetas = [
  _PlanetaCfg('S', '5', 11),
  _PlanetaCfg('V', '3', 6),
  _PlanetaCfg('M', '2', 11),
  _PlanetaCfg('J', '1', 12),
  _PlanetaCfg('U', '6', 120),
  _PlanetaCfg('N', '7', 120),
  _PlanetaCfg('P', '4', 240),
];

// ─────────────────────────────────────────────
// TELA GRÁFICO
// ─────────────────────────────────────────────
class TelaGrafico extends StatefulWidget {
  final List<MeuGrafico> lista;
  final usuario;

  const TelaGrafico({super.key, required this.lista, required this.usuario});

  @override
  State<TelaGrafico> createState() => _TelaGraficoState();
}

class _TelaGraficoState extends State<TelaGrafico> {
  Set<String> planetasSelecionados = {'S', 'V', 'M', 'J', 'U', 'N', 'P'};
  final List<String> todosPlanetas  = ['S', 'V', 'M', 'J', 'U', 'N', 'P'];
  final GlobalKey _chartKey = GlobalKey();

  // cores fixas por planeta — legível em fundo escuro
  static const Map<String, Color> _cores = {
    'S': Color(0xFF38BDF8), // sky
    'V': Color(0xFFF472B6), // pink
    'M': Color(0xFFFF6B6B), // red
    'J': Color(0xFFFBBF24), // amber
    'U': Color(0xFF34D399), // green
    'N': Color(0xFFA78BFA), // purple
    'P': Color(0xFFFB923C), // orange
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        title: Text(
          'Ciclo de ${widget.usuario}',
          style: const TextStyle(color: _textPrimary, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: _textSecondary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Column(
          children: [
            _buildFiltrosPlanetas(),
            const SizedBox(height: 10),
            Expanded(
              child: _buildGrafico(),
            ),
            const SizedBox(height: 10),
            _buildBotaoExportar(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Filtros ──
  Widget _buildFiltrosPlanetas() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: todosPlanetas.map((p) {
          final ativo = planetasSelecionados.contains(p);
          final cor = _cores[p] ?? _accent;
          return GestureDetector(
            onTap: () => setState(() {
              ativo
                  ? planetasSelecionados.remove(p)
                  : planetasSelecionados.add(p);
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ativo ? cor.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ativo ? cor.withOpacity(0.6) : _border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: ativo ? cor : _textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    p,
                    style: TextStyle(
                      color: ativo ? cor : _textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Gráfico ──
  Widget _buildGrafico() {
    return _gerarGraficoMeuCiclo(
      context,
      widget.lista,
      chartKey: _chartKey,
      altura: double.infinity,
      planetasVisiveis: planetasSelecionados,
      espessuraLinha: 2.5,
      mostrarEixoDireito: false,
      mostrarEixoSuperior: false,
      tamanhoFonte: 12,
      corFonte: _textSecondary,
    );
  }

  // ── Botão exportar ──
  Widget _buildBotaoExportar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _gerarPdfComGrafico,
        icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
        label: const Text('Exportar PDF'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF166534),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // GERADOR DE GRÁFICO
  // ─────────────────────────────────────────────
  Widget _gerarGraficoMeuCiclo(
    BuildContext context,
    List<MeuGrafico> lista, {
    GlobalKey? chartKey,
    double altura = 300,
    double tamanhoFonte = 14,
    double tamanhoFonteEmoji = 25,
    double tamanhoFonteBottom = 11,
    Color corFonte = Colors.white,
    double espessuraLinha = 2,
    bool mostrarEixoEsquerdo = true,
    bool mostrarEixoDireito = false,
    bool mostrarEixoInferior = true,
    bool mostrarEixoSuperior = false,
    Set<String>? planetasVisiveis,
  }) {
    List<FlSpot> _downsample(List<FlSpot> pontos, int max) {
      if (pontos.length <= max) return pontos;
      final bucket = (pontos.length / max).ceil();
      final result = <FlSpot>[];
      for (int i = 0; i < pontos.length; i += bucket) {
        final end = (i + bucket).clamp(0, pontos.length);
        final slice = pontos.sublist(i, end);
        FlSpot mn = slice.first, mx = slice.first;
        for (var p in slice) {
          if (p.y < mn.y) mn = p;
          if (p.y > mx.y) mx = p;
        }
        result..add(mn)..add(mx);
      }
      return result..sort((a, b) => a.x.compareTo(b.x));
    }

    final Map<String, List<MeuGrafico>> grupos = {};
    for (var item in lista) {
      final nome = item.nome ?? 'Sem nome';
      grupos.putIfAbsent(nome, () => []).add(item);
    }

    final linhas = <LineChartBarData>[];
    final Map<double, List<MeuGrafico>> mapaX = {};
    double? minX, maxX;

    grupos.forEach((nome, dados) {
      if (planetasVisiveis != null && !planetasVisiveis.contains(nome)) return;
      dados.sort((a, b) => (a.eixo_x ?? 0).compareTo(b.eixo_x ?? 0));

      var spots = <FlSpot>[];
      for (var e in dados) {
        final x = (e.eixo_x ?? 0).toDouble();
        final y = (e.eixo_y ?? 0).toDouble();
        spots.add(FlSpot(x, y));
        mapaX.putIfAbsent(x, () => []).add(e);
        if (minX == null || x < minX!) minX = x;
        if (maxX == null || x > maxX!) maxX = x;
      }

      spots = _downsample(spots, 400);
      linhas.add(LineChartBarData(
        spots: spots,
        isCurved: false,
        color: _cores[nome] ?? _accent,
        barWidth: espessuraLinha,
        dotData: FlDotData(show: false),
      ));
    });

    final range = (minX != null && maxX != null) ? (maxX! - minX!) : 0.0;
    final margem = range * 0.02;
    final largura = MediaQuery.of(context).size.width;

    return RepaintBoundary(
      key: chartKey,
      child: SizedBox(
        height: altura,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            minScale: 1,
            maxScale: 5,
            constrained: true,
            child: SizedBox(
              width: largura * 2,
              child: LineChart(LineChartData(
                backgroundColor: _surface,
                lineBarsData: linhas,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: _border, strokeWidth: 0.5),
                  getDrawingVerticalLine: (_) =>
                      FlLine(color: _border, strokeWidth: 0.5),
                ),
                minY: -2.5,
                maxY: 2.5,
                minX: (minX ?? 0) - margem,
                maxX: (maxX ?? 0) + margem,
                extraLinesData: ExtraLinesData(verticalLines: []),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: mostrarEixoEsquerdo,
                      interval: 1,
                      reservedSize: 50,
                      getTitlesWidget: (value, _) {
                        const emojis = {
                           2: '🚀', 1: '🙂', 0: '⚖️', -1: '🙁', -2: '💀',
                        };
                        final e = emojis[value.toInt()];
                        if (e == null) return const SizedBox();
                        return Center(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(e,
                                style: TextStyle(fontSize: tamanhoFonteEmoji)),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: mostrarEixoDireito)),
                  topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: mostrarEixoSuperior)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: mostrarEixoInferior,
                      reservedSize: 50,
                      interval: 31536000000,
                      getTitlesWidget: (value, _) {
                        final d = DateTime.fromMillisecondsSinceEpoch(
                            value.toInt());
                        return Transform.rotate(
                          angle: -0.5,
                          child: Text(
                            '${d.month}/${d.year}      ',
                            style: TextStyle(
                              color: corFonte,
                              fontSize: tamanhoFonteBottom,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => _surface2,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (spots) => spots.map((spot) {
                      final itens = mapaX[spot.x];
                      if (itens == null || itens.isEmpty) return null;
                      final texto = itens
                          .map((i) => '${i.nome}: ${i.datastring}')
                          .join('\n');
                      return LineTooltipItem(
                        texto,
                        const TextStyle(color: _textPrimary, fontSize: 12),
                      );
                    }).toList(),
                  ),
                ),
              )),
            ),
          ),
        ),
      ),
    );
  }

  // ── Captura e PDF ──
  Future<Uint8List?> _capturarGrafico() async {
    final ctx = _chartKey.currentContext;
    if (ctx == null) return null;
    final boundary = ctx.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return null;
    await Future.delayed(const Duration(milliseconds: 300));
    final image = await boundary.toImage(pixelRatio: 3.0);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  Future<void> _gerarPdfComGrafico() async {
    await SchedulerBinding.instance.endOfFrame;
    _mostrarLoading(context);
    try {
      final bytes = await _capturarGrafico();
      if (bytes == null) return;
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(build: (_) => pw.Image(pw.MemoryImage(bytes))),
      );
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Grafico_Ciclo.pdf',
      );
    } finally {
      _fecharLoading(context);
    }
  }

  void _mostrarLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: _accent, strokeWidth: 2),
              SizedBox(height: 16),
              Text('Gerando PDF...',
                  style: TextStyle(color: _textPrimary, fontSize: 14)),
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

// ─────────────────────────────────────────────
// MEU MAPA PAGE
// ─────────────────────────────────────────────
class MeuMapaPage extends StatefulWidget {
  final Function(int) onMenuItemSelected;
  const MeuMapaPage({super.key, required this.onMenuItemSelected});

  @override
  State<MeuMapaPage> createState() => _MeuMapaPageState();
}

class _MeuMapaPageState extends State<MeuMapaPage> {
  String nome = '';
  String sexo = '';
  DateTime? dataNascimento;

  int? anoInicial;
  int? anoFinal;
  bool loading = true;
  bool processando = false;

  // Graus dos planetas — indexados pela letra
  final Map<String, List<GrauPlaneta>> _grausPorPlaneta = {
    'S': [], 'V': [], 'M': [], 'J': [], 'U': [], 'N': [], 'P': [],
  };

  // Ciclos por planeta — indexados pela letra
  final Map<String, List<MeuCiclo>> _cicloPorPlaneta = {
    'S': [], 'V': [], 'M': [], 'J': [], 'U': [], 'N': [], 'P': [],
  };

  List<MeuGrafico> meuGrafico = [];
  List<int> anos = [];

  int _norm(int g) => g <= 0 ? 360 + g : (g > 360 ? g - 360 : g);

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  void _selectItem(int index) {
    widget.onMenuItemSelected(index);
  }

  // ─────────────────────────────────────────────
  // CARREGAR USUÁRIO
  // ─────────────────────────────────────────────
  Future<void> _carregarUsuario() async {
    final user = await AuthService.getUserData();

    nome = user['nome'] ?? '';
    final s = user['sexo'] ?? '';
    sexo = s == 'M' ? 'Masculino' : s == 'F' ? 'Feminino' : s;

    dataNascimento = user['data_nascimento'] != null
        ? DateTime.parse(user['data_nascimento'])
        : DateTime(2000, 1, 1);

    anoInicial = dataNascimento!.year;
    anoFinal   = DateTime.now().year;

    final diff = 2100 - anoInicial! + 1;
    anos = List.generate(diff, (i) => anoInicial! + i);

    setState(() => loading = false);
  }

  // ─────────────────────────────────────────────
  // CONSULTAR
  // ─────────────────────────────────────────────
  Future<void> _consultar() async {
    if (anoInicial! > anoFinal!) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Atenção',
              style: TextStyle(color: _textPrimary)),
          content: const Text(
              'Ano inicial não pode ser maior que ano final.',
              style: TextStyle(color: _textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK',
                  style: TextStyle(color: _accent)),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => processando = true);

    try {
      final grauBase = await _buscarGrauPermanente(
        dia: dataNascimento?.day,
        mes: dataNascimento?.month,
      );
      final grauCalc = await _buscarGrauCalculado(grau_a: grauBase.toString());

      // Busca graus de todos os planetas em paralelo
      await Future.wait(_planetas.map((cfg) async {
        _grausPorPlaneta[cfg.letra] =
            await GrauPlanetaService.getGrausPlanetas(codciclo: cfg.codciclo);
      }));

      final dn = dataNascimento!;

      // Monta ciclo de cada planeta
      for (final cfg in _planetas) {
        final isPluton = cfg.letra == 'P';
        final dataIni = isPluton
            ? DateTime(dn.year - 5, dn.month, dn.day)
            : DateTime(dn.year, dn.month - 6, dn.day);
        final dataFim = isPluton
            ? DateTime(anoFinal! + 5, dn.month, dn.day)
            : DateTime(anoFinal!, dn.month + 6, dn.day);

        await _montarCicloPlaneta(
          grauCalc,
          cfg: cfg,
          dataInicial: dataIni,
          dataFinal: dataFim,
        );
        await refinarMeuCiclo(
            grauCalc, _cicloPorPlaneta[cfg.letra]!, cfg.letra);
      }

      await _montarGrafico(grauCalc);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              TelaGrafico(lista: meuGrafico, usuario: nome),
        ),
      );
    } finally {
      if (mounted) setState(() => processando = false);
    }
  }

  // ─────────────────────────────────────────────
  // MÉTODO GENÉRICO — substitui os 7 montarCicloXxx
  // ─────────────────────────────────────────────
  Future<void> _montarCicloPlaneta(
    GrauCalculado g, {
    required _PlanetaCfg cfg,
    DateTime? dataInicial,
    DateTime? dataFinal,
  }) async {
    final lista = _grausPorPlaneta[cfg.letra]!;
    final destino = <MeuCiclo>[];
    final grausAlvo = _montarListaGraus(g);

    lista.sort((a, b) => a.data!.compareTo(b.data!));

    final filtrada = lista.where((e) {
      if (e.data == null) return false;
      if (dataInicial != null && e.data!.isBefore(dataInicial)) return false;
      if (dataFinal   != null && e.data!.isAfter(dataFinal))    return false;
      return true;
    }).toList();

    if (filtrada.length < 2) return;

    for (int i = 0; i < filtrada.length - 1; i++) {
      final a  = filtrada[i];
      final b  = filtrada[i + 1];
      final g1 = a.grau!;
      final g2 = b.grau!;

      if (grausAlvo.contains(g1)) {
        destino.add(MeuCiclo(data: a.data!, grau: g1, nome: cfg.letra));
      }
      for (var alvo in grausAlvo) {
        if (_cruza(g1, g2, alvo)) {
          destino.add(MeuCiclo(
            data: _interpolar(a.data!, b.data!, g1, g2, alvo),
            grau: alvo,
            nome: cfg.letra,
          ));
        }
      }
    }

    _cicloPorPlaneta[cfg.letra] =
        _filtrarUltimosPorPeriodo(destino, meses: cfg.meses);
  }

  // ─────────────────────────────────────────────
  // MONTAR GRÁFICO
  // ─────────────────────────────────────────────
  Future<void> _montarGrafico(GrauCalculado g) async {
    meuGrafico.clear();
    for (final cfg in _planetas) {
      final lista = _cicloPorPlaneta[cfg.letra]!;
      if (lista.isEmpty) continue;
      final linha = await _montarLinhaGrafico(lista, g);
      meuGrafico.addAll(linha);
    }
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        centerTitle: isMobile,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.map_outlined, color: _accent, size: 18),
            SizedBox(width: 8),
            Text('Meu Mapa',
                style: TextStyle(color: _textPrimary, fontSize: 17)),
          ],
        ),
        actions: isMobile
            ? null
            : [
                _navBtn('Home',   0),
                _navBtn('Mapa',   1),
                _navBtn('Perfil', 2),
                const SizedBox(width: 8),
              ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: _accent, strokeWidth: 2))
          : SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeroMapa(),
                        const SizedBox(height: 32),
                        _buildSecaoUsuario(),
                        const SizedBox(height: 24),
                        _buildSecaoPeriodo(),
                        const SizedBox(height: 24),
                        _buildBotaoConsultar(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _navBtn(String label, int index) {
    return TextButton(
      onPressed: () => _selectItem(index),
      style: TextButton.styleFrom(foregroundColor: _textSecondary),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }

  // ── Hero ──
  Widget _buildHeroMapa() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: _accentDark.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: _accentDark.withOpacity(0.4), width: 1.5),
            ),
            child: const Icon(Icons.loop, color: _accent, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Gerar meu Mapa',
            style: TextStyle(
              color: _textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Selecione o período e consulte os ciclos planetários',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Seção dados do usuário ──
  Widget _buildSecaoUsuario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Minhas informações'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              _infoRow(Icons.person_outline, 'Nome', nome),
              const SizedBox(height: 12),
              _infoRow(Icons.wc_outlined, 'Sexo', sexo),
              const SizedBox(height: 12),
              _infoRow(
                Icons.cake_outlined,
                'Nascimento',
                dataNascimento != null
                    ? '${dataNascimento!.day.toString().padLeft(2, '0')}/'
                      '${dataNascimento!.month.toString().padLeft(2, '0')}/'
                      '${dataNascimento!.year}'
                    : '—',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _accent, size: 18),
        const SizedBox(width: 10),
        Text('$label: ',
            style: const TextStyle(
                color: _textSecondary, fontSize: 14)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                color: _textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ── Seção período ──
  Widget _buildSecaoPeriodo() {
    final dropStyle = DropdownButtonFormField<int>(
      // só para referenciar o estilo — não usado diretamente
      items: const [],
      onChanged: null,
      decoration: const InputDecoration(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Período'),
        const SizedBox(height: 12),
        _dropdown(
          label: 'Ano inicial',
          value: anoInicial,
          icon: Icons.calendar_today_outlined,
          onChanged: (v) => setState(() => anoInicial = v),
        ),
        const SizedBox(height: 12),
        _dropdown(
          label: 'Ano final',
          value: anoFinal,
          icon: Icons.event_outlined,
          onChanged: (v) => setState(() => anoFinal = v),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required int? value,
    required IconData icon,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      dropdownColor: _surface2,
      style: const TextStyle(color: _textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textSecondary),
        prefixIcon: Icon(icon, color: _accent, size: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent),
        ),
        filled: true,
        fillColor: _surface,
      ),
      items: anos
          .map((a) => DropdownMenuItem(
                value: a,
                child: Text('$a'),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  // ── Botão consultar ──
  Widget _buildBotaoConsultar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: processando ? null : _consultar,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentDark,
          disabledBackgroundColor: _surface2,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: processando
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Text('Processando...',
                      style: TextStyle(color: Colors.white)),
                ],
              )
            : const Text(
                'Consultar',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(width: 3, height: 18, color: _accent,
            margin: const EdgeInsets.only(right: 10)),
        Text(label,
            style: const TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // LÓGICA DE CICLOS — preservada intacta
  // ─────────────────────────────────────────────
  bool _cruza(int g1, int g2, int alvo) {
    if ((g1 - g2).abs() > 300) {
      if (g1 > g2) g2 += 360; else g1 += 360;
      if (alvo < 50) alvo += 360;
    }
    return (alvo > min(g1, g2) && alvo < max(g1, g2));
  }

  DateTime _interpolar(DateTime d1, DateTime d2, int g1, int g2, int alvo) {
    final total   = (g2 - g1).abs();
    final parcial = (alvo - g1).abs();
    final fator   = total == 0 ? 0.0 : parcial / total;
    final diff    = d2.difference(d1).inMilliseconds;
    return d1.add(Duration(milliseconds: (diff * fator).round()));
  }

  List<MeuCiclo> _filtrarUltimosPorPeriodo(
      List<MeuCiclo> lista, {required int meses}) {
    lista.sort((a, b) => a.data!.compareTo(b.data!));
    final map = <int, List<MeuCiclo>>{};
    for (var e in lista) map.putIfAbsent(e.grau!, () => []).add(e);

    final result = <MeuCiclo>[];
    map.forEach((_, eventos) {
      DateTime? inicio;
      MeuCiclo? ultimo;
      for (var e in eventos) {
        if (inicio == null) { inicio = e.data; ultimo = e; continue; }
        final diff = (e.data!.year - inicio.year) * 12 +
                     (e.data!.month - inicio.month);
        if (diff <= meses) {
          ultimo = e;
        } else {
          result.add(ultimo!);
          inicio = e.data;
          ultimo = e;
        }
      }
      if (ultimo != null) result.add(ultimo);
    });
    return result..sort((a, b) => a.data!.compareTo(b.data!));
  }

  Set<int> _montarListaGraus(GrauCalculado g) {
    final lista = [
      g.grau_a, g.grau_b, g.grau_c, g.grau_d,
      g.grau_e, g.grau_f, g.grau_g, g.grau_h,
    ];
    final result = <int>{};
    for (var v in lista) {
      result.addAll([_norm(v! - 5), _norm(v), _norm(v + 5)]);
    }
    return result;
  }

  Future<String> obterFase(GrauCalculado g, int grau) async {
    final lista = [
      {'letra': 'A', 'valor': g.grau_a},
      {'letra': 'B', 'valor': g.grau_b},
      {'letra': 'C', 'valor': g.grau_c},
      {'letra': 'D', 'valor': g.grau_d},
      {'letra': 'E', 'valor': g.grau_e},
      {'letra': 'F', 'valor': g.grau_f},
      {'letra': 'G', 'valor': g.grau_g},
      {'letra': 'H', 'valor': g.grau_h},
    ];
    for (int i = 0; i < lista.length; i++) {
      final atual  = lista[i];
      final proximo = lista[(i + 1) % lista.length];
      final gAtual = atual['valor'] as int;
      final gProx  = proximo['valor'] as int;
      if (grau == gAtual) return atual['letra'] as String;
      if (gAtual < gProx) {
        if (grau > gAtual && grau < gProx)
          return '${atual['letra']}${proximo['letra']}';
      } else {
        if (grau > gAtual || grau < gProx)
          return '${atual['letra']}${proximo['letra']}';
      }
    }
    return '';
  }

  // refinarMeuCiclo, _montarLinhaGrafico, ajustarStringPeriodo,
  // _formatDataBR, adicionarMeses, adicionarAnos — preservados sem alteração
  Future<void> refinarMeuCiclo(
      GrauCalculado g, List<MeuCiclo> ciclo, String planeta) async {
    final principais = [
      g.grau_a, g.grau_b, g.grau_c, g.grau_d,
      g.grau_e, g.grau_f, g.grau_x1, g.grau_x2,
      g.grau_g, g.grau_h,
    ];
    List<MeuCiclo> resultado = [];
    List<MeuCiclo> resultadoFinal = [];

    for (int i = 0; i < ciclo.length; i++) {
      final atual = ciclo[i];
      if (atual.grau == null || atual.data == null) continue;
      final grau = atual.grau!;
      if (!principais.contains(grau)) continue;

      String? dataAnterior = '';
      String dataPrincipal = _formatDataBR(atual.data!);
      String? dataPosterior = '';
      DateTime dataAnteriorCiclo =
          DateTime(anoInicial!, dataNascimento!.month, dataNascimento!.day);
      DateTime dataPosteriorCiclo =
          DateTime(anoInicial!, dataNascimento!.month, dataNascimento!.day);

      if (i > 0) {
        final prev = ciclo[i - 1];
        if (prev.grau != null &&
            ((prev.grau! + 5) % 360 == grau) &&
            prev.data != null) {
          dataAnterior = _formatDataBR(prev.data!);
          dataAnteriorCiclo = prev.data!;
        }
      }
      if (i < ciclo.length - 1) {
        final next = ciclo[i + 1];
        if (next.grau != null &&
            ((next.grau! - 5 + 360) % 360 == grau) &&
            next.data != null) {
          dataPosterior = _formatDataBR(next.data!);
          dataPosteriorCiclo = next.data!;
        }
      }

      String datas = '';
      if (dataAnterior != '') datas += '$dataAnterior → ';
      datas += dataPrincipal;
      if (dataPosterior != '') datas += ' → $dataPosterior';

      resultado.add(MeuCiclo(
        nome: planeta,
        data: atual.data!,
        data_0: dataAnteriorCiclo,
        data_1: dataPosteriorCiclo,
        grau: grau,
      )..datastring = datas);
    }

    DateTime dataComparacaoAnterior = DateTime.now();

    for (int i = 0; i < resultado.length; i++) {
      String dataAnteriorFinal = '';
      String dataPrincipalFinal = '';
      String dataPosteriorFinal = '';
      DateTime dataPrincipalCicloFinal = resultado[i].data!;
      final limiteIni = DateTime(anoInicial!, dataNascimento!.month, 1);
      final limiteFim = DateTime(anoFinal!,   dataNascimento!.month, 1);

      if (i == 0) {
        String datasFinal = '';
        if (resultado[i].data!.isBefore(limiteIni)) {
          if (resultado[i].data_1!.isBefore(limiteIni)) {
            dataPosteriorFinal = _formatDataBR(limiteIni);
            dataPrincipalCicloFinal = limiteIni;
            datasFinal = ' → $dataPosteriorFinal';
          } else if (resultado[i].data_1!.isAfter(limiteIni)) {
            if (resultado[i].data_1!.difference(limiteIni).inDays >=
                limiteIni.difference(resultado[i].data!).inDays) {
              dataPrincipalFinal = _formatDataBR(limiteIni);
              dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
              dataPrincipalCicloFinal = limiteIni;
              datasFinal = '$dataPrincipalFinal → $dataPosteriorFinal';
            } else {
              dataPosteriorFinal = _formatDataBR(limiteIni);
              dataPrincipalCicloFinal = limiteIni;
              datasFinal = ' → $dataPosteriorFinal';
            }
          } else {
            dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
            dataPrincipalCicloFinal = resultado[i].data_1!;
            datasFinal = ' → $dataPosteriorFinal';
          }
        } else if (resultado[i].data!.isAfter(limiteIni)) {
          if (resultado[i].data_0!.isBefore(limiteIni)) {
            if (resultado[i].data_0!.difference(limiteIni).inDays >=
                limiteIni.difference(resultado[i].data!).inDays) {
              dataPrincipalFinal = _formatDataBR(limiteIni);
              dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
              dataPrincipalCicloFinal = limiteIni;
              datasFinal = ' → $dataPrincipalFinal → $dataPosteriorFinal';
            } else {
              dataAnteriorFinal = _formatDataBR(limiteIni);
              dataPrincipalFinal = _formatDataBR(resultado[i].data!);
              dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
              dataPrincipalCicloFinal = limiteIni;
              datasFinal =
                  '$dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal';
            }
          } else if (resultado[i].data_0!.isAfter(limiteIni)) {
            dataAnteriorFinal = _formatDataBR(limiteIni);
            dataPrincipalFinal = _formatDataBR(resultado[i].data!);
            dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
            dataPrincipalCicloFinal = limiteIni;
            datasFinal =
                '$dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal';
          } else {
            dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
            dataPrincipalFinal = _formatDataBR(resultado[i].data!);
            dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
            dataPrincipalCicloFinal = resultado[i].data_0!;
            datasFinal =
                '$dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal';
          }
        } else {
          dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
          dataPrincipalFinal = _formatDataBR(resultado[i].data!);
          dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
          dataPrincipalCicloFinal = resultado[i].data!;
          datasFinal =
              '$dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal';
        }
        resultadoFinal.add(MeuCiclo(
          nome: planeta,
          data: dataPrincipalCicloFinal,
          grau: resultado[i].grau!,
        )..datastring = ajustarStringPeriodo(datasFinal));
      } else if (i == resultado.length - 1) {
        String datasFinal = '';
        if (resultado[i].data!.isBefore(limiteFim)) {
          if (resultado[i].data_1!.isBefore(limiteFim)) {
            dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
            dataPrincipalFinal = _formatDataBR(resultado[i].data!);
            dataPosteriorFinal = _formatDataBR(limiteFim);
            dataPrincipalCicloFinal = limiteFim;
            datasFinal =
                ' $dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal';
          } else if (resultado[i].data_1!.isAfter(limiteFim)) {
            if (resultado[i].data_1!.difference(limiteFim).inDays >=
                limiteFim.difference(resultado[i].data!).inDays) {
              dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
              dataPrincipalFinal = _formatDataBR(limiteFim);
              dataPrincipalCicloFinal = limiteFim;
              datasFinal = ' $dataAnteriorFinal → $dataPrincipalFinal → ';
            } else {
              dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
              dataPrincipalFinal = _formatDataBR(resultado[i].data!);
              dataPosteriorFinal = _formatDataBR(limiteFim);
              dataPrincipalCicloFinal = limiteFim;
              datasFinal =
                  ' $dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal';
            }
          } else {
            dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
            dataPrincipalFinal = _formatDataBR(resultado[i].data!);
            dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
            dataPrincipalCicloFinal = resultado[i].data_1!;
            datasFinal =
                ' $dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal';
          }
        } else if (resultado[i].data!.isAfter(limiteFim)) {
          if (resultado[i].data_0!.isBefore(limiteFim)) {
            if (resultado[i].data_0!.difference(limiteFim).inDays >=
                limiteFim.difference(resultado[i].data!).inDays) {
              dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
              dataPrincipalFinal = _formatDataBR(limiteFim);
              dataPrincipalCicloFinal = limiteFim;
              datasFinal = '$dataAnteriorFinal → $dataPrincipalFinal → ';
            } else {
              dataAnteriorFinal = _formatDataBR(limiteFim);
              dataPrincipalCicloFinal = limiteFim;
              datasFinal = '$dataAnteriorFinal →  ';
            }
          } else if (resultado[i].data_0!.isAfter(limiteFim)) {
            dataAnteriorFinal = _formatDataBR(limiteFim);
            dataPrincipalCicloFinal = limiteFim;
            datasFinal = '$dataAnteriorFinal → ';
          } else {
            dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
            dataPrincipalCicloFinal = resultado[i].data_0!;
            datasFinal = '$dataAnteriorFinal → ';
          }
        } else {
          dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
          dataPrincipalFinal = _formatDataBR(resultado[i].data!);
          dataPrincipalCicloFinal = resultado[i].data!;
          datasFinal = '$dataAnteriorFinal → $dataPrincipalFinal → ';
        }

        if (dataComparacaoAnterior.isAfter(dataPrincipalCicloFinal) ||
            dataComparacaoAnterior
                .isAtSameMomentAs(dataPrincipalCicloFinal)) {
          dataPrincipalCicloFinal =
              adicionarMeses(dataComparacaoAnterior, 1);
        }
        resultadoFinal.add(MeuCiclo(
          nome: planeta,
          data: dataPrincipalCicloFinal,
          grau: resultado[i].grau!,
        )..datastring = ajustarStringPeriodo(datasFinal));
      } else {
        resultadoFinal.add(MeuCiclo(
          nome: resultado[i].nome,
          data: resultado[i].data!,
          grau: resultado[i].grau!,
        )..datastring =
            ajustarStringPeriodo(resultado[i].datastring!));
      }
      dataComparacaoAnterior = resultado[i].data!;
    }

    _cicloPorPlaneta[planeta] = resultadoFinal;
  }

  Future<List<MeuGrafico>> _montarLinhaGrafico(
      List<MeuCiclo> lista, GrauCalculado g) async {
    final linha = <MeuGrafico>[];
    if (lista.isEmpty) return linha;

    // tabela de fases → y para Masculino e Feminino
    const fasesM = {
      'A': 0,  'AB': -1, 'B': -2, 'BC': -1, 'C': 0,  'CD': 1,
      'D': 2,  'DE': 1,  'E': 0,  'EF': -1, 'F': -2, 'FG': -1,
      'G': 0,  'GH': 1,  'H': 2,  'HA': 1,
    };
    const fasesF = {
      'A': 0,  'AB': 1,  'B': 2,  'BC': 1,  'C': 0,  'CD': -1,
      'D': -2, 'DE': -1, 'E': 0,  'EF': 1,  'F': 2,  'FG': 1,
      'G': 0,  'GH': -1, 'H': -2, 'HA': -1,
    };
    final tabela = sexo == 'Feminino' ? fasesF : fasesM;

    for (final item in lista) {
      if (item.grau == null) continue;
      final faseAtual = await obterFase(g, item.grau!);
      final data = DateTime.parse(item.data.toString());

      linha.add(MeuGrafico(
        eixo_x: data.millisecondsSinceEpoch,
        eixo_y: tabela[faseAtual] ?? 0,
        datastring: item.datastring,
        letra: faseAtual,
        nome: item.nome ?? '',
      ));
    }
    return linha;
  }

  // ─────────────────────────────────────────────
  // HELPERS — preservados intactos
  // ─────────────────────────────────────────────
  String _formatDataBR(DateTime data) =>
      '${data.month.toString().padLeft(2, '0')}/'
      '${data.year.toString().padLeft(4, '0')}';

  String ajustarStringPeriodo(String input) {
    if (input.isEmpty) return '';
    final partes = input.split('→');
    final unicas = <String>[];
    for (var p in partes.map((e) => e.trim()).where(
        (e) => e.isNotEmpty && e.toLowerCase() != 'null')) {
      if (!unicas.contains(p)) unicas.add(p);
    }
    return unicas.join(' → ');
  }

  DateTime adicionarMeses(DateTime data, int meses) {
    int novoMes = data.month + meses;
    int novoAno = data.year + ((novoMes - 1) ~/ 12);
    novoMes     = ((novoMes - 1) % 12) + 1;
    final ultimoDia = DateTime(novoAno, novoMes + 1, 0).day;
    return DateTime(novoAno, novoMes,
        data.day > ultimoDia ? ultimoDia : data.day);
  }

  DateTime adicionarAnos(DateTime data, int anos) =>
      DateTime(data.year + anos, data.month, data.day);

  // ─────────────────────────────────────────────
  // SERVICES — preservados intactos
  // ─────────────────────────────────────────────
  Future<int> _buscarGrauPermanente({int? dia, int? mes}) async {
    final data =
        await GrauPermanenteService.getGrausPermanentes(dia: dia, mes: mes);
    return data.isEmpty ? 0 : data.first.grau ?? 0;
  }

  Future<GrauCalculado> _buscarGrauCalculado({String? grau_a}) async {
    final data =
        await GrauCalculadoService.getGrausCalculados(grau_a: grau_a);
    return data.isEmpty
        ? GrauCalculado(
            grau_a: 0, grau_b: 0, grau_c: 0, grau_x1: 0,
            grau_d: 0, grau_e: 0, grau_f: 0, grau_x2: 0,
            grau_g: 0, grau_h: 0,
          )
        : data.first;
  }

  Future<void> gerarPDF(GrauCalculado gc) async {
    setState(() => processando = true);
    final pdf = pw.Document();
    final cicloTotal = _cicloPorPlaneta.values.expand((l) => l).toList()
      ..sort((a, b) => a.data!.compareTo(b.data!));

    pdf.addPage(pw.Page(
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Mapa de Ciclo',
              style: pw.TextStyle(fontSize: 20)),
          pw.SizedBox(height: 20),
          ...cicloTotal.map((e) {
            final f = getFase(e.grau!, gc);
            return pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(f),
                  pw.Text('${e.grau}'),
                  pw.Text(
                      '${e.data!.day}/${e.data!.month}/${e.data!.year}'),
                ],
              ),
            );
          }),
        ],
      ),
    ));

    await Printing.layoutPdf(
        onLayout: (format) async => pdf.save());
    setState(() => processando = false);
  }

  String getFase(int grau, GrauCalculado gc) {
    final mapa = {
      'A': gc.grau_a, 'B': gc.grau_b, 'C': gc.grau_c,
      'X1': gc.grau_x1, 'D': gc.grau_d, 'E': gc.grau_e,
      'F': gc.grau_f, 'X2': gc.grau_x2, 'G': gc.grau_g,
      'H': gc.grau_h,
    };
    for (var entry in mapa.entries) {
      final base = entry.value!;
      if (grau == base)           return entry.key;
      if (grau == _norm(base - 5)) return '${entry.key}-5';
      if (grau == _norm(base + 5)) return '${entry.key}+5';
    }
    return '';
  }
}
*/























/*
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
//import 'package:universal_html/js.dart';

import '../models/graucalculado_model.dart';
import '../models/grauplaneta_model.dart';
import '../models/meuciclo_model.dart';
import '../models/meugrafico_model.dart';

import '../services/auth_service.dart';
import '../services/graupermanente_service.dart';
import '../services/graucalculado_service.dart';
import '../services/grauplaneta_service.dart';


class TelaGrafico extends StatefulWidget {
  final List<MeuGrafico> lista;
  final  usuario;


  const TelaGrafico({super.key, required this.lista, required this.usuario});

  @override
  State<TelaGrafico> createState() => _TelaGraficoState();
}

class _TelaGraficoState extends State<TelaGrafico> {

  // 🔥 estado correto
  Set<String> planetasSelecionados = {'S', 'V', 'M', 'J', 'U', 'N', 'P'};
  //String nome = '';
  final List<String> todosPlanetas = ['S', 'V', 'M', 'J', 'U', 'N', 'P'];
  final GlobalKey _chartKey = GlobalKey();
  


  @override
  Widget build(BuildContext context) {
  // nome = widget.usuario;
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: Text("Gráfico do Ciclo de " + widget.usuario +'👋'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [

           // _field("Nome", nome),
            const SizedBox(height: 10),
            // 🔥 CHECKBOXES
            _buildCheckboxPlanetas(),

            const SizedBox(height: 10),
           // widget.usuario

            // 🔥 GRÁFICO
            Expanded(
              child: gerarGraficoMeuCiclo(
                context,
                widget.lista,
                chartKey: _chartKey,
                altura: double.infinity, // 🔥 deixa o Expanded mandar
                planetasVisiveis: planetasSelecionados,
                espessuraLinha: 3,
                mostrarPontos: true,
                mostrarEixoDireito: false,
                mostrarEixoSuperior: false,
                tamanhoFonte: 12,
                corFonte: Colors.white,
              ),
            ),


            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: gerarPdfComGrafico,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Exportar PDF"),
              ),
            ),

            const SizedBox(height: 25),

          ],
        ),
      ),
    );
  }

  // =========================
  // 🔥 CHECKBOXES FUNCIONAIS
  // =========================
  Widget _buildCheckboxPlanetas() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: todosPlanetas.map((planeta) {
        final ativo = planetasSelecionados.contains(planeta);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (ativo) {
                planetasSelecionados.remove(planeta);
              } else {
                planetasSelecionados.add(planeta);
              }
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: ativo,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      planetasSelecionados.add(planeta);
                    } else {
                      planetasSelecionados.remove(planeta);
                    }
                  });
                },
              ),
              Text(
                planeta,
                style: TextStyle(
                  color: ativo ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget legendaInterativa(
    Map<String, Color> mapaCores,
    Set<String> ativos,
    Function(String) onToggle,
  ) {
    return Wrap(
      spacing: 8,
      children: mapaCores.entries.map((e) {
        final ativo = ativos.contains(e.key);

        return GestureDetector(
          onTap: () => onToggle(e.key),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                color: ativo ? e.value : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                e.key,
                style: TextStyle(
                  color: ativo ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  //**********GRAFICOS************//
  /*VERSAO 5*/
  Widget gerarGraficoMeuCiclo(
    BuildContext context,
    List<MeuGrafico> lista, {
    GlobalKey? chartKey,

    double altura = 300,
    bool mostrarLegenda = true,

    double tamanhoFonte = 14,
    double tamanhoFonteEmoji = 25,
    double tamanhoFonteBottom = 11,
    Color corFonte = Colors.white,
    double espessuraLinha = 2,

    bool mostrarEixoEsquerdo = true,
    bool mostrarEixoDireito = false,
    bool mostrarEixoInferior = true,
    bool mostrarEixoSuperior = false,

    bool mostrarPontos = true,

    Set<String>? planetasVisiveis,
  }) {
    // =========================
    // DOWNSAMPLING
    // =========================
    List<FlSpot> downsample(List<FlSpot> pontos, int maxPontos) {
      if (pontos.length <= maxPontos) return pontos;

      final bucketSize = (pontos.length / maxPontos).ceil();
      final resultado = <FlSpot>[];

      for (int i = 0; i < pontos.length; i += bucketSize) {
        final end =
            (i + bucketSize < pontos.length) ? i + bucketSize : pontos.length;

        final bucket = pontos.sublist(i, end);

        FlSpot min = bucket.first;
        FlSpot max = bucket.first;

        for (var p in bucket) {
          if (p.y < min.y) min = p;
          if (p.y > max.y) max = p;
        }

        resultado.add(min);
        resultado.add(max);
      }

      resultado.sort((a, b) => a.x.compareTo(b.x));
      return resultado;
    }

    // =========================
    // AGRUPAR
    // =========================
    final Map<String, List<MeuGrafico>> grupos = {};
    final Map<String, Color> corPorGrupo = {};

    final cores = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.brown,
      Colors.pinkAccent,
      Colors.yellow,
    ];

    int corIndex = 0;

    for (var item in lista) {
      final nome = item.nome ?? 'Sem nome';
      grupos.putIfAbsent(nome, () => []);
      grupos[nome]!.add(item);

      corPorGrupo.putIfAbsent(nome, () {
        final cor = cores[corIndex % cores.length];
        corIndex++;
        return cor;
      });
    }

    final linhas = <LineChartBarData>[];
    final Map<double, List<MeuGrafico>> mapaX = {};

    double? minXGlobal;
    double? maxXGlobal;

    grupos.forEach((nome, dados) {
      if (planetasVisiveis != null &&
          !planetasVisiveis.contains(nome)) return;

      dados.sort((a, b) => (a.eixo_x ?? 0).compareTo(b.eixo_x ?? 0));

      var spots = <FlSpot>[];

      for (var e in dados) {
        final x = (e.eixo_x ?? 0).toDouble();
        final y = (e.eixo_y ?? 0).toDouble();

        spots.add(FlSpot(x, y));

        mapaX.putIfAbsent(x, () => []);
        mapaX[x]!.add(e);

        if (minXGlobal == null || x < minXGlobal!) minXGlobal = x;
        if (maxXGlobal == null || x > maxXGlobal!) maxXGlobal = x;
      }

      spots = downsample(spots, 400);

      linhas.add(
        LineChartBarData(
          spots: spots,
          isCurved: false,
          color: corPorGrupo[nome],
          barWidth: espessuraLinha,
          dotData: FlDotData(show: false),
        ),
      );
    });


    // =========================
    // FOLGA LATERAL INTELIGENTE
    // =========================
    double margem = 0;
    if (minXGlobal != null && maxXGlobal != null) {
      final range = maxXGlobal! - minXGlobal!;
      margem = range * 0.02;// 2% de folga
    }

    final larguraTela = MediaQuery.of(context).size.width;

    return RepaintBoundary(
      key: chartKey,
      child: SizedBox(
        height: altura,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            minScale: 1,
            maxScale: 5,
            constrained: true,
            child: SizedBox(
              width: larguraTela * 2,
              child: LineChart(
                LineChartData(
                  backgroundColor: Colors.white,
                  lineBarsData: linhas,

                  gridData: FlGridData(show: true),

                  minY: -2.5,
                  maxY: 2.5,
                  minX: (minXGlobal ?? 0) - margem,
                  maxX: (maxXGlobal ?? 0) + margem,

                  // 🔥 LINHA VERTICAL (estilo TradingView)
                  extraLinesData: ExtraLinesData(
                    verticalLines: [],
                  ),

                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: mostrarEixoEsquerdo,
                        interval: 1,
                        reservedSize: 50,

                        getTitlesWidget: (value, meta) {
                          if (value % 1 != 0) return const SizedBox();

                          String? emoji;

                          switch (value.toInt()) {
                            case 2:
                              emoji = '🚀';
                              break;
                            case 1:
                              emoji = '🙂';
                              break;
                            case 0:
                              emoji = '⚖️';
                              break;
                            case -1:
                              emoji = '🙁';
                              break;
                            case -2:
                              emoji = '💀';
                              break;
                          }

                          if (emoji == null) return const SizedBox();

                          return Center(
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                emoji,
                                style: TextStyle(fontSize: tamanhoFonteEmoji, fontFamily: 'poppins',),//Apple Color Emoji
                              ),
                            ),
                          );
                        },

                        /*getTitlesWidget: (value, meta) {
                          if (value % 1 != 0) return const SizedBox();

                          switch (value.toInt()) {
                            case 2:
                              return Text('🚀',
                                  style: TextStyle(fontSize: tamanhoFonte));
                            case 1:
                              return Text('🙂',
                                  style: TextStyle(fontSize: tamanhoFonte));
                            case 0:
                              return Text('⚖️',
                                  style: TextStyle(fontSize: tamanhoFonte));
                            case -1:
                              return Text('🙁',
                                  style: TextStyle(fontSize: tamanhoFonte));
                            case -2:
                              return Text('💀',
                                  style: TextStyle(fontSize: tamanhoFonte));
                            default:
                              return const SizedBox();
                          }
                        },*/
                    
                      ),
                    ),

                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: mostrarEixoDireito),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: mostrarEixoSuperior),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: mostrarEixoInferior,
                        reservedSize: 50,
                        interval: 31536000000,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                              value.toInt());

                          return Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              "${date.month}/${date.year}      ",
                              style: TextStyle(
                                color: corFonte,
                                fontSize: tamanhoFonteBottom,
                                fontFamily: 'courrier',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // 🔥 TOOLTIP PROFISSIONAL
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      //tooltipBgColor: Colors.black87,
                      getTooltipColor: (touchedSpot) => Colors.black87,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems: (spots) {
                        if (spots.isEmpty) return [];

                        return spots.map((spot) {
                          final x = spot.x;
                          final itens = mapaX[x];

                          if (itens == null || itens.isEmpty) {
                            return null;
                          }

                          // 🔥 monta texto com TODAS as séries
                          final texto = itens.map((item) {
                            return "${item.nome}: ${item.datastring}";
                          }).join("\n");

                          return LineTooltipItem(
                            texto,
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'courrier',
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Uint8List?> _capturarGrafico() async {
    try {
      final context = _chartKey.currentContext;

      if (context == null) {
        print("ERRO: context do gráfico é NULL");
        return null;
      }

      final boundary = context.findRenderObject();

      if (boundary == null || boundary is! RenderRepaintBoundary) {
        print("ERRO: boundary inválido");
        return null;
      }

      // aguarda renderização completa
      await Future.delayed(Duration(milliseconds: 300));

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Erro ao capturar gráfico: $e");
      return null;
    }
  }

  Future<void> gerarPdfComGrafico() async {
    await SchedulerBinding.instance.endOfFrame;

    _mostrarLoading(context);

    await Future.delayed(Duration(milliseconds: 50));
    
    try{

      final imageBytes = await _capturarGrafico();

      if (imageBytes == null) return;

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (_) => pw.Image(pw.MemoryImage(imageBytes)),
        ),
      );

      //await Printing.layoutPdf(
      //  onLayout: (format) async => pdf.save(),
      //);

      await Printing.sharePdf(
          bytes: await pdf.save(),
          filename: 'Grafico_Ciclo.pdf',
        );

    } finally {
      _fecharLoading(context);
    }

  }

  void _mostrarLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 15),
              Text('Gerando pdf do gráfico, aguarde...'),
            ],
          ),
        );
      },
    );
  }

  void _fecharLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // ==============================
  // FIELD VISUAL (DESABILITADO)
  // ==============================
  Widget _field(String label, String value) {
    return TextField(
      enabled: false,
      controller: TextEditingController(text: value),
      decoration: _input(label, Icons.lock),
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

class MeuMapaPage extends StatefulWidget {
  final Function(int) onMenuItemSelected;
  const MeuMapaPage({super.key, required this.onMenuItemSelected,});//

  @override
  State<MeuMapaPage> createState() => _MeuMapaPageState();
}

class _MeuMapaPageState extends State<MeuMapaPage> {
  String nome = '';
  String sexo = '';
  DateTime? dataNascimento;
  int selectedIndex = 0;

  int? anoInicial;
  int? anoFinal;

  bool loading = true;
  bool processando = false;

  List<GrauPlaneta> grausSaturno = [];
  List<GrauPlaneta> grausVenus = [];
  List<GrauPlaneta> grausMarte = [];
  List<GrauPlaneta> grausJupiter = [];
  List<GrauPlaneta> grausUrano = [];
  List<GrauPlaneta> grausNetuno = [];
  List<GrauPlaneta> grausPlutao = [];

  List<MeuCiclo> meuCiclo = [];
  //List<MeuCiclo> meuCicloTotal = [];
  List<MeuCiclo> meuCicloSaturno = [];
  List<MeuCiclo> meuCicloVenus = [];
  List<MeuCiclo> meuCicloMarte = [];
  List<MeuCiclo> meuCicloJupiter = [];
  List<MeuCiclo> meuCicloUrano = [];
  List<MeuCiclo> meuCicloNetuno = [];
  List<MeuCiclo> meuCicloPlutao = [];

  List<MeuGrafico> meuGrafico = [];

  List<int> anos =  List.generate(1101, (index) => 1900 + index); // 1900 até 3000

  int _norm(int g) => g <= 0 ? 360 + g : (g > 360 ? g - 360 : g);

  // =============================
  // INIT
  // =============================
  @override
  void initState() {
    super.initState();
    carregarUsuario();
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

  Future<void> carregarUsuario() async {
    //print('ENTROU meumap_page.dart - carregarusuario()');
    final user = await AuthService.getUserData();

    nome = user['nome'] ?? '';
    sexo = user['sexo'] ?? '';
    if(sexo == 'M') sexo = 'Masculino';
    else if(sexo == 'F') sexo = 'Feminino';

    dataNascimento = user['data_nascimento'] != null
        ? DateTime.parse(user['data_nascimento'])
        : DateTime(2000, 1, 1);

    anoInicial = dataNascimento?.year;
    anoFinal = DateTime.now().year;

    int anoDiferenca = 2100 - anoInicial! + 1;

    anos = List.generate(anoDiferenca, (index) => anoInicial! + index); // 1900 até 3000
    //anos = List.generate(1101, (index) => 1900 + index);

    setState(() => loading = false);
  }

  // =============================
  // CONSULTA
  // =============================
  Future<void> consultar() async {
    setState(() => processando = true);
    bool sair = false;
    if(anoInicial! > anoFinal!){
        sair = true;
        final confirmar = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Informação.'),
            content: const Text('Ano inicial não pode ser maior que ano final.'),
            actions: [
              //TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('OK')),
            ],
          ),
        );
    }

    if(sair == true){
      setState(() => processando = false);
      return;
    }

    meuCicloJupiter.clear();
    meuCicloMarte.clear();
    meuCicloVenus.clear();
    meuCicloSaturno.clear();
    meuCicloUrano.clear();
    meuCicloNetuno.clear();
    meuCicloPlutao.clear();

    final grauBase = await buscarGrauPermanente(
      dia: dataNascimento?.day,
      mes: dataNascimento?.month,
    );

    final grauCalc = await buscarGrauCalculado(
      grau_a: grauBase.toString(),
    );
    //debugPrint("Graus Calculados: A=${grauCalc.grau_a}, B=${grauCalc.grau_b}, C=${grauCalc.grau_c}, X1=${grauCalc.grau_x1}, D=${grauCalc.grau_d}, E=${grauCalc.grau_e}, F=${grauCalc.grau_f}, X2=${grauCalc.grau_x2}, G=${grauCalc.grau_g}, H=${grauCalc.grau_h}");  

    grausSaturno = await buscarGrausSaturno(codciclo: '5');
    grausVenus = await buscarGrausVenus(codciclo: '3');
    grausMarte = await buscarGrausMarte(codciclo: '2');
    grausJupiter = await buscarGrausJupiter(codciclo: '1');
    grausUrano = await buscarGrausUrano(codciclo: '6');
    grausNetuno = await buscarGrausNetuno(codciclo: '7');
    grausPlutao = await buscarGrausPlutao(codciclo: '4');

    DateTime dataInicioCiclo = DateTime(dataNascimento!.year, dataNascimento!.month - 6, dataNascimento!.day, 0, 0, 0);
    //debugPrint('Data Início Ciclo: ${dataInicioCiclo.day}/${dataInicioCiclo.month}/${dataInicioCiclo.year}'); // debug para verificar a data de início do ciclo

    await montarCicloSaturno(grauCalc, dataInicial: DateTime(dataNascimento!.year, dataNascimento!.month - 6, dataNascimento!.day, 0, 0, 0), dataFinal: DateTime(anoFinal!, dataNascimento!.month + 6, dataNascimento!.day, 0, 0,0));
    //debugPrint('meu ciclo s: ${meuCicloSaturno.map((c) => 'data: ${c.data}, grau: ${c.grau}, letra: ${c.letra}').toList().toString()}');
    await refinarMeuCiclo(grauCalc, meuCicloSaturno, 'S'); 
   // debugPrint('Ciclo Refinado: ${meuCicloSaturno.map((c) => 'data: ${c.data}, dataString: ${c.datastring}, grau: ${c.grau}, letra: ${c.letra}').toList().toString()}');

    await montarCicloVenus(grauCalc, dataInicial: DateTime(dataNascimento!.year, dataNascimento!.month - 6, dataNascimento!.day, 0, 0, 0), dataFinal: DateTime(anoFinal!, dataNascimento!.month + 6, dataNascimento!.day, 0, 0, 0));
    //debugPrint('meu ciclo v: ${meuCicloVenus.map((c) => 'data: ${c.data}, grau: ${c.grau}, letra: ${c.letra}').toList().toString()}');
    await refinarMeuCiclo(grauCalc, meuCicloVenus, 'V'); 
    //debugPrint('Ciclo Refinado: ${meuCicloVenus.map((c) => 'data: ${c.data}, dataString: ${c.datastring}, grau: ${c.grau}, letra: ${c.letra}').toList().toString()}');

    await montarCicloMarte(grauCalc, dataInicial: DateTime(dataNascimento!.year, dataNascimento!.month - 6, dataNascimento!.day, 0, 0, 0), dataFinal: DateTime(anoFinal!, dataNascimento!.month + 6, dataNascimento!.day, 0, 0, 0));
    //debugPrint('meu ciclo m: ${meuCicloMarte.map((c) => 'data: ${c.data}, grau: ${c.grau}, letra: ${c.letra}').toList().toString()}');
    await refinarMeuCiclo(grauCalc, meuCicloMarte, 'M'); 
    //debugPrint('Ciclo Refinado: ${meuCicloMarte.map((c) => 'data: ${c.data}, dataString: ${c.datastring}, grau: ${c.grau}, letra: ${c.letra}').toList().toString()}');

    await montarCicloJupiter(grauCalc, dataInicial: DateTime(dataNascimento!.year, dataNascimento!.month - 6, dataNascimento!.day, 0, 0, 0), dataFinal: DateTime(anoFinal!, dataNascimento!.month + 6, dataNascimento!.day, 0, 0, 0));
    //debugPrint('meu ciclo j: ${meuCicloJupiter.map((c) => 'data: ${c.data}, grau: ${c.grau}, letra: ${c.letra}').toList().toString()}');
    await refinarMeuCiclo(grauCalc, meuCicloJupiter, 'J'); 
    //debugPrint('Ciclo Refinado: ${meuCicloJupiter.map((c) => 'data: ${c.data}, dataString: ${c.datastring}, grau: ${c.grau}, letra: ${c.letra}').toList().toString()}');

    await montarCicloUrano(grauCalc, dataInicial: DateTime(dataNascimento!.year, dataNascimento!.month - 6, dataNascimento!.day, 0, 0, 0), dataFinal: DateTime(anoFinal!, dataNascimento!.month + 6, dataNascimento!.day, 0, 0, 0));
   //debugPrint('meu ciclo u: ${meuCicloUrano.map((c) => 'data: ${c.data}, grau: ${c.grau}, letra: ${c.letra}').toList().toString()}');
    await refinarMeuCiclo(grauCalc, meuCicloUrano, 'U'); 
    //debugPrint('Ciclo Refinado: ${meuCicloUrano.map((c) => 'data: ${c.data}, dataString: ${c.datastring}, grau: ${c.grau}, letra: ${c.letra}').toList().toString()}');

    await montarCicloNetuno(grauCalc, dataInicial: DateTime(dataNascimento!.year, dataNascimento!.month - 6, dataNascimento!.day, 0, 0, 0), dataFinal: DateTime(anoFinal!, dataNascimento!.month + 6, dataNascimento!.day, 0, 0, 0));
    //debugPrint('meu ciclo n: ${meuCicloNetuno.map((c) => 'data: ${c.data}, grau: ${c.grau}, letra: ${c.letra}').toList().toString()}');
    await refinarMeuCiclo(grauCalc, meuCicloNetuno, 'N'); 
    //debugPrint('Ciclo Refinado: ${meuCicloNetuno.map((c) => 'data: ${c.data}, dataString: ${c.datastring}, grau: ${c.grau}, letra: ${c.letra}').toList().toString()}');

    await montarCicloPlutao(grauCalc, dataInicial: DateTime(dataNascimento!.year - 5, dataNascimento!.month, dataNascimento!.day, 0, 0, 0), dataFinal: DateTime(anoFinal! + 5, dataNascimento!.month, dataNascimento!.day, 0, 0, 0));
    //debugPrint('meu ciclo p: ${meuCicloPlutao.map((c) => 'data: ${c.data}, grau: ${c.grau}, letra: ${c.letra}').toList().toString()}');
    await refinarMeuCiclo(grauCalc, meuCicloPlutao, 'P'); 
    //debugPrint('Ciclo Refinado: ${meuCicloPlutao.map((c) => 'data: ${c.data}, dataString: ${c.datastring}, grau: ${c.grau}, letra: ${c.letra}').toList().toString()}');

    await montarGrafico(grauCalc);
    //print('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    //print('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    //debugPrint('meu gráfico: ${meuGrafico.map((c) => 'nome: ${c.nome}, data: ${c.datastring}, x: ${c.eixo_x}, y: ${c.eixo_y}, letra: ${c.letra}').toList().toString()}');
    //print('******************************************************************************************');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaGrafico(lista: meuGrafico, usuario: nome,),
      ),
    );

    setState(() => processando = false);
  }
 
  // ===================================================================
  // ESSE METODO É O CORAÇÃO DO CICLO: ELE PEGA OS GRAUS CALCULADOS E OS 
  // GRAUS DOS PLANETAS, E MONTA A LINHA DO TEMPO DO CICLO
  // ==================================================================
  Future<void> montarCiclo(
    GrauCalculado g, {
    DateTime? dataInicial,
    DateTime? dataFinal,
  }) async {
  meuCiclo.clear();

  final grausAlvo = _montarListaGraus(g);
 // debugPrint("Graus Alvo: ${grausAlvo.toList()}");

  grausSaturno.sort((a, b) => a.data!.compareTo(b.data!));
  grausVenus.sort((a, b) => a.data!.compareTo(b.data!));
  grausMarte.sort((a, b) => a.data!.compareTo(b.data!));
  grausJupiter.sort((a, b) => a.data!.compareTo(b.data!));
  grausUrano.sort((a, b) => a.data!.compareTo(b.data!));
  grausNetuno.sort((a, b) => a.data!.compareTo(b.data!));
  grausPlutao.sort((a, b) => a.data!.compareTo(b.data!));

  // ===================================================
  // 🔥 FILTRO POR PERÍODO DE LISTA DOS GRAUS DE SATURNO
  // ===================================================
  final listaFiltradaS = grausSaturno.where((e) {
    if (e.data == null) return false;

    if (dataInicial != null && e.data!.isBefore(dataInicial)) {
      return false;
    }

    if (dataFinal != null && e.data!.isAfter(dataFinal)) {
      return false;
    }

    return true;
  }).toList();

  // ⚠️ segurança: precisa de pelo menos 2 pontos
  if (listaFiltradaS.length < 2) return;

  // ===============================================
  // 🔁 INSERE OS GRAUS E SUAS RESPECITVAS DATAS 
  // 🔁 QUANDO ELES SE ENCONTRAREM NOS GRAUS CALCULADOS 
  // ===============================================
  for (int i = 0; i < listaFiltradaS.length - 1; i++) {
    final a = listaFiltradaS[i];
    final b = listaFiltradaS[i + 1];

    final g1 = a.grau!;
    final g2 = b.grau!;

    // exato
    if (grausAlvo.contains(g1)) {
      meuCiclo.add(MeuCiclo(data: a.data!, grau: g1));
    }

    // interpolado
    for (var alvo in grausAlvo) {
      if (_cruza(g1, g2, alvo)) {
        meuCiclo.add(MeuCiclo(
          data: _interpolar(a.data!, b.data!, g1, g2, alvo),
          grau: alvo,
          nome: 'S',
        ));
      }
    }
  }



  // ===================================================
  // 🔥 FILTRO POR PERÍODO DE LISTA DOS GRAUS DE VÊNUS
  // ===================================================
  final listaFiltradaV = grausVenus.where((e) {
    if (e.data == null) return false;

    if (dataInicial != null && e.data!.isBefore(dataInicial)) {
      return false;
    }

    if (dataFinal != null && e.data!.isAfter(dataFinal)) {
      return false;
    }

    return true;
  }).toList();

  // ⚠️ segurança: precisa de pelo menos 2 pontos
  if (listaFiltradaV.length < 2) return;

  // ===============================================
  // 🔁 INSERE OS GRAUS E SUAS RESPECITVAS DATAS 
  // 🔁 QUANDO ELES SE ENCONTRAREM NOS GRAUS CALCULADOS 
  // ===============================================
  for (int i = 0; i < listaFiltradaV.length - 1; i++) {
    final a = listaFiltradaV[i];
    final b = listaFiltradaV[i + 1];

    final g1 = a.grau!;
    final g2 = b.grau!;

    // exato
    if (grausAlvo.contains(g1)) {
      meuCiclo.add(MeuCiclo(data: a.data!, grau: g1));
    }

    // interpolado
    for (var alvo in grausAlvo) {
      if (_cruza(g1, g2, alvo)) {
        meuCiclo.add(MeuCiclo(
          data: _interpolar(a.data!, b.data!, g1, g2, alvo),
          grau: alvo,
          nome: 'V',
        ));
      }
    }
  }



  // ===================================================
  // 🔥 FILTRO POR PERÍODO DE LISTA DOS GRAUS DE MARTE
  // ===================================================
  final listaFiltradaM = grausMarte.where((e) {
    if (e.data == null) return false;

    if (dataInicial != null && e.data!.isBefore(dataInicial)) {
      return false;
    }

    if (dataFinal != null && e.data!.isAfter(dataFinal)) {
      return false;
    }

    return true;
  }).toList();

  // ⚠️ segurança: precisa de pelo menos 2 pontos
  if (listaFiltradaM.length < 2) return;

  // ===============================================
  // 🔁 INSERE OS GRAUS E SUAS RESPECITVAS DATAS 
  // 🔁 QUANDO ELES SE ENCONTRAREM NOS GRAUS CALCULADOS 
  // ===============================================
  for (int i = 0; i < listaFiltradaM.length - 1; i++) {
    final a = listaFiltradaM[i];
    final b = listaFiltradaM[i + 1];

    final g1 = a.grau!;
    final g2 = b.grau!;

    // exato
    if (grausAlvo.contains(g1)) {
      meuCiclo.add(MeuCiclo(data: a.data!, grau: g1));
    }

    // interpolado
    for (var alvo in grausAlvo) {
      if (_cruza(g1, g2, alvo)) {
        meuCiclo.add(MeuCiclo(
          data: _interpolar(a.data!, b.data!, g1, g2, alvo),
          grau: alvo,
          nome: 'M',
        ));
      }
    }
  }


  // ===================================================
  // 🔥 FILTRO POR PERÍODO DE LISTA DOS GRAUS DE JUPITER
  // ===================================================
  final listaFiltradaJ = grausJupiter.where((e) {
    if (e.data == null) return false;

    if (dataInicial != null && e.data!.isBefore(dataInicial)) {
      return false;
    }

    if (dataFinal != null && e.data!.isAfter(dataFinal)) {
      return false;
    }

    return true;
  }).toList();

  // ⚠️ segurança: precisa de pelo menos 2 pontos
  if (listaFiltradaJ.length < 2) return;

  // ===============================================
  // 🔁 INSERE OS GRAUS E SUAS RESPECITVAS DATAS 
  // 🔁 QUANDO ELES SE ENCONTRAREM NOS GRAUS CALCULADOS 
  // ===============================================
  for (int i = 0; i < listaFiltradaJ.length - 1; i++) {
    final a = listaFiltradaJ[i];
    final b = listaFiltradaJ[i + 1];

    final g1 = a.grau!;
    final g2 = b.grau!;

    // exato
    if (grausAlvo.contains(g1)) {
      meuCiclo.add(MeuCiclo(data: a.data!, grau: g1));
    }

    // interpolado
    for (var alvo in grausAlvo) {
      if (_cruza(g1, g2, alvo)) {
        meuCiclo.add(MeuCiclo(
          data: _interpolar(a.data!, b.data!, g1, g2, alvo),
          grau: alvo,
          nome: 'J',
        ));
      }
    }
  }


  // ===================================================
  // 🔥 FILTRO POR PERÍODO DE LISTA DOS GRAUS DE URANO
  // ===================================================
  final listaFiltradaU = grausUrano.where((e) {
    if (e.data == null) return false;

    if (dataInicial != null && e.data!.isBefore(dataInicial)) {
      return false;
    }

    if (dataFinal != null && e.data!.isAfter(dataFinal)) {
      return false;
    }

    return true;
  }).toList();

  // ⚠️ segurança: precisa de pelo menos 2 pontos
  if (listaFiltradaU.length < 2) return;

  // ===============================================
  // 🔁 INSERE OS GRAUS E SUAS RESPECITVAS DATAS 
  // 🔁 QUANDO ELES SE ENCONTRAREM NOS GRAUS CALCULADOS 
  // ===============================================
  for (int i = 0; i < listaFiltradaU.length - 1; i++) {
    final a = listaFiltradaU[i];
    final b = listaFiltradaU[i + 1];

    final g1 = a.grau!;
    final g2 = b.grau!;

    // exato
    if (grausAlvo.contains(g1)) {
      meuCiclo.add(MeuCiclo(data: a.data!, grau: g1));
    }

    // interpolado
    for (var alvo in grausAlvo) {
      if (_cruza(g1, g2, alvo)) {
        meuCiclo.add(MeuCiclo(
          data: _interpolar(a.data!, b.data!, g1, g2, alvo),
          grau: alvo,
          nome: 'U',
        ));
      }
    }
  }



  // ===================================================
  // 🔥 FILTRO POR PERÍODO DE LISTA DOS GRAUS DE NETUNO
  // ===================================================
  final listaFiltradaN = grausNetuno.where((e) {
    if (e.data == null) return false;

    if (dataInicial != null && e.data!.isBefore(dataInicial)) {
      return false;
    }

    if (dataFinal != null && e.data!.isAfter(dataFinal)) {
      return false;
    }

    return true;
  }).toList();

  // ⚠️ segurança: precisa de pelo menos 2 pontos
  if (listaFiltradaN.length < 2) return;

  // ===============================================
  // 🔁 INSERE OS GRAUS E SUAS RESPECITVAS DATAS 
  // 🔁 QUANDO ELES SE ENCONTRAREM NOS GRAUS CALCULADOS 
  // ===============================================
  for (int i = 0; i < listaFiltradaN.length - 1; i++) {
    final a = listaFiltradaN[i];
    final b = listaFiltradaN[i + 1];

    final g1 = a.grau!;
    final g2 = b.grau!;

    // exato
    if (grausAlvo.contains(g1)) {
      meuCiclo.add(MeuCiclo(data: a.data!, grau: g1));
    }

    // interpolado
    for (var alvo in grausAlvo) {
      if (_cruza(g1, g2, alvo)) {
        meuCiclo.add(MeuCiclo(
          data: _interpolar(a.data!, b.data!, g1, g2, alvo),
          grau: alvo,
          nome: 'N',
        ));
      }
    }
  }



  // ===================================================
  // 🔥 FILTRO POR PERÍODO DE LISTA DOS GRAUS DE PLUTÃO
  // ===================================================
  final listaFiltradaP = grausPlutao.where((e) {
    if (e.data == null) return false;

    if (dataInicial != null && e.data!.isBefore(dataInicial)) {
      return false;
    }

    if (dataFinal != null && e.data!.isAfter(dataFinal)) {
      return false;
    }

    return true;
  }).toList();

  // ⚠️ segurança: precisa de pelo menos 2 pontos
  if (listaFiltradaP.length < 2) return;

  // ===============================================
  // 🔁 INSERE OS GRAUS E SUAS RESPECITVAS DATAS 
  // 🔁 QUANDO ELES SE ENCONTRAREM NOS GRAUS CALCULADOS 
  // ===============================================
  for (int i = 0; i < listaFiltradaP.length - 1; i++) {
    final a = listaFiltradaP[i];
    final b = listaFiltradaP[i + 1];

    final g1 = a.grau!;
    final g2 = b.grau!;

    // exato
    if (grausAlvo.contains(g1)) {
      meuCiclo.add(MeuCiclo(data: a.data!, grau: g1));
    }

    // interpolado
    for (var alvo in grausAlvo) {
      if (_cruza(g1, g2, alvo)) {
        meuCiclo.add(MeuCiclo(
          data: _interpolar(a.data!, b.data!, g1, g2, alvo),
          grau: alvo,
          nome: 'P',
        ));
      }
    }
  }




  // ==============================
  // FILTRO FINAL (JÁ EXISTENTE)
  // ==============================
  meuCiclo = _filtrarUltimosPorPeriodo(meuCiclo, meses: 11);
}

  Future<void> montarCicloSaturno(
  GrauCalculado g, {
  DateTime? dataInicial,
  DateTime? dataFinal,
}) async {
  meuCicloSaturno.clear();

  final grausAlvo = _montarListaGraus(g);
 // debugPrint("Graus Alvo: ${grausAlvo.toList()}");

  grausSaturno.sort((a, b) => a.data!.compareTo(b.data!));

  // ===================================================
  // 🔥 FILTRO POR PERÍODO DE LISTA DOS GRAUS DE SATURNO
  // ===================================================
  final listaFiltrada = grausSaturno.where((e) {
    if (e.data == null) return false;

    if (dataInicial != null && e.data!.isBefore(dataInicial)) {
      return false;
    }

    if (dataFinal != null && e.data!.isAfter(dataFinal)) {
      return false;
    }

    return true;
  }).toList();

  // ⚠️ segurança: precisa de pelo menos 2 pontos
  if (listaFiltrada.length < 2) return;

  // ===============================================
  // 🔁 INSERE OS GRAUS E SUAS RESPECITVAS DATAS 
  // 🔁 QUANDO ELES SE ENCONTRAREM NOS GRAUS CALCULADOS 
  // ===============================================
  for (int i = 0; i < listaFiltrada.length - 1; i++) {
    final a = listaFiltrada[i];
    final b = listaFiltrada[i + 1];

    final g1 = a.grau!;
    final g2 = b.grau!;

    // exato
    if (grausAlvo.contains(g1)) {
      meuCicloSaturno.add(MeuCiclo(data: a.data!, grau: g1, nome: 'S'));
    }

    // interpolado
    for (var alvo in grausAlvo) {
      if (_cruza(g1, g2, alvo)) {
        meuCicloSaturno.add(MeuCiclo(
          data: _interpolar(a.data!, b.data!, g1, g2, alvo),
          grau: alvo,
          nome: 'S',
        ));
      }
    }
  }



  // ==============================
  // FILTRO FINAL (JÁ EXISTENTE)
  // ==============================
  meuCicloSaturno = _filtrarUltimosPorPeriodo(meuCicloSaturno, meses: 11);//11
}

  Future<void> montarCicloVenus(
  GrauCalculado g, {
  DateTime? dataInicial,
  DateTime? dataFinal,
}) async {
  meuCicloVenus.clear();

  final grausAlvo = _montarListaGraus(g);
 // debugPrint("Graus Alvo: ${grausAlvo.toList()}");

  grausVenus.sort((a, b) => a.data!.compareTo(b.data!));

  // ===================================================
  // 🔥 FILTRO POR PERÍODO DE LISTA DOS GRAUS DE VENUS
  // ===================================================
  final listaFiltrada = grausVenus.where((e) {
    if (e.data == null) return false;

    if (dataInicial != null && e.data!.isBefore(dataInicial)) {
      return false;
    }

    if (dataFinal != null && e.data!.isAfter(dataFinal)) {
      return false;
    }

    return true;
  }).toList();

  // ⚠️ segurança: precisa de pelo menos 2 pontos
  if (listaFiltrada.length < 2) return;

  // ===============================================
  // 🔁 INSERE OS GRAUS E SUAS RESPECITVAS DATAS 
  // 🔁 QUANDO ELES SE ENCONTRAREM NOS GRAUS CALCULADOS 
  // ===============================================
  for (int i = 0; i < listaFiltrada.length - 1; i++) {
    final a = listaFiltrada[i];
    final b = listaFiltrada[i + 1];

    final g1 = a.grau!;
    final g2 = b.grau!;

    // exato
    if (grausAlvo.contains(g1)) {
      meuCicloVenus.add(MeuCiclo(data: a.data!, grau: g1, nome: 'V'));
    }

    // interpolado
    for (var alvo in grausAlvo) {
      if (_cruza(g1, g2, alvo)) {
        meuCicloVenus.add(MeuCiclo(
          data: _interpolar(a.data!, b.data!, g1, g2, alvo),
          grau: alvo,
          nome: 'V',
        ));
      }
    }
  }



  // ==============================
  // FILTRO FINAL (JÁ EXISTENTE)
  // ==============================
  meuCicloVenus = _filtrarUltimosPorPeriodo(meuCicloVenus, meses: 6);
}

  Future<void> montarCicloMarte(
  GrauCalculado g, {
  DateTime? dataInicial,
  DateTime? dataFinal,
}) async {
  meuCicloMarte.clear();

  final grausAlvo = _montarListaGraus(g);
 // debugPrint("Graus Alvo: ${grausAlvo.toList()}");

  grausMarte.sort((a, b) => a.data!.compareTo(b.data!));

  // ===================================================
  // 🔥 FILTRO POR PERÍODO DE LISTA DOS GRAUS DE MARTE
  // ===================================================
  final listaFiltrada = grausMarte.where((e) {
    if (e.data == null) return false;

    if (dataInicial != null && e.data!.isBefore(dataInicial)) {
      return false;
    }

    if (dataFinal != null && e.data!.isAfter(dataFinal)) {
      return false;
    }

    return true;
  }).toList();

  // ⚠️ segurança: precisa de pelo menos 2 pontos
  if (listaFiltrada.length < 2) return;

  // ===============================================
  // 🔁 INSERE OS GRAUS E SUAS RESPECITVAS DATAS 
  // 🔁 QUANDO ELES SE ENCONTRAREM NOS GRAUS CALCULADOS 
  // ===============================================
  for (int i = 0; i < listaFiltrada.length - 1; i++) {
    final a = listaFiltrada[i];
    final b = listaFiltrada[i + 1];

    final g1 = a.grau!;
    final g2 = b.grau!;

    // exato
    if (grausAlvo.contains(g1)) {
      meuCicloMarte.add(MeuCiclo(data: a.data!, grau: g1, nome: 'M'));
    }

    // interpolado
    for (var alvo in grausAlvo) {
      if (_cruza(g1, g2, alvo)) {
        meuCicloMarte.add(MeuCiclo(
          data: _interpolar(a.data!, b.data!, g1, g2, alvo),
          grau: alvo,
          nome: 'M',
        ));
      }
    }
  }


  // ==============================
  // FILTRO FINAL 
  // ==============================
  meuCicloMarte = _filtrarUltimosPorPeriodo(meuCicloMarte, meses: 11);//11
}

  Future<void> montarCicloJupiter(
  GrauCalculado g, {
  DateTime? dataInicial,
  DateTime? dataFinal,
}) async {
  meuCicloJupiter.clear();

  final grausAlvo = _montarListaGraus(g);
 // debugPrint("Graus Alvo: ${grausAlvo.toList()}");

  grausJupiter.sort((a, b) => a.data!.compareTo(b.data!));

  // ===================================================
  // 🔥 FILTRO POR PERÍODO DE LISTA DOS GRAUS DE JUPITER
  // ===================================================
  final listaFiltrada = grausJupiter.where((e) {
    if (e.data == null) return false;

    if (dataInicial != null && e.data!.isBefore(dataInicial)) {
      return false;
    }

    if (dataFinal != null && e.data!.isAfter(dataFinal)) {
      return false;
    }

    return true;
  }).toList();

  // ⚠️ segurança: precisa de pelo menos 2 pontos
  if (listaFiltrada.length < 2) return;

  // ===============================================
  // 🔁 INSERE OS GRAUS E SUAS RESPECITVAS DATAS 
  // 🔁 QUANDO ELES SE ENCONTRAREM NOS GRAUS CALCULADOS 
  // ===============================================
  for (int i = 0; i < listaFiltrada.length - 1; i++) {
    final a = listaFiltrada[i];
    final b = listaFiltrada[i + 1];

    final g1 = a.grau!;
    final g2 = b.grau!;

    // exato
    if (grausAlvo.contains(g1)) {
      meuCicloJupiter.add(MeuCiclo(data: a.data!, grau: g1, nome: 'J'));
    }

    // interpolado
    for (var alvo in grausAlvo) {
      if (_cruza(g1, g2, alvo)) {
        meuCicloJupiter.add(MeuCiclo(
          data: _interpolar(a.data!, b.data!, g1, g2, alvo),
          grau: alvo,
          nome: 'J',
        ));
      }
    }
  }


  // ==============================
  // FILTRO FINAL 
  // ==============================
  meuCicloJupiter = _filtrarUltimosPorPeriodo(meuCicloJupiter, meses: 12);
}

  Future<void> montarCicloUrano(
  GrauCalculado g, {
  DateTime? dataInicial,
  DateTime? dataFinal,
}) async {
  meuCicloUrano.clear();

  final grausAlvo = _montarListaGraus(g);
 // debugPrint("Graus Alvo: ${grausAlvo.toList()}");

  grausUrano.sort((a, b) => a.data!.compareTo(b.data!));

  // ===================================================
  // 🔥 FILTRO POR PERÍODO DE LISTA DOS GRAUS DE URANO
  // ===================================================
  final listaFiltrada = grausUrano.where((e) {
    if (e.data == null) return false;

    if (dataInicial != null && e.data!.isBefore(dataInicial)) {
      return false;
    }

    if (dataFinal != null && e.data!.isAfter(dataFinal)) {
      return false;
    }

    return true;
  }).toList();

  // ⚠️ segurança: precisa de pelo menos 2 pontos
  if (listaFiltrada.length < 2) return;

  // ===============================================
  // 🔁 INSERE OS GRAUS E SUAS RESPECITVAS DATAS 
  // 🔁 QUANDO ELES SE ENCONTRAREM NOS GRAUS CALCULADOS 
  // ===============================================
  for (int i = 0; i < listaFiltrada.length - 1; i++) {
    final a = listaFiltrada[i];
    final b = listaFiltrada[i + 1];

    final g1 = a.grau!;
    final g2 = b.grau!;

    // exato
    if (grausAlvo.contains(g1)) {
      meuCicloUrano.add(MeuCiclo(data: a.data!, grau: g1, nome: 'U'));
    }

    // interpolado
    for (var alvo in grausAlvo) {
      if (_cruza(g1, g2, alvo)) {
        meuCicloUrano.add(MeuCiclo(
          data: _interpolar(a.data!, b.data!, g1, g2, alvo),
          grau: alvo,
          nome: 'U',
        ));
      }
    }
  }


  // ==============================
  // FILTRO FINAL 
  // ==============================
  meuCicloUrano = _filtrarUltimosPorPeriodo(meuCicloUrano, meses: 120);
}

  Future<void> montarCicloNetuno(
  GrauCalculado g, {
  DateTime? dataInicial,
  DateTime? dataFinal,
}) async {
  meuCicloNetuno.clear();

  final grausAlvo = _montarListaGraus(g);
 // debugPrint("Graus Alvo: ${grausAlvo.toList()}");

  grausNetuno.sort((a, b) => a.data!.compareTo(b.data!));

  // ===================================================
  // 🔥 FILTRO POR PERÍODO DE LISTA DOS GRAUS DE NETUNO
  // ===================================================
  final listaFiltrada = grausNetuno.where((e) {
    if (e.data == null) return false;

    if (dataInicial != null && e.data!.isBefore(dataInicial)) {
      return false;
    }

    if (dataFinal != null && e.data!.isAfter(dataFinal)) {
      return false;
    }

    return true;
  }).toList();

  // ⚠️ segurança: precisa de pelo menos 2 pontos
  if (listaFiltrada.length < 2) return;

  // ===============================================
  // 🔁 INSERE OS GRAUS E SUAS RESPECITVAS DATAS 
  // 🔁 QUANDO ELES SE ENCONTRAREM NOS GRAUS CALCULADOS 
  // ===============================================
  for (int i = 0; i < listaFiltrada.length - 1; i++) {
    final a = listaFiltrada[i];
    final b = listaFiltrada[i + 1];

    final g1 = a.grau!;
    final g2 = b.grau!;

    // exato
    if (grausAlvo.contains(g1)) {
      meuCicloNetuno.add(MeuCiclo(data: a.data!, grau: g1, nome: 'N'));
    }

    // interpolado
    for (var alvo in grausAlvo) {
      if (_cruza(g1, g2, alvo)) {
        meuCicloNetuno.add(MeuCiclo(
          data: _interpolar(a.data!, b.data!, g1, g2, alvo),
          grau: alvo,
          nome: 'N',
        ));
      }
    }
  }


  // ==============================
  // FILTRO FINAL 
  // ==============================
  meuCicloNetuno = _filtrarUltimosPorPeriodo(meuCicloNetuno, meses: 120);
}

  Future<void> montarCicloPlutao(
  GrauCalculado g, {
  DateTime? dataInicial,
  DateTime? dataFinal,
}) async {
  meuCicloPlutao.clear();

  final grausAlvo = _montarListaGraus(g);
 // debugPrint("Graus Alvo: ${grausAlvo.toList()}");

  grausPlutao.sort((a, b) => a.data!.compareTo(b.data!));

  // ===================================================
  // 🔥 FILTRO POR PERÍODO DE LISTA DOS GRAUS DE PLUTÃO
  // ===================================================
  final listaFiltrada = grausPlutao.where((e) {
    if (e.data == null) return false;

    if (dataInicial != null && e.data!.isBefore(dataInicial)) {
      return false;
    }

    if (dataFinal != null && e.data!.isAfter(dataFinal)) {
      return false;
    }

    return true;
  }).toList();

  // ⚠️ segurança: precisa de pelo menos 2 pontos
  if (listaFiltrada.length < 2) return;

  // ===============================================
  // 🔁 INSERE OS GRAUS E SUAS RESPECITVAS DATAS 
  // 🔁 QUANDO ELES SE ENCONTRAREM NOS GRAUS CALCULADOS 
  // ===============================================
  for (int i = 0; i < listaFiltrada.length - 1; i++) {
    final a = listaFiltrada[i];
    final b = listaFiltrada[i + 1];

    final g1 = a.grau!;
    final g2 = b.grau!;

    // exato
    if (grausAlvo.contains(g1)) {
      meuCicloPlutao.add(MeuCiclo(data: a.data!, grau: g1, nome: 'P'));
    }

    // interpolado
    for (var alvo in grausAlvo) {
      if (_cruza(g1, g2, alvo)) {
        meuCicloPlutao.add(MeuCiclo(
          data: _interpolar(a.data!, b.data!, g1, g2, alvo),
          grau: alvo,
          nome: 'P',
        ));
      }
    }
  }


  // ==============================
  // FILTRO FINAL 
  // ==============================
  meuCicloPlutao = _filtrarUltimosPorPeriodo(meuCicloPlutao, meses: 240);
}

  Future<void> montarGrafico(GrauCalculado g) async {
    meuGrafico.clear();

    final listas = [
      meuCicloSaturno,
      meuCicloVenus,
      meuCicloMarte,
      meuCicloJupiter,
      meuCicloUrano,
      meuCicloNetuno,
      meuCicloPlutao,
    ];

    for (var lista in listas) {
      if (lista.isEmpty) continue;

      final linha = await _montarLinhaGrafico(lista, g);

      meuGrafico.addAll(linha);
    }


    //debugPrint("Dados para o gráfico: ${meuGrafico.map((e) => "(${e.letra}, ${e.eixo_x}, ${e.eixo_y}, ${e.datastring}, ${e.nome})").toList()}");
  }

/*
  Future<void> montarGrafico(
  GrauCalculado g) async {

  meuGrafico.clear();
 
    /*
    Letra Solar (S)|Fase quando Homem|Fase quando Mulher|Letra INI-FIN|eixo x,y (H)|eixo x,y (M)|
    ---------------|-----------------|------------------|-------------|------------|------------|
    Sobre A        |        1        |         3        |    E - E    |  a,    0   |   a,    0  |
    Entre A e B    |        1-2      |         3-4      |    E - E    |  a+1, -1   |   a+1,  1  |
    Sobre B        |        2        |         4        |    E - E    |  a+2, -2   |   a+2,  2  |
    Entre B e C    |        2-3      |         4-1      |    G - G    |  a+3, -1   |   a+3,  1  |
    Sobre C        |        3        |         1        |    G - G    |  a+4,  0   |   a+4,  0  |
    Entre C e D    |        3-4      |         1-2      |    G - G    |  a+5,  1   |   a+5, -1  |
    Sobre D        |        4        |         2        |    G - G    |  a+6,  2   |   a+6, -2  |
    Entre D e E    |        4-1      |         2-3      |    A - A    |  a+7,  1   |   a+7, -1  |
    Sobre E        |        1        |         3        |    A - A    |  a+8,  0   |   a+8,  0  |
    Entre E e F    |        1-2      |         3-4      |    A - A    |  a+9, -1   |   a+9,  1  |
    Sobre F        |        2        |         4        |    A - A    |  a+10, -2  |   a+10, 2  |
    Entre F e G    |        2-3      |         4-1      |    C - C    |  a+11, -1  |   a+11, 1  |
    Sobre G        |        3        |         1        |    C - C    |  a+12,  0  |   a+12, 0  |
    Entre G e H    |        3-4      |         1-2      |    C - C    |  a+13,  1  |   a+13,-1  |
    Sobre H        |        4        |         2        |    C - C    |  a+14,  2  |   a+14,-2  |
    Entre H e A    |        4-1      |         2-3      |    E - E    |  a+15,  1  |   a+15,-1  |
    */


    // ========================================
    // 🔁 MONTA DADOS DO GRAFICO LINHA SATURNO
    // ========================================
    String faseAtual = '';
    int x = 0;
    int y = 0;
    String letra = '';
    String nome = '';

    for (int i = 0; i < meuCicloSaturno.length - 1; i++) {

      faseAtual = await obterFase(g, int.tryParse(meuCicloSaturno[i].grau!.toString())!);
      nome = meuCicloSaturno[i].nome ?? '';
      if(faseAtual == 'A'){
        if(i==0){
         x = 0;
        }else{x = x + 1;}
        y = 0;
        letra = 'E';       
      }else
      if(faseAtual == 'AB'){
        if(i==0){
         x = 0;
        }else{x = x + 1;}
        y = -1;
        letra = 'E';       
      }else
      if(faseAtual == 'B'){
        if(i==0){
         x = 0;
        }else{x = x + 1;}
        y = -2;
        letra = 'E';       
      }else
      if(faseAtual == 'BC'){
        if(i==0){
         x = 0;
        }else{x = x + 1;}
        y = -1;
        letra = 'G';       
      }else
      if(faseAtual == 'C'){
        if(i==0){
         x = 0;
        }else{x = x + 1;}
        y = 0;
        letra = 'G';       
      }else
      if(faseAtual == 'CD'){
        if(i==0){
         x = 0;
        }else{x = x + 1;}
        y = 1;
        letra = 'G';       
      }else
      if(faseAtual == 'D'){
        if(i==0){
         x = 0;
        }else{x = x + 1;}
        y = 2;
        letra = 'G';       
      }else
      if(faseAtual == 'DE'){
        if(i==0){
         x = 0;
        }else{x = x + 1;}
        y = 1;
        letra = 'A';       
      }else
      if(faseAtual == 'E'){
        if(i==0){
         x = 0;
        }else{x = x + 1;}
        y = 0;
        letra = 'A';       
      }else
      if(faseAtual == 'EF'){
        if(i==0){
         x = 0;
        }else{x = x + 1;}
        y = -1;
        letra = 'A';       
      }else
      if(faseAtual == 'F'){
        if(i==0){
         x = 0;
        }else{x = x + 1;}
        y = -2;
        letra = 'A';       
      }else
      if(faseAtual == 'FG'){
        if(i==0){
         x = 0;
        }else{x = x + 1;}
        y = -1;
        letra = 'C';       
      }else
      if(faseAtual == 'G'){
        if(i==0){
         x = 0;
        }else{x = x + 1;}
        y = 0;
        letra = 'C';       
      }else
      if(faseAtual == 'GH'){
        if(i==0){
         x = 0;
        }else{x = x + 1;}
        y = 1;
        letra = 'C';       
      }else
      if(faseAtual == 'H'){
        if(i==0){
         x = 0;
        }else{x = x + 1;}
        y = 2;
        letra = 'C';       
      }else
      if(faseAtual == 'HA'){
        if(i==0){
         x = 0;
        }else{x = x + 1;}
        y = 1;
        letra = 'E';       
      }


      meuGrafico.add(MeuGrafico(
        eixo_x: x,
        eixo_y: y,
        datastring: meuCicloSaturno[i].data.toString(),
        letra: faseAtual,
        nome: nome,
      ));


    }

 
}
*/

  // ==============================
  // ESSE METODO PEGA OS GRAUS CALCULADOS E RETORNA OS GRAUS PRINCIPAIS  E SEUS RESPECTIVOS GRAUS ANTERIORES E POSTERIORES (A - 5, A, A + 5, B- 5, B, B + 5, ...)
  // ==============================
  Set<int> _montarListaGraus(GrauCalculado g) {
    final lista = [
      g.grau_a, g.grau_b, g.grau_c, g.grau_d,
      g.grau_e, g.grau_f, 
      g.grau_g, g.grau_h,
    ];
//g.grau_x1, g.grau_x2,
    final result = <int>{};

    for (var v in lista) {
      result.addAll([
        _norm(v! - 5),
        _norm(v),
        _norm(v + 5),
      ]);
    }

    return result;
  }

  bool _cruza(int g1, int g2, int alvo) {
    if ((g1 - g2).abs() > 300) {
      if (g1 > g2) g2 += 360;
      else g1 += 360;

      if (alvo < 50) alvo += 360;
    }

    return (alvo > min(g1, g2) && alvo < max(g1, g2));
  }

  DateTime _interpolar(DateTime d1, DateTime d2, int g1, int g2, int alvo) {
    final total = (g2 - g1).abs();
    final parcial = (alvo - g1).abs();

    final fator = total == 0 ? 0 : parcial / total;
    final diff = d2.difference(d1).inMilliseconds;

    return d1.add(Duration(milliseconds: (diff * fator).round()));
  }

  List<MeuCiclo> _filtrarUltimosPorPeriodo(List<MeuCiclo> lista, {required int meses}) {
    lista.sort((a, b) => a.data!.compareTo(b.data!));

    final Map<int, List<MeuCiclo>> map = {};

    for (var e in lista) {
      map.putIfAbsent(e.grau!, () => []).add(e);
    }

    final result = <MeuCiclo>[];

    map.forEach((grau, eventos) {
      DateTime? inicio;
      MeuCiclo? ultimo;

      for (var e in eventos) {
        if (inicio == null) {
          inicio = e.data;
          ultimo = e;
          continue;
        }

        final diff = (e.data!.year - inicio.year) * 12 + (e.data!.month - inicio.month);

        if (diff <= meses) {
          ultimo = e;
        } else {
          result.add(ultimo!);
          inicio = e.data;
          ultimo = e;
        }
      }

      if (ultimo != null) result.add(ultimo);
    });

    return result..sort((a, b) => a.data!.compareTo(b.data!));
  }

  // =============================
  // FASE AUTOMÁTICA
  // =============================
  String fase(int grau, GrauCalculado g) {
    Map<String, int> mapa = {
      "A": g.grau_a!,
      "B": g.grau_b!,
      "C": g.grau_c!,
      "D": g.grau_d!,
      "E": g.grau_e!,
      "F": g.grau_f!,
      "X1": g.grau_x1!,
      "X2": g.grau_x2!,
      "G": g.grau_g!,
      "H": g.grau_h!,
    };

    for (var k in mapa.keys) {
      if (grau == _norm(mapa[k]!)) return k;
      if (grau == _norm(mapa[k]! - 5)) return "$k-5";
      if (grau == _norm(mapa[k]! + 5)) return "$k+5";
    }

    return "";
  }

  // =============================
  // PDF
  // =============================
  Future<void> gerarPDF(GrauCalculado gc) async {
    setState(() => processando = true);
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Text("Mapa de Ciclo",
                  style: pw.TextStyle(fontSize: 20)),

              pw.SizedBox(height: 20),

              ...meuCiclo.map((e) {
                final fase = getFase(e.grau!, gc);

                return pw.Container(
                  margin: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(fase),
                      pw.Text("${e.grau}"),
                      pw.Text(
                          "${e.data!.day}/${e.data!.month}/${e.data!.year}"),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );

    setState(() => processando = false);
  }

  // =============================
  // BUILD
  // =============================
  @override
  Widget build(BuildContext context) {

    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(

      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        title: const Text("Gerar Mapa"),
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

                  
                  const Icon(
                    Icons.loop,
                    size: 80,
                    color: Colors.cyan,
                  ),
                  

                  const SizedBox(height: 16),

                  // ================= TÍTULO =================
                  const Text(
                    "Gerar meu Mapa",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // =========================
                  // DADOS USUÁRIO
                  // =========================
                  const Text(
                    "Minhas Informações",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _field("Nome", nome),
                  const SizedBox(height: 10),
                  _field("Sexo", sexo),
                  const SizedBox(height: 10),
                  _field(
                    "Data Nascimento",
                    dataNascimento != null
                        ? "${dataNascimento!.day}/${dataNascimento!.month}/${dataNascimento!.year}"
                        : "",
                  ),

                  const SizedBox(height: 24),

                  // =========================
                  // CONSULTA
                  // =========================
                  const Text(
                    "Período",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<int>(
                    initialValue: anoInicial,
                    decoration: _input("Ano Inicial", Icons.lock),
                    items: anos
                        .map((ano) => DropdownMenuItem(
                              value: ano,
                              child: Text("$ano"),
                            ))
                        .toList(),
                    //onChanged: null, deixa e componente desabilitado
                    onChanged:  (value) {
                      setState(() {
                        anoInicial = value;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<int>(
                    initialValue: anoFinal,
                    decoration: _input("Ano Final", Icons.calendar_today),
                    items: anos
                        .map((ano) => DropdownMenuItem(
                              value: ano,
                              child: Text("$ano"),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        anoFinal = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // BOTÕES
                  // =========================
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: processando ? null : consultar,
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: processando
                          ? const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text("Processando..."),
                              ],
                            )
                          : const Text("Consultar"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // =========================
                  // TIMELINE
                  // =========================
                  if (meuCiclo.isNotEmpty) ...[
                    const Text(
                      "Linha do Tempo",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: meuCiclo.length,
                        itemBuilder: (_, i) {
                          final e = meuCiclo[i];

                          return Card(
                            color: Colors.grey[900],
                            child: ListTile(
                              leading: const Icon(
                                Icons.timeline,
                                color: Colors.blue,
                              ),
                              title: Text(
                                "Grau ${e.grau}",
                                style: const TextStyle(
                                    color: Colors.white),
                              ),
                              subtitle: Text(
                                "${e.data!.day}/${e.data!.month}/${e.data!.year}",
                                style: const TextStyle(
                                    color: Colors.white70),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],

                  // =========================
                  // GRÁFICO (placeholder)
                  // =========================
                  if (meuCiclo.isNotEmpty) ...[
                    const Text(
                      "Gráfico",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "Gráfico aqui",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                  ],

              
                ],

              ),

            ),

          ),

        ),

      ),


    );



  }

  // =============================
  // SERVICES (mantidos)
  // =============================
  Future<int> buscarGrauPermanente({int? dia, int? mes}) async {
    final data = await GrauPermanenteService.getGrausPermanentes(dia: dia, mes: mes);
    return data.isEmpty ? 0 : data.first.grau ?? 0;
  }

  Future<GrauCalculado> buscarGrauCalculado({String? grau_a}) async {
    final data = await GrauCalculadoService.getGrausCalculados(grau_a: grau_a);
    return data.isEmpty ? GrauCalculado(
      grau_a: 0, grau_b: 0, grau_c: 0, grau_x1: 0,
      grau_d: 0, grau_e: 0, grau_f: 0, grau_x2: 0,
      grau_g: 0, grau_h: 0,
    ) : data.first;
  }

  // ==============================
  // FIELD GRAUS DOS PLANETAS
  // ==============================
  Future<List<GrauPlaneta>> buscarGrausSaturno({String? codciclo}) async {
    return await GrauPlanetaService.getGrausPlanetas(codciclo: codciclo);
  }

  Future<List<GrauPlaneta>> buscarGrausVenus({String? codciclo}) async {
    return await GrauPlanetaService.getGrausPlanetas(codciclo: codciclo);
  }

  Future<List<GrauPlaneta>> buscarGrausMarte({String? codciclo}) async {
    return await GrauPlanetaService.getGrausPlanetas(codciclo: codciclo);
  }

  Future<List<GrauPlaneta>> buscarGrausJupiter({String? codciclo}) async {
    return await GrauPlanetaService.getGrausPlanetas(codciclo: codciclo);
  }

  Future<List<GrauPlaneta>> buscarGrausUrano({String? codciclo}) async {
    return await GrauPlanetaService.getGrausPlanetas(codciclo: codciclo);
  }

  Future<List<GrauPlaneta>> buscarGrausNetuno({String? codciclo}) async {
    return await GrauPlanetaService.getGrausPlanetas(codciclo: codciclo);
  }

  Future<List<GrauPlaneta>> buscarGrausPlutao({String? codciclo}) async {
    return await GrauPlanetaService.getGrausPlanetas(codciclo: codciclo);
  }

  // ==============================
  // FIELD VISUAL (DESABILITADO)
  // ==============================
  Widget _field(String label, String value) {
    return TextField(
      enabled: false,
      controller: TextEditingController(text: value),
      decoration: _input(label, Icons.lock),
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

  Widget buildGrafico() {
    final spots = <FlSpot>[];

    for (int i = 0; i < meuCiclo.length; i++) {
      spots.add(FlSpot(i.toDouble(), meuCiclo[i].grau!.toDouble()));
    }

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  String getFase(int grau, GrauCalculado gc) {
    final mapa = {
      "A": gc.grau_a,
      "B": gc.grau_b,
      "C": gc.grau_c,
      "X1": gc.grau_x1,
      "D": gc.grau_d,
      "E": gc.grau_e,
      "F": gc.grau_f,
      "X2": gc.grau_x2,
      "G": gc.grau_g,
      "H": gc.grau_h,
    };

    for (var entry in mapa.entries) {
      final base = entry.value;

      if (grau == base) return entry.key;
      if (grau == _wrap(base! - 5)) return "${entry.key}-5";
      if (grau == _wrap(base + 5)) return "${entry.key}+5";
    }

    return "";
  }

  int _wrap(int grau) {
    if (grau <= 0) return 360 + grau;
    if (grau > 360) return grau - 360;
    return grau;
  }

  Widget buildTimeline(GrauCalculado gc) {
    return ListView.builder(
      itemCount: meuCiclo.length,
      itemBuilder: (_, i) {
        final e = meuCiclo[i];
        final fase = getFase(e.grau!, gc);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueAccent),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fase,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${e.grau}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "${e.data!.day}/${e.data!.month}/${e.data!.year}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  DateTime adicionarMeses(DateTime data, int meses) {
    int novoMes = data.month + meses;
    int novoAno = data.year + ((novoMes - 1) ~/ 12);
    novoMes = ((novoMes - 1) % 12) + 1;

    int ultimoDiaDoMes = DateTime(novoAno, novoMes + 1, 0).day;

    int novoDia = data.day > ultimoDiaDoMes
        ? ultimoDiaDoMes
        : data.day;

    return DateTime(novoAno, novoMes, novoDia);
  }

  DateTime adicionarAnos(DateTime data, int anos) {
    return DateTime(
      data.year + anos,
      data.month,
      data.day,
    );
  }

  Future<String> obterFase(GrauCalculado g, int grau) async {
    // Lista ordenada na sequência do ciclo
    final lista = [
      {'letra': 'A', 'valor': g.grau_a},
      {'letra': 'B', 'valor': g.grau_b},
      {'letra': 'C', 'valor': g.grau_c},
      {'letra': 'D', 'valor': g.grau_d},
      {'letra': 'E', 'valor': g.grau_e},
      {'letra': 'F', 'valor': g.grau_f},
     // {'letra': 'X2', 'valor': g.grau_x2},
      {'letra': 'G', 'valor': g.grau_g},
      {'letra': 'H', 'valor': g.grau_h},
    ];

    for (int i = 0; i < lista.length; i++) {
      final atual = lista[i];
      final proximo = lista[(i + 1) % lista.length];

      final int gAtual = atual['valor'] as int;
      final int gProx = proximo['valor'] as int;

      // ✅ Caso EXATO
      if (grau == gAtual) {
        return atual['letra'] as String;
      }

      // ============================
      // 🔥 INTERVALO NORMAL
      // ============================
      if (gAtual < gProx) {
        if (grau > gAtual && grau < gProx) {
          return "${atual['letra']}${proximo['letra']}";
        }
      }
      // ============================
      // 🔥 INTERVALO COM VIRADA (360°)
      // ============================
      else {
        if (grau > gAtual || grau < gProx) {
          return "${atual['letra']}${proximo['letra']}";
        }
      }
    }

    return '';
  }

  Future<void> refinarMeuCiclo(GrauCalculado g, List<MeuCiclo> ciclo, String planeta) async {
    final principais = [
      g.grau_a,
      g.grau_b,
      g.grau_c,
      g.grau_d,
      g.grau_e,
      g.grau_f,
      g.grau_x1,
      g.grau_x2,
      g.grau_g,
      g.grau_h,
    ];

    List<MeuCiclo> resultado = [];
    List<MeuCiclo> resultadoFinal = [];

    for (int i = 0; i < ciclo.length; i++) {
      final atual = ciclo[i];

      if (atual.grau == null || atual.data == null) continue;

      final grau = atual.grau!;

      // 👉 só processa se for grau principal
      if (!principais.contains(grau)) continue; 

      String? dataAnterior;
      String dataPrincipal = _formatDataBR(atual.data!); 
      String? dataPosterior;
      DateTime dataAnteriorCiclo = DateTime(anoInicial!, dataNascimento!.month, dataNascimento!.day);
      DateTime dataPosteriorCiclo = DateTime(anoInicial!, dataNascimento!.month, dataNascimento!.day);

      // =========================
      // 🔵 BUSCA ANTERIOR (-5)
      // =========================
      if (i > 0) {
        final prev = ciclo[i - 1];

        if (prev.grau != null &&
            ((prev.grau! + 5) % 360 == grau) &&
            prev.data != null) {
                 dataAnterior = _formatDataBR(prev.data!);
                 dataAnteriorCiclo = prev.data!;
           }

      }

      // =========================
      // 🟢 BUSCA POSTERIOR (+5)
      // =========================
      if (i < ciclo.length - 1) {
        final next = ciclo[i + 1];

        if (next.grau != null &&
            ((next.grau! - 5 + 360) % 360 == grau) &&
            next.data != null) {

          dataPosterior = _formatDataBR(next.data!);
          dataPosteriorCiclo = next.data!;
        }
      }

      // =========================
      // 🧩 MONTA STRING FINAL
      // =========================
      String datas = "";

      if (dataAnterior != "") {
        datas += "$dataAnterior → ";
      }

      datas += dataPrincipal;

      if (dataPosterior != "") {
        datas += " → $dataPosterior";
      }

      resultado.add(MeuCiclo(
        nome: planeta,
        data: atual.data!,
        data_0: dataAnteriorCiclo,
        data_1: dataPosteriorCiclo,
        grau: grau,
      )..datastring = datas);
    }

    DateTime dataComparacaoAnterior = DateTime.now();

    for (int i = 0; i < resultado.length; i++) {
      String? dataAnteriorFinal = "";
      String dataPrincipalFinal = ""; 
      String? dataPosteriorFinal = "";
      DateTime? dataPrincipalCicloFinal =  resultado[i].data!;

      /*Verificação das datas do primeiro grau se está igual a data inicial do intervalo para não apresentar diferença no gráfico*/
      if(i == 0){
        String datasFinal = "";
        
        /*Situacao em que a data principal é menor que a data inicial do intervalo*/
        if(resultado[i].data!.isBefore(DateTime(anoInicial!, dataNascimento!.month, 1))){

          /*Se data principal é menor que a data inicial do intervalo E a data posterior também é menor que data inicial do intervalo*/
          if(resultado[i].data_1!.isBefore(DateTime(anoInicial!, dataNascimento!.month, 1))){
            dataAnteriorFinal = "";
            dataPrincipalFinal = "";
            dataPosteriorFinal = _formatDataBR(DateTime(anoInicial!, dataNascimento!.month, 1));
            dataPrincipalCicloFinal = DateTime(anoInicial!, dataNascimento!.month, 1);

            datasFinal = " → $dataPosteriorFinal";

          }else
          /*Se data principal é menor que a data inicial do intervalo E a data posterior é maior que data inicial do intervalo*/
          if((resultado[i].data_1!.isAfter(DateTime(anoInicial!, dataNascimento!.month, 1)))){
            /*verificar quem está mais próximo da data inicial do intervalo*/
              if ((resultado[i].data_1!
                      .difference(DateTime(anoInicial!, dataNascimento!.month, 1))
                      .inDays) >=
                  (DateTime(anoInicial!, dataNascimento!.month, 1)
                      .difference(resultado[i].data!)
                      .inDays)) 
              {
                  dataAnteriorFinal = "";
                  dataPrincipalFinal = _formatDataBR(DateTime(anoInicial!, dataNascimento!.month, 1));
                  dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
                  dataPrincipalCicloFinal = DateTime(anoInicial!, dataNascimento!.month, 1);

                  datasFinal = "$dataPrincipalFinal → $dataPosteriorFinal";
              }else{
                  dataAnteriorFinal = "";
                  dataPrincipalFinal = "";
                  dataPosteriorFinal = _formatDataBR(DateTime(anoInicial!, dataNascimento!.month, 1));
                  dataPrincipalCicloFinal = DateTime(anoInicial!, dataNascimento!.month, 1);

                  datasFinal = " → $dataPosteriorFinal";
              }

          }
          /*Se data principal é menor que a data inicial do intervalo E a data posterior é igual a data inicial do intervalo*/
          else
          if(resultado[i].data_1!.isAtSameMomentAs(DateTime(anoInicial!, dataNascimento!.month, 1))){
            dataAnteriorFinal = "";
            dataPrincipalFinal = "";
            dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
            dataPrincipalCicloFinal = resultado[i].data_1!;

            datasFinal += " → $dataPosteriorFinal";
          }

        }else
        /*Situacao em que a data principal é maior que a data inicial do intervalo*/
        if(resultado[i].data!.isAfter(DateTime(anoInicial!, dataNascimento!.month, 1))){
  
          /*Situacao em que a data principal é maior que a data inicial do intervalo E data anterior é menor que data inicial do intervalo*/
          if(resultado[i].data_0!.isBefore(DateTime(anoInicial!, dataNascimento!.month, 1))){
             /*Verificar quem está mais próximo da data inicial do intervalo*/
              if ((resultado[i].data_0!
                      .difference(DateTime(anoInicial!, dataNascimento!.month, 1))
                      .inDays) >=
                  (DateTime(anoInicial!, dataNascimento!.month, 1)
                      .difference(resultado[i].data!)
                      .inDays)) 
              {
                  dataAnteriorFinal = "";
                  dataPrincipalFinal = _formatDataBR(DateTime(anoInicial!, dataNascimento!.month, 1));
                  dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
                  dataPrincipalCicloFinal = DateTime(anoInicial!, dataNascimento!.month, 1);

                  datasFinal += " → $dataPrincipalFinal → $dataPosteriorFinal";
              }else{
                  dataAnteriorFinal = _formatDataBR(DateTime(anoInicial!, dataNascimento!.month, 1));
                  dataPrincipalFinal = _formatDataBR(resultado[i].data!);
                  dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
                  dataPrincipalCicloFinal = DateTime(anoInicial!, dataNascimento!.month, 1);

                  datasFinal += "$dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal";
              }

          }
          else
          /*Situacao em que a data principal é maior que a data inicial do intervalo E data anterior também é maior que data inicial do intervalo*/
          if((resultado[i].data_0!.isAfter(DateTime(anoInicial!, dataNascimento!.month, 1)))){
            dataAnteriorFinal = _formatDataBR(DateTime(anoInicial!, dataNascimento!.month, 1));
            dataPrincipalFinal = _formatDataBR(resultado[i].data!);
            dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
            dataPrincipalCicloFinal = DateTime(anoInicial!, dataNascimento!.month, 1);

            datasFinal += "$dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal";
          }
          else
          /*Situacao em que a data principal é maior que a data inicial do intervalo E data anterior é igual a data inicial do intervalo*/
          if(resultado[i].data_0!.isAtSameMomentAs(DateTime(anoInicial!, dataNascimento!.month, 1))){
            dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
            dataPrincipalFinal = _formatDataBR(resultado[i].data!);
            dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
            dataPrincipalCicloFinal = resultado[i].data_0!;

            datasFinal += "$dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal";
          }

        }
        /*Situacao em que a data principal é igual a data inicial do intervalo*/
        else{
            dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
            dataPrincipalFinal = _formatDataBR(resultado[i].data!);
            dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
            dataPrincipalCicloFinal = resultado[i].data!;

            datasFinal += "$dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal";
        }

        /*Adiciona data anterior a primeira data do periodo*/
        //resultadoFinal.add(MeuCiclo(
        //  nome: planeta,
        //  data: adicionarMeses(dataPrincipalCicloFinal, -2),
        //  grau: resultado[i].grau!,
        //)..datastring = '');

        resultadoFinal.add(MeuCiclo(
          nome: planeta,
          data: dataPrincipalCicloFinal,
          grau: resultado[i].grau!,
        )..datastring = ajustarStringPeriodo(datasFinal));

      }
      else
      /*Verificação das datas do ultimo grau se está igual a data final do intervalo para não apresentar diferença no gráfico*/
      if(i == resultado.length - 1){
        String datasFinal = "";

        /*Situacao em que a data principal é menor que a data final do intervalo*/
        if(resultado[i].data!.isBefore(DateTime(anoFinal!, dataNascimento!.month, 1))){

          /*Se a data principal é menor que a data final do intervalo E a data posterior também é menor que a data final do intervalo*/
          if(resultado[i].data_1!.isBefore(DateTime(anoFinal!, dataNascimento!.month, 1))){
            dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
            dataPrincipalFinal = _formatDataBR(resultado[i].data!);
            dataPosteriorFinal = _formatDataBR(DateTime(anoFinal!, dataNascimento!.month, 1));
            dataPrincipalCicloFinal = DateTime(anoFinal!, dataNascimento!.month, 1);

            datasFinal = " $dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal";

          }else
          /*Se a data principal é menor que a data final do intervalo E a data posterior é maior que a data final do intervalo*/
          if((resultado[i].data_1!.isAfter(DateTime(anoFinal!, dataNascimento!.month, 1)))){
              
              if ((resultado[i].data_1!
                      .difference(DateTime(anoFinal!, dataNascimento!.month, 1))
                      .inDays) >=
                  (DateTime(anoFinal!, dataNascimento!.month, 1)
                      .difference(resultado[i].data!)
                      .inDays)) 
              {
                dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
                dataPrincipalFinal = _formatDataBR(DateTime(anoFinal!, dataNascimento!.month, 1));
                dataPosteriorFinal = "";
                dataPrincipalCicloFinal = DateTime(anoFinal!, dataNascimento!.month, 1);

                datasFinal = " $dataAnteriorFinal → $dataPrincipalFinal → ";

              }else{
                dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
                dataPrincipalFinal =  _formatDataBR(resultado[i].data!);
                dataPosteriorFinal = _formatDataBR(DateTime(anoFinal!, dataNascimento!.month, 1));
                dataPrincipalCicloFinal = DateTime(anoFinal!, dataNascimento!.month, 1);

                datasFinal = " $dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal";

              }
          }
          else
          /*Se a data principal é menor que a data final do intervalo E a data posterior é igual a data final do intervalo*/
          if(resultado[i].data_1!.isAtSameMomentAs(DateTime(anoFinal!, dataNascimento!.month, 1))){
            dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
            dataPrincipalFinal = _formatDataBR(resultado[i].data!);
            dataPosteriorFinal = _formatDataBR(resultado[i].data_1!);
            dataPrincipalCicloFinal = resultado[i].data_1!;

            datasFinal = " $dataAnteriorFinal → $dataPrincipalFinal → $dataPosteriorFinal";
          }

        }
        else
        /*Situacao em que a data principal é maior que a data final do intervalo*/
        if(resultado[i].data!.isAfter(DateTime(anoFinal!, dataNascimento!.month, 1))){

          /*Se a data principal é maior que a data final do intervalo E a data anterior é menor que a data final do intervalo*/
          if(resultado[i].data_0!.isBefore(DateTime(anoFinal!, dataNascimento!.month, 1))){
              /*Verificar quem está mais próximo da data final do intervalo*/
              if ((resultado[i].data_0!
                      .difference(DateTime(anoFinal!, dataNascimento!.month, 1))
                      .inDays) >=
                  (DateTime(anoFinal!, dataNascimento!.month, 1)
                      .difference(resultado[i].data!)
                      .inDays)) 
              {
                  dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
                  dataPrincipalFinal = _formatDataBR(DateTime(anoFinal!, dataNascimento!.month, 1));
                  dataPosteriorFinal = "";
                  dataPrincipalCicloFinal = DateTime(anoFinal!, dataNascimento!.month, 1);

                  datasFinal += "$dataAnteriorFinal → $dataPrincipalFinal → ";

              }else{
                  dataAnteriorFinal = _formatDataBR( DateTime(anoFinal!, dataNascimento!.month, 1));
                  dataPrincipalFinal = "";
                  dataPosteriorFinal = "";
                  dataPrincipalCicloFinal = DateTime(anoFinal!, dataNascimento!.month, 1);

                  datasFinal += "$dataAnteriorFinal →  ";
              }
          }
          else
          /*Se a data principal é maior que a data final do intervalo E a data anterior também é maior que a data final do intervalo*/
          if((resultado[i].data_0!.isAfter(DateTime(anoFinal!, dataNascimento!.month, 1)))){
            dataAnteriorFinal =  _formatDataBR(DateTime(anoFinal!, dataNascimento!.month, 1));
            dataPrincipalFinal = "";
            dataPosteriorFinal = "";
            dataPrincipalCicloFinal =  DateTime(anoFinal!, dataNascimento!.month, 1);

            datasFinal += "$dataAnteriorFinal → ";
          }else
          if(resultado[i].data_0!.isAtSameMomentAs(DateTime(anoFinal!, dataNascimento!.month, 1))){
            dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
            dataPrincipalFinal = "";
            dataPosteriorFinal = "";
            dataPrincipalCicloFinal = resultado[i].data_0!;

            datasFinal += "$dataAnteriorFinal → ";
          }

        }
        /*Situacao em que a data principal é igual a data final do intervalo*/
        else{
            dataAnteriorFinal = _formatDataBR(resultado[i].data_0!);
            dataPrincipalFinal = _formatDataBR(resultado[i].data!);
            dataPosteriorFinal = "";
            dataPrincipalCicloFinal = resultado[i].data!;

            datasFinal += "$dataAnteriorFinal → $dataPrincipalFinal → ";
        }

        if((dataComparacaoAnterior.isAfter(dataPrincipalCicloFinal))||(dataComparacaoAnterior.isAtSameMomentAs(dataPrincipalCicloFinal))){
          dataPrincipalCicloFinal = adicionarMeses(dataComparacaoAnterior, 1);
        }

        resultadoFinal.add(MeuCiclo(
          nome: planeta,
          data: dataPrincipalCicloFinal,
          grau: resultado[i].grau!,
        )..datastring = ajustarStringPeriodo(datasFinal));

        /*Adiciona data após a ultima data do grafico*/
        //resultadoFinal.add(MeuCiclo(
        //  nome: planeta,
        //  data: adicionarMeses(dataPrincipalCicloFinal, 2),
        //  grau: resultado[i].grau!,
        //)..datastring = '');

      }
      /*caso não seja nem o primeiro nem o ultimo grau insere sem verificação*/
      else
      {
          resultadoFinal.add(MeuCiclo(
            nome: resultado[i].nome,
            data: resultado[i].data!,
            grau: resultado[i].grau!,
          )..datastring = ajustarStringPeriodo(resultado[i].datastring!));

      }

      dataComparacaoAnterior = resultado[i].data!;
     
    }

    if (planeta == 'S') {
      meuCicloSaturno = resultadoFinal;
    } else if (planeta == 'V') {
      meuCicloVenus = resultadoFinal;
    } else if (planeta == 'M') {
      meuCicloMarte = resultadoFinal;
    } else if (planeta == 'J') {
      meuCicloJupiter = resultadoFinal;
    } else if (planeta == 'U') {
      meuCicloUrano = resultadoFinal;
    } else if (planeta == 'N') {
      meuCicloNetuno = resultadoFinal;
    } else if (planeta == 'P') {
      meuCicloPlutao = resultadoFinal;
    } else {  
    meuCiclo = resultadoFinal;
    }
  }

  String _formatDataBR(DateTime data) {
    return "${data.month.toString().padLeft(2, '0')}/"
          "${data.year.toString().padLeft(4, '0')}";
  }

  Future<List<MeuGrafico>> _montarLinhaGrafico(
    List<MeuCiclo> lista,
    GrauCalculado g,
  ) async {

    /*
    Letra Solar (S)|Fase quando Homem|Fase quando Mulher|Letra INI-FIN|eixo x,y (H)|eixo x,y (M)|
    ---------------|-----------------|------------------|-------------|------------|------------|
    Sobre A        |        1        |         3        |    E - E    |  a,    0   |   a,    0  |
    Entre A e B    |        1-2      |         3-4      |    E - E    |  a+1, -1   |   a+1,  1  |
    Sobre B        |        2        |         4        |    E - E    |  a+2, -2   |   a+2,  2  |
    Entre B e C    |        2-3      |         4-1      |    G - G    |  a+3, -1   |   a+3,  1  |
    Sobre C        |        3        |         1        |    G - G    |  a+4,  0   |   a+4,  0  |
    Entre C e D    |        3-4      |         1-2      |    G - G    |  a+5,  1   |   a+5, -1  |
    Sobre D        |        4        |         2        |    G - G    |  a+6,  2   |   a+6, -2  |
    Entre D e E    |        4-1      |         2-3      |    A - A    |  a+7,  1   |   a+7, -1  |
    Sobre E        |        1        |         3        |    A - A    |  a+8,  0   |   a+8,  0  |
    Entre E e F    |        1-2      |         3-4      |    A - A    |  a+9, -1   |   a+9,  1  |
    Sobre F        |        2        |         4        |    A - A    |  a+10, -2  |   a+10, 2  |
    Entre F e G    |        2-3      |         4-1      |    C - C    |  a+11, -1  |   a+11, 1  |
    Sobre G        |        3        |         1        |    C - C    |  a+12,  0  |   a+12, 0  |
    Entre G e H    |        3-4      |         1-2      |    C - C    |  a+13,  1  |   a+13,-1  |
    Sobre H        |        4        |         2        |    C - C    |  a+14,  2  |   a+14,-2  |
    Entre H e A    |        4-1      |         2-3      |    E - E    |  a+15,  1  |   a+15,-1  |
    */

    List<MeuGrafico> linha = [];

    if (lista.isEmpty) return linha;

    String faseAtual = '';
    int x = 0;
    int y = 0;
    String letra = '';
    String nome = '';
//print('TAMANHO: ' + lista.length.toString());
    for (int i = 0; i <= lista.length - 1; i++) {
      final item = lista[i];
     // print('i::'+ i.toString() + ' - ' + item.nome.toString() + ' - ' + item.data.toString() + ' - ' + item.grau.toString());

      if (item.grau == null) continue;

      faseAtual = await obterFase(g, item.grau!);
      nome = item.nome ?? '';

      // mantém exatamente sua lógica atual 👇
      //(1) if (i == 0) {
      //(1)  x = 0;
      //(1)} else {
      //(1)  x = x + 1;
     //(1) }

      final data = DateTime.parse(item.data.toString());
      x = data.millisecondsSinceEpoch;

      if(sexo == 'Masculino'){
          if (faseAtual == 'A') {
            y = 0;
            letra = 'E';
          } else if (faseAtual == 'AB') {
            y = -1;
            letra = 'E';
          } else if (faseAtual == 'B') {
            y = -2;
            letra = 'E';
          } else if (faseAtual == 'BC') {
            y = -1;
            letra = 'G';
          } else if (faseAtual == 'C') {
            y = 0;
            letra = 'G';
          } else if (faseAtual == 'CD') {
            y = 1;
            letra = 'G';
          } else if (faseAtual == 'D') {
            y = 2;
            letra = 'G';
          } else if (faseAtual == 'DE') {
            y = 1;
            letra = 'A';
          } else if (faseAtual == 'E') {
            y = 0;
            letra = 'A';
          } else if (faseAtual == 'EF') {
            y = -1;
            letra = 'A';
          } else if (faseAtual == 'F') {
            y = -2;
            letra = 'A';
          } else if (faseAtual == 'FG') {
            y = -1;
            letra = 'C';
          } else if (faseAtual == 'G') {
            y = 0;
            letra = 'C';
          } else if (faseAtual == 'GH') {
            y = 1;
            letra = 'C';
          } else if (faseAtual == 'H') {
            y = 2;
            letra = 'C';
          } else if (faseAtual == 'HA') {
            y = 1;
            letra = 'E';
          }
      } else if (sexo == 'Feminino') {
          if (faseAtual == 'A') {
            y = 0;
            letra = 'E';
          } else if (faseAtual == 'AB') {
            y = 1;
            letra = 'E';
          } else if (faseAtual == 'B') {
            y = 2;
            letra = 'E';
          } else if (faseAtual == 'BC') {
            y = 1;
            letra = 'G';
          } else if (faseAtual == 'C') {
            y = 0;
            letra = 'G';
          } else if (faseAtual == 'CD') {
            y = -1;
            letra = 'G';
          } else if (faseAtual == 'D') {
            y = -2;
            letra = 'G';
          } else if (faseAtual == 'DE') {
            y = -1;
            letra = 'A';
          } else if (faseAtual == 'E') {
            y = 0;
            letra = 'A';
          } else if (faseAtual == 'EF') {
            y = 1;
            letra = 'A';
          } else if (faseAtual == 'F') {
            y = 2;
            letra = 'A';
          } else if (faseAtual == 'FG') {
            y = 1;
            letra = 'C';
          } else if (faseAtual == 'G') {
            y = 0;
            letra = 'C';
          } else if (faseAtual == 'GH') {
            y = -1;
            letra = 'C';
          } else if (faseAtual == 'H') {
            y = -2;
            letra = 'C';
          } else if (faseAtual == 'HA') {
            y = -1;
            letra = 'E';
          }

      }

      linha.add(MeuGrafico(
        eixo_x: x,
        eixo_y: y,
        datastring: item.datastring, //item.data.toString(),
        letra: faseAtual,
        nome: nome, // 🔥 ESSENCIAL → diferencia as linhas
      ));
    }

    return linha;
  }

  String ajustarStringPeriodo(String input) {
    if (input.isEmpty) return '';

    // Divide a string pelas setas
    List<String> partes = input.split('→');

    // Limpa espaços e remove null / vazio
    List<String> filtradas = partes
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e.toLowerCase() != 'null')
        .toList();

    // Remove duplicados mantendo ordem
    List<String> unicas = [];
    for (var item in filtradas) {
      if (!unicas.contains(item)) {
        unicas.add(item);
      }
    }

    // Junta novamente com seta
    return unicas.join(' → ');
  }


}

*/