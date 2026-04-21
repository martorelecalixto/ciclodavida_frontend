import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────
const _bg         = Color(0xFF0B1120);
const _surface    = Color(0xFF131E30);
const _surface2   = Color(0xFF1A2740);
const _accent     = Color(0xFF38BDF8); // sky-400
const _accentDark = Color(0xFF0EA5E9); // sky-500
const _textPrimary   = Color(0xFFF1F5F9);
const _textSecondary = Color(0xFF94A3B8);
const _border     = Color(0xFF1E3A5F);

// ─────────────────────────────────────────────
// DASHBOARD SCREEN
// ─────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  final Function(int) onMenuItemSelected;

  const DashboardScreen({super.key, required this.onMenuItemSelected});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _pagina = 0;
  String _nome = 'Usuário';

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _nome = prefs.getString('nome') ?? 'Usuário');
  }

  void _ir(int pagina) => setState(() => _pagina = pagina);
  void _voltar()       => setState(() => _pagina = 0);

  // ── Navegação externa (menu lateral / AppBar) ──
  void _selectItem(int index) {
    widget.onMenuItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 700;

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(isMobile),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: KeyedSubtree(
          key: ValueKey(_pagina),
          child: _buildPagina(),
        ),
      ),
    );
  }

  // ── AppBar ──
  AppBar _buildAppBar(bool isMobile) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: _surface,
      elevation: 0,
      centerTitle: isMobile,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(
              //color: _accentDark, 
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: _buildLogo(), 
          ),
          const SizedBox(width: 8),
          Text(
            'Ciclo da Vida',
            style: TextStyle(
              color: _textPrimary, fontSize: 17, fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: isMobile
          ? null
          : [
              _navBtn('Home',   0, active: true),
              _navBtn('Mapa',   1),
              _navBtn('Perfil', 2),
              _navBtn('Credito', 3),
              _navBtnSair('Sair', -1),
              const SizedBox(width: 8),
            ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _border),
      ),
    );
  }

  Widget _navBtn(String label, int index,{active=false}) {
    //final active = _pagina == index; 
   // print('pagina: ' + _pagina.toString() +' index::' + index.toString());
   // print('====================');
    return TextButton(
      onPressed: () => _ir(index),
      style: TextButton.styleFrom(
        foregroundColor: active ? _accent : _textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _navBtnSair(String label, int index) {
    final active = _pagina == index;
    return TextButton(
      onPressed: () => _selectItem(index),
      style: TextButton.styleFrom(
        foregroundColor: active ? _accent : _textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }

  // ── Roteador ──
  Widget _buildPagina() {
    //print('pagina::::'+_pagina.toString());
    switch (_pagina) {
      case 0:  return _HomePage(nome: _nome, onNavegar: _ir);
      case 1:  // Mapa → delega para o pai
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onMenuItemSelected(1);
        });
        return _HomePage(nome: _nome, onNavegar: _ir);
      case 2:  // Perfil → delega para o pai
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onMenuItemSelected(2);
        });
        return _HomePage(nome: _nome, onNavegar: _ir);
      case 3:  // Perfil → delega para o pai
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onMenuItemSelected(3);
        });
        return _HomePage(nome: _nome, onNavegar: _ir);
      case 4:  return _InfoPage(config: _pageConfigs[3], onVoltar: _voltar);
      case 5:  return _InfoPage(config: _pageConfigs[4], onVoltar: _voltar);
      case 6:  return _InfoPage(config: _pageConfigs[5], onVoltar: _voltar);
      case 7:  return _InfoPage(config: _pageConfigs[6], onVoltar: _voltar);
      case 8:  return _InfoPage(config: _pageConfigs[7], onVoltar: _voltar);
      case 9:  return _InfoPage(config: _pageConfigs[8], onVoltar: _voltar);
      case 10:  return _InfoPage(config: _pageConfigs[9], onVoltar: _voltar);
      case 11: return _InfoPage(config: _pageConfigs[10], onVoltar: _voltar);
      default: return _HomePage(nome: _nome, onNavegar: _ir);
    }
  }

  // ── Logo + título ──
  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 25, height: 25,
          decoration: BoxDecoration(
            //color: _accentDark.withOpacity(0.12),
            shape: BoxShape.circle,
            //border: Border.all(color: _accentDark.withOpacity(0.4), width: 1.5),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.loop, color: _accent, size: 36),
            ),
          ),
        ),
      ],
    );
  }


}

// ─────────────────────────────────────────────
// CONFIG DE CADA PÁGINA
// ─────────────────────────────────────────────
class _PageConfig {
  final String titulo;
  final String categoria;
  final IconData icone;
  final Color cor;
  final String imagem;
  final List<String> paragrafos;

  const _PageConfig({
    required this.titulo,
    required this.categoria,
    required this.icone,
    required this.cor,
    required this.imagem,
    required this.paragrafos,
  });
}

const List<_PageConfig> _pageConfigs = [
  // índice 0 → _pagina 1 (Mapa)
  _PageConfig(
    titulo: 'Meu Mapa',
    categoria: 'Navegação',
    icone: Icons.map_outlined,
    cor: Color(0xFF38BDF8),
    imagem: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800',
    paragrafos: [
      'Seu mapa é a representação visual da sua jornada completa. '
      'Ele reúne todos os dados coletados e os organiza de forma '
      'geográfica e temporal, oferecendo uma visão ampla do seu percurso.',
      'Por meio do mapa você identifica padrões pessoais que seriam '
      'invisíveis em tabelas ou listas. A distribuição espacial dos '
      'eventos revela conexões entre momentos aparentemente isolados.',
      'Cada ponto no mapa é único e reflete um aspecto da sua realidade. '
      'A ferramenta foi projetada para ser sua principal referência na '
      'tomada de decisões importantes.',
      'Com o mapa ativo, a análise se torna profunda e intuitiva. '
      'Você passa a entender não apenas o que aconteceu, mas como '
      'cada evento se conecta ao próximo dentro da sua trajetória.',
    ],
  ),

  // índice 1 → _pagina 2 (Perfil)
  _PageConfig(
    titulo: 'Meu Perfil',
    categoria: 'Conta',
    icone: Icons.person_outline,
    cor: Color(0xFFA78BFA),
    imagem: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
    paragrafos: [
      'Seu perfil centraliza todas as informações que personalizam '
      'a sua experiência dentro do sistema. Ele define como os '
      'algoritmos interpretam e respondem aos seus dados.',
      'Manter o perfil atualizado é essencial para garantir '
      'a precisão das análises. Pequenas mudanças nos seus dados '
      'podem impactar diretamente a qualidade dos resultados gerados.',
      'O sistema usa as informações do perfil para calibrar cada '
      'cálculo de forma individualizada. Não existe um resultado '
      'genérico — tudo é ajustado à sua realidade específica.',
      'Você pode revisar e atualizar seu perfil a qualquer momento. '
      'Recomendamos revisões periódicas para garantir que os dados '
      'reflitam fielmente seu momento atual.',
    ],
  ),
  // índice 2 → _pagina 3 ("APENAS PARA COMPLETAR INDICE")
  _PageConfig(
    titulo: 'APENAS PARA COMPLETAR INDICE',
    categoria: 'Conta',
    icone: Icons.person_outline,
    cor: Color(0xFFA78BFA),
    imagem: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
    paragrafos: [
      'Seu perfil centraliza todas as informações que personalizam '
      'a sua experiência dentro do sistema. Ele define como os '
      'algoritmos interpretam e respondem aos seus dados.',
      'Manter o perfil atualizado é essencial para garantir '
      'a precisão das análises. Pequenas mudanças nos seus dados '
      'podem impactar diretamente a qualidade dos resultados gerados.',
      'O sistema usa as informações do perfil para calibrar cada '
      'cálculo de forma individualizada. Não existe um resultado '
      'genérico — tudo é ajustado à sua realidade específica.',
      'Você pode revisar e atualizar seu perfil a qualquer momento. '
      'Recomendamos revisões periódicas para garantir que os dados '
      'reflitam fielmente seu momento atual.',
    ],
  ),
  // índice 3 → _pagina 4 (Ciclos)
  /*_PageConfig(
    titulo: 'Ciclos da Vida',
    categoria: 'Conceito',
    icone: Icons.loop,
    cor: Color(0xFF34D399),
    imagem: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800',
    paragrafos: [
      'A vida é construída sobre ciclos que se repetem constantemente '
      'ao longo do tempo. Esses ciclos não são aleatórios — eles seguem '
      'padrões organizados que podem ser observados com atenção e método.',
      'Quando você começa a perceber esses padrões, passa a entender '
      'melhor os momentos de crescimento, pausa e transformação. '
      'Nada acontece de forma isolada; tudo faz parte de um fluxo '
      'contínuo que se repete com pequenas variações a cada volta.',
      'Os ciclos também explicam por que certas situações voltam a '
      'acontecer na sua vida. Isso não significa erro — significa '
      'oportunidade de aprendizado e evolução pessoal profunda.',
      'Ao compreender os ciclos, você ganha clareza sobre decisões '
      'importantes e evita agir por impulso. Passa a respeitar o '
      'momento certo de avançar, pausar ou recuar.',
      'Existe um tempo para plantar, um tempo para crescer e um '
      'tempo para colher. Ignorar essa lógica gera frustração; '
      'respeitá-la gera resultados mais consistentes e duradouros.',
      'No final, entender os ciclos significa dominar a si mesmo, '
      'trazendo mais segurança, confiança e direção para cada '
      'aspecto da sua trajetória pessoal e profissional.',
    ],
  ),*/
  _PageConfig(
    titulo: 'O Ciclo da Vida',
    categoria: 'Fundamentos',
    icone: Icons.autorenew,
    cor: Color(0xFF6366F1),
    imagem: 'https://images.unsplash.com/photo-1492724441997-5dc865305da7?w=800',
    paragrafos: [
      'A vida não acontece de forma aleatória. Existe um ritmo, um fluxo invisível que conduz cada fase da sua existência.'
      'O ciclo da vida representa exatamente isso: um movimento contínuo de crescimento, desafios e renovação.'
      'Assim como as estações do ano, você também passa por períodos de expansão e recolhimento.'
      'Existem momentos em que tudo flui com facilidade e outros em que tudo parece travar sem explicação.'
      'Essas mudanças não são acaso — elas fazem parte de um padrão maior que pode ser compreendido.'
      'Ao entender o seu ciclo, você começa a enxergar sua vida com mais clareza e menos confusão.'
      'O que antes parecia sorte ou azar passa a fazer sentido dentro de um contexto.'
      'Você deixa de reagir à vida e começa a antecipar os movimentos dela.'
      'Cada fase tem um propósito específico e uma energia dominante.'
      'Algumas fases pedem ação, outras pedem paciência.'
      'Algumas trazem crescimento rápido, outras exigem estrutura e maturidade.'
      'Ignorar esse ciclo gera frustração e decisões equivocadas.'
      'Seguir o ciclo traz alinhamento e resultados mais consistentes.'
      'A grande vantagem é que esse padrão pode ser calculado e interpretado.'
      'Ou seja, você não precisa mais viver no escuro.'
      'Você passa a entender o momento certo de agir e o momento certo de esperar.'
      'Essa consciência muda completamente a forma como você toma decisões.'
      'E o mais importante: coloca você no controle da sua própria trajetória.'
      'O ciclo da vida é o mapa invisível que sempre esteve guiando você.'
      'Agora você finalmente pode enxergá-lo com clareza.'
    ],
  ),

  // índice 4 → _pagina 5 (Futuro)
 /* _PageConfig(
    titulo: 'Previsão do Futuro',
    categoria: 'Análise',
    icone: Icons.visibility_outlined,
    cor: Color(0xFFFBBF24),
    imagem: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800',
    paragrafos: [
      'O futuro não é totalmente aleatório. Ele é influenciado por '
      'padrões que já aconteceram antes, e a repetição de eventos '
      'permite projeções cada vez mais precisas com o passar do tempo.',
      'Ao entender o passado de forma estruturada, você antecipa '
      'cenários futuros com maior confiança. A análise correta '
      'reduz riscos e transforma incertezas em probabilidades gerenciáveis.',
      'Não se trata de adivinhação, mas de lógica e observação '
      'sistemática. Os sinais estão sempre presentes no fluxo dos '
      'acontecimentos — basta desenvolver a habilidade de lê-los.',
      'Decisões melhores surgem quando você enxerga além do presente '
      'imediato. Quem entende padrões passa a controlar probabilidades '
      'em vez de apenas reagir às circunstâncias.',
    ],
  ),*/
  _PageConfig(
    titulo: 'A Contagem do Tempo',
    categoria: 'Fundamentos',
    icone: Icons.schedule,
    cor: Color(0xFF22C55E),
    imagem: 'https://images.unsplash.com/photo-1501139083538-0139583c060f?w=800',
    paragrafos: [
      'Desde o momento do seu nascimento, um ciclo invisível começou a ser contado.'
      'Esse ciclo não segue apenas o relógio comum, mas sim um padrão energético.'
      'Cada ano da sua vida carrega uma vibração específica.'
      'Essa vibração influencia diretamente suas experiências e decisões.'
      'A astrologia utiliza movimentos celestes para medir esse fluxo.'
      'Não se trata de previsão mística, mas de leitura de padrões.'
      'Assim como o tempo marca horas, o ciclo marca fases da vida.'
      'Cada fase possui um significado e uma intensidade própria.'
      'Ao longo dos anos, esses padrões se repetem de forma organizada.'
      'Isso permite entender não só o presente, mas também o passado e o futuro.'
      'Você começa a perceber que certos acontecimentos seguem uma lógica.'
      'Momentos de crise e crescimento deixam de ser coincidência.'
      'A contagem astrológica revela o “tempo certo” das coisas.'
      'Ela mostra quando insistir e quando recuar.'
      'Quando investir e quando se proteger.'
      'Quando agir com coragem e quando agir com estratégia.'
      'Esse tipo de leitura transforma completamente sua visão de vida.'
      'Você passa a agir com mais segurança e menos dúvida.'
      'E isso gera decisões mais inteligentes e conscientes.'
      'O tempo deixa de ser seu inimigo e passa a ser seu aliado.'
    ],
  ),

  // índice 5 → _pagina 6 (Natureza)
  /*_PageConfig(
    titulo: 'Ritmos da Natureza',
    categoria: 'Conceito',
    icone: Icons.eco_outlined,
    cor: Color(0xFF4ADE80),
    imagem: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
    paragrafos: [
      'A natureza funciona em ciclos perfeitos e interdependentes. '
      'As estações do ano são o exemplo mais visível dessa lógica: '
      'tudo cresce, amadurece, se transforma e recomeça.',
      'Nada acontece por acaso no mundo natural. Existe uma ordem '
      'invisível guiando cada processo, desde o ciclo das chuvas '
      'até o ritmo de crescimento de uma floresta inteira.',
      'O ser humano também faz parte desses ritmos, ainda que '
      'muitas vezes ignore esse fato. Ignorar os ciclos naturais '
      'gera desequilíbrio; seguir seus ritmos traz harmonia.',
      'Observar a natureza é aprender sobre a vida de forma '
      'profunda e silenciosa. Ela ensina adaptação constante '
      'e resiliência diante de qualquer mudança.',
    ],
  ),*/

  _PageConfig(
    titulo: 'Fases da Vida',
    categoria: 'Ciclos',
    icone: Icons.timeline,
    cor: Color(0xFFF59E0B),
    imagem: 'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=800',
    paragrafos: [
      'A vida é composta por fases bem definidas, cada uma com sua própria energia.'
      'Existem períodos de crescimento, onde tudo parece avançar rapidamente.'
      'Outros momentos são mais desafiadores e exigem resiliência.'
      'Há também fases de estabilidade, ideais para consolidar conquistas.'
      'Essas fases não são aleatórias, elas seguem um ciclo preciso.'
      'Cada planeta influencia um tipo específico de experiência.'
      'Júpiter traz expansão, Saturno traz responsabilidade.'
      'Marte impulsiona ação, enquanto Vênus trabalha relações.'
      'Urano, Netuno e Plutão trazem mudanças mais profundas.'
      'Quando esses movimentos se combinam, criam o cenário da sua vida.'
      'Você pode estar em uma fase de crescimento profissional e desafio emocional ao mesmo tempo.'
      'Ou viver um período de estabilidade geral com pequenos conflitos internos.'
      'Entender essas fases evita decisões impulsivas.'
      'Você aprende a respeitar o momento atual.'
      'Isso reduz ansiedade e aumenta sua clareza.'
      'Você começa a agir com mais inteligência emocional.'
      'E passa a aproveitar melhor as oportunidades.'
      'Cada fase tem um valor, mesmo as difíceis.'
      'Porque todas contribuem para sua evolução.'
      'Quando você entende isso, tudo muda.'
    ],
  ),  
  
  /*
  // índice 6 → _pagina 7 (Tempo)
  _PageConfig(
    titulo: 'Tempo e Padrões',
    categoria: 'Conceito',
    icone: Icons.access_time_outlined,
    cor: Color(0xFFF472B6),
    imagem: 'https://images.unsplash.com/photo-1501139083538-0139583c060f?w=800',
    paragrafos: [
      'O tempo é a base estrutural de todos os ciclos. Ele organiza '
      'eventos em sequência lógica e fornece o eixo sobre o qual '
      'todos os padrões se manifestam e podem ser medidos.',
      'Sem tempo não há mudança perceptível. Tudo acontece dentro '
      'de intervalos, e compreender esses intervalos é essencial '
      'para qualquer análise séria de comportamento e tendências.',
      'Os padrões são distribuídos ao longo do tempo de maneira '
      'que revela intenções ocultas nas sequências de eventos. '
      'O tempo transforma dados isolados em narrativas compreensíveis.',
      'A percepção do tempo muda decisões de forma radical. '
      'Quem aprende a enxergar o tempo como uma estrutura '
      'de padrões passa a ter vantagem estratégica consistente.',
    ],
  ),*/

  _PageConfig(
    titulo: 'Momento de Agir',
    categoria: 'Estratégia',
    icone: Icons.flash_on,
    cor: Color(0xFFEF4444),
    imagem: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800',
    paragrafos: [
      'Um dos maiores segredos da vida é saber o momento certo de agir.'
      'Nem sempre esforço gera resultado — o timing é essencial.'
      'Existem períodos em que qualquer ação tende a dar certo.'
      'E outros em que até boas decisões enfrentam resistência.'
      'Isso acontece porque cada fase tem uma energia dominante.'
      'Quando você age alinhado com essa energia, tudo flui.'
      'Quando age contra ela, surgem obstáculos.'
      'O mapa de ciclos permite identificar esses momentos.'
      'Você passa a agir com estratégia, não apenas impulso.'
      'Isso aumenta drasticamente suas chances de sucesso.'
      'Você reduz erros e evita desgaste desnecessário.'
      'E começa a aproveitar melhor cada oportunidade.'
      'Saber esperar também se torna uma vantagem.'
      'Nem toda fase é para avançar — algumas são para preparar.'
      'Essa consciência traz maturidade e equilíbrio.'
      'Você deixa de se comparar com os outros.'
      'E passa a respeitar o seu próprio tempo.'
      'Isso gera mais confiança e menos ansiedade.'
      'O resultado é uma vida mais leve e eficiente.'
      'E decisões muito mais acertadas.'
    ],
  ),

  // índice 7 → _pagina 8 (Cadastro)
  _PageConfig(
    titulo: 'Cadastro Inicial',
    categoria: 'Como funciona',
    icone: Icons.person_add_outlined,
    cor: Color(0xFF38BDF8),
    imagem: 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=800',
    paragrafos: [
      'O início de tudo está nos dados que você fornece. '
      'Informações corretas e completas geram resultados precisos; '
      'dados imprecisos comprometem toda a cadeia de análise.'
      'Cada detalhe inserido no cadastro influencia os cálculos '
      'subsequentes. O sistema foi projetado para transformar '
      'informações pessoais em padrões significativos e acionáveis.'
      'O cadastro não é apenas um formulário — é a fundação '
      'sobre a qual toda a sua experiência será construída. '
      'Quanto mais cuidadoso nessa etapa, melhores os resultados.'
      'Sem um cadastro completo não há análise consistente. '
      'Tudo no sistema começa aqui, e a qualidade dessa base '
      'determina diretamente o valor de tudo que vem depois.',
    ],
  ),
  // índice 8 → _pagina 9 (Processamento)
  _PageConfig(
    titulo: 'Previsões',
    categoria: 'Futuro',
    icone: Icons.visibility,
    cor: Color(0xFF0EA5E9),
    imagem: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800',
    paragrafos: [
      'Imagine poder enxergar tendências antes que elas aconteçam.'
      'A previsão de ciclos permite exatamente isso.'
      'Você consegue identificar períodos favoráveis e desafiadores.'
      'Isso vale tanto para o curto quanto para o longo prazo.'
      'No curto prazo, você ajusta decisões imediatas.'
      'No longo prazo, você planeja sua vida com mais segurança.'
      'Você deixa de viver no improviso.'
      'E passa a construir um caminho com intenção.'
      'Cada fase futura pode ser analisada com antecedência.'
      'Isso reduz riscos e aumenta oportunidades.'
      'Você sabe quando investir, mudar ou esperar.'
      'Isso gera vantagem em relação a quem não tem essa visão.'
      'A previsibilidade não tira a liberdade.'
      'Ela amplia sua capacidade de escolha.'
      'Você passa a agir com consciência.'
      'E não apenas reagir aos acontecimentos.'
      'Isso muda completamente seus resultados.'
      'Você ganha clareza, direção e segurança.'
      'E constrói uma vida muito mais estratégica.'
      'O futuro deixa de ser incerto e passa a ser planejável.'
    ],
  ), 
 
 /* _PageConfig(
    titulo: 'Processamento',
    categoria: 'Como funciona',
    icone: Icons.settings_outlined,
    cor: Color(0xFFA78BFA),
    imagem: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800',
    paragrafos: [
      'Os dados passam por uma análise algorítmica estruturada '
      'que identifica correlações e padrões não evidentes a '
      'olho nu. É o coração inteligente do sistema.',
      'Cada cálculo segue uma lógica definida e auditável. '
      'Nada é feito de forma aleatória — todo resultado tem '
      'uma cadeia de raciocínio que pode ser rastreada.',
      'O processamento conecta os dados brutos do cadastro '
      'com os resultados que você verá nas análises. Esse '
      'elo é o que transforma informação em inteligência.',
      'A precisão do sistema depende diretamente da qualidade '
      'desse processo. É aqui que dados ganham contexto '
      'e passam a ter significado real para a sua jornada.',
    ],
  ),*/
  // índice 10 → _pagina 11 (Geração)
  _PageConfig(
    titulo: 'Sua História',
    categoria: 'Análise',
    icone: Icons.history,
    cor: Color(0xFF8B5CF6),
    imagem: 'https://images.unsplash.com/photo-1465101162946-4377e57745c3?w=800',
    paragrafos: [
      'Seu passado guarda padrões que podem explicar o seu presente.'
      'Ao analisar ciclos anteriores, você começa a identificar repetições.'
      'Momentos de crescimento tendem a seguir um padrão.'
      'Assim como momentos de dificuldade.'
      'Essa análise traz uma nova perspectiva sobre sua história.'
      'Você passa a entender por que certas coisas aconteceram.'
      'E como elas se encaixam no seu ciclo.'
      'Isso reduz arrependimentos e aumenta aprendizado.'
      'Você deixa de ver erros como fracassos.'
      'E passa a enxergá-los como parte do processo.'
      'Essa consciência traz maturidade emocional.'
      'E fortalece sua capacidade de decisão.'
      'Você começa a reconhecer seus próprios padrões.'
      'E pode quebrar ciclos negativos.'
      'Ou potencializar ciclos positivos.'
      'Isso gera evolução real e consistente.'
      'Você se conhece melhor.'
      'E passa a confiar mais em si mesmo.'
      'O passado deixa de ser um peso.'
      'E se torna uma ferramenta poderosa.'
    ],
  ),

  /*_PageConfig(
    titulo: 'Geração de Ciclos',
    categoria: 'Como funciona',
    icone: Icons.autorenew,
    cor: Color(0xFF34D399),
    imagem: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800',
    paragrafos: [
      'Os ciclos são gerados automaticamente a partir dos dados '
      'processados. Cada ciclo representa uma fase distinta da '
      'sua trajetória com início, meio e fim bem definidos.',
      'As fases se conectam entre si de forma contínua — '
      'nada é isolado. O término de um ciclo alimenta '
      'o início do seguinte, criando uma narrativa coerente.',
      'A geração de ciclos revela padrões ocultos que só '
      'se tornam visíveis quando os dados são analisados '
      'em conjunto e ao longo de um período significativo.',
      'Compreender os ciclos gerados permite prever '
      'comportamentos futuros com mais segurança e tomar '
      'decisões alinhadas com o momento certo de cada fase.',
    ],
  ),*/
  // índice 11 → _pagina 12 (Visualização)
  _PageConfig(
    titulo: 'Descubra Seu Potencial',
    categoria: 'Premium',
    icone: Icons.star,
    cor: Color(0xFFF97316),
    imagem: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?w=800',
    paragrafos: [
      'Existe um padrão guiando sua vida neste exato momento.'
      'E a maioria das pessoas simplesmente ignora isso.'
      'Elas tomam decisões no escuro, baseadas apenas em tentativa e erro.'
      'Mas você não precisa viver assim.'
      'Com o mapa de ciclos, você enxerga além do óbvio.'
      'Você entende o momento certo de agir.'
      'E evita erros que poderiam custar anos da sua vida.'
      'Essa é a diferença entre reagir e antecipar.'
      'Entre sorte e estratégia.'
      'Entre dúvida e clareza.'
      'Imagine saber quando investir, mudar ou esperar.'
      'Imagine entender por que certas fases foram difíceis.'
      'E como aproveitar melhor as próximas.'
      'Isso não é sorte. É conhecimento.'
      'E está disponível para você agora.'
      'Cada decisão se torna mais consciente.'
      'Cada passo mais seguro.'
      'Cada fase mais clara.'
      'Você assume o controle da sua própria trajetória.'
      'E começa a viver com direção e propósito.'
    ],
  ),

  /*_PageConfig(
    titulo: 'Visualização',
    categoria: 'Como funciona',
    icone: Icons.bar_chart_outlined,
    cor: Color(0xFFFBBF24),
    imagem: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800',
    paragrafos: [
      'Os dados e ciclos são exibidos de forma clara e intuitiva '
      'por meio de gráficos, mapas e painéis interativos. '
      'A visualização é onde tudo se torna compreensível.',
      'Gráficos bem construídos facilitam a interpretação '
      'de informações complexas. Padrões que seriam invisíveis '
      'em tabelas ficam imediatamente evidentes de forma visual.',
      'A análise se torna intuitiva quando você pode ver '
      'o todo de uma vez. Informação bem apresentada é '
      'uma das ferramentas mais poderosas que existem.',
      'Tudo está ao seu alcance nesta etapa final. '
      'Agora você enxerga a sua jornada com profundidade, '
      'clareza e capacidade real de agir sobre ela.',
    ],
  ),*/
];

// ─────────────────────────────────────────────
// HOME PAGE
// ─────────────────────────────────────────────

class _HomePage extends StatelessWidget {
  final String nome;
  final void Function(int) onNavegar;

  const _HomePage({required this.nome, required this.onNavegar});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Hero(nome: nome),
          const SizedBox(height: 32),
          _SectionLabel(label: 'O que é o ciclo da vida?'),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isMobile ? 1.0 : 1.1,
            children: [
              _NavCard(label: 'O Ciclo da Vida',  icon: Icons.loop,         cor: const Color(0xFF6366F1), pagina: 4, onTap: onNavegar),//Color(0xFF34D399)
              _NavCard(label: 'A Contagem do Tempo',    icon: Icons.schedule, cor: const Color(0xFF22C55E), pagina: 5, onTap: onNavegar),//Color(0xFFFBBF24)
              _NavCard(label: 'Fases da Vida',  icon: Icons.timeline,        cor: const Color(0xFFF59E0B), pagina: 6, onTap: onNavegar),//Color(0xFF4ADE80)
              _NavCard(label: 'Momento de Agir',     icon: Icons.flash_on,cor: const Color(0xFFEF4444), pagina: 7, onTap: onNavegar),//Color(0xFFF472B6)
            ],
          ),
          const SizedBox(height: 32),
          _SectionLabel(label: 'Como funciona?'),
          const SizedBox(height: 14),
          _Stepper(
            steps: const [
              _Step(num: 1, label: 'Cadastro inicial',      pagina: 8),
              _Step(num: 2, label: 'Previsões',   pagina: 9),
              _Step(num: 3, label: 'Sua História',     pagina: 10),
              _Step(num: 4, label: 'Descubra Seu Potencial',  pagina: 11),
            ],
            onTap: onNavegar,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Hero ──
class _Hero extends StatelessWidget {
  final String nome;
  const _Hero({required this.nome});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 2, height: 52,
            decoration: BoxDecoration(
            ),
            alignment: Alignment.center,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo, $nome 👋',
                  style: const TextStyle(
                    color: _textPrimary, fontSize: 18, fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Controle total da sua jornada',
                  style: TextStyle(color: _textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ──
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 18, color: _accent,
            margin: const EdgeInsets.only(right: 10)),
        Text(label, style: const TextStyle(
          color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w600,
        )),
      ],
    );
  }
}

// ── Nav Card ──
class _NavCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color cor;
  final int pagina;
  final void Function(int) onTap;

  const _NavCard({
    required this.label, required this.icon, required this.cor,
    required this.pagina, required this.onTap,
  });

  @override
  State<_NavCard> createState() => _NavCardState();
}

class _NavCardState extends State<_NavCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit:  (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.pagina),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: _hover
                ? widget.cor.withOpacity(0.12)
                : _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hover ? widget.cor.withOpacity(0.5) : _border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: widget.cor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.cor, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: TextStyle(
                  color: _hover ? widget.cor : _textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stepper visual ──
class _Step {
  final int num;
  final String label;
  final int pagina;
  const _Step({required this.num, required this.label, required this.pagina});
}

class _Stepper extends StatelessWidget {
  final List<_Step> steps;
  final void Function(int) onTap;
  const _Stepper({required this.steps, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (i) {
        final s = steps[i];
        final isLast = i == steps.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linha vertical + número
              SizedBox(
                width: 36,
                child: Column(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: const BoxDecoration(
                        color: _accentDark, shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${s.num}',
                        style: const TextStyle(
                          color: Colors.white, fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1.5,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: _border,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Item clicável
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                  child: GestureDetector(
                    onTap: () => onTap(s.pagina),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.label,
                              style: const TextStyle(
                                color: _textPrimary, fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: _textSecondary, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
// INFO PAGE — página única reutilizável
// ─────────────────────────────────────────────
class _InfoPage extends StatefulWidget {
  final _PageConfig config;
  final VoidCallback onVoltar;

  const _InfoPage({required this.config, required this.onVoltar});

  @override
  State<_InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<_InfoPage> {
  final ScrollController _scroll = ScrollController();
  double _progresso = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final max = _scroll.position.maxScrollExtent;
    if (max <= 0) return;
    setState(() => _progresso = (_scroll.offset / max).clamp(0.0, 1.0));
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = widget.config;
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Barra de progresso de leitura ──
            LinearProgressIndicator(
              value: _progresso,
              backgroundColor: _surface,
              color: cfg.cor,
              minHeight: 3,
            ),

            // ── Conteúdo rolável ──
            Expanded(
              child: SingleChildScrollView(
                controller: _scroll,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 40,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Botão voltar + chip de categoria ──
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: widget.onVoltar,
                          icon: const Icon(Icons.arrow_back,
                              size: 16, color: _textSecondary),
                          label: const Text('Voltar',
                              style: TextStyle(color: _textSecondary)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: cfg.cor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: cfg.cor.withOpacity(0.3)),
                          ),
                          child: Text(
                            cfg.categoria,
                            style: TextStyle(
                              color: cfg.cor, fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Ícone ──
                    Center(
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: cfg.cor.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: cfg.cor.withOpacity(0.3), width: 1.5),
                        ),
                        child: Icon(cfg.icone, color: cfg.cor, size: 36),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Título ──
                    Center(
                      child: Text(
                        cfg.titulo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _textPrimary, fontSize: 24,
                          fontWeight: FontWeight.w700, height: 1.3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Imagem ──
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        cfg.imagem,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: _surface2,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: cfg.cor, strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: _surface2,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(cfg.icone, color: cfg.cor, size: 48),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Parágrafos ──
                    ...cfg.paragrafos.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        p,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 15,
                          height: 1.7,
                        ),
                      ),
                    )),

                    const SizedBox(height: 32),

                    // ── Botão voltar final ──
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: widget.onVoltar,
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Voltar ao início'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cfg.cor,
                          side: BorderSide(color: cfg.cor.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



















/*
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistrade/pages/meumapa_page.dart';
import '../../pages/planetas_page.dart';
import '../../pages/grausPermanentes_page.dart';
import '../../pages/grausCalculados_page.dart';
import '../../pages/grausplanetas_page.dart';
import '../../pages/profile_page.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onMenuItemSelected;

  const DashboardScreen({
    super.key,
    required this.onMenuItemSelected,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  String nome = 'Usuário';
  int _pagina = 0;
  bool processando = false;

  final Map<String, int> rotas = {
    "home": 0,
    "mapa": 1,
    "perfil": 2,

    "ciclos": 3,
    "futuro": 4,
    "natureza": 5,
    "tempo": 6,

    "cadastro": 7,
    "processamento": 8,
    "geracao": 9,
    "visualizacao": 10,
  };

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

  @override
  Widget build(BuildContext context) {
    //final isMobile = MediaQuery.of(context).size.width < 600;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        title: const Text("Controle total da sua jornada"),
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

      body: _buildPagina(),

    );


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

    try{
      //if(index == 1)
      _mostrarLoading(context);
      widget.onMenuItemSelected(index);

      setState(() => processando = false);
    }finally{
      _fecharLoading(context);
    }
   // Navigator.pop(context);
  }


  Widget _buildPagina() {
    switch (_pagina) {
      case 0:
        return _home();
      case 1:
        return  _MapaPage(onVoltar: () => setState(() => _pagina = 0),);
      case 2:
        return  _PerfilPage(onVoltar: () => setState(() => _pagina = 0),);

      case 3:
        return  _CiclosPage(onVoltar: () => setState(() => _pagina = 0),);
      case 4:
        return  _FuturoPage(onVoltar: () => setState(() => _pagina = 0),);
      case 5:
        return  _NaturezaPage(onVoltar: () => setState(() => _pagina = 0),);
      case 6:
        return  _TempoPage(onVoltar: () => setState(() => _pagina = 0),);

      case 7:
        return  _CadastroPage(onVoltar: () => setState(() => _pagina = 0),);
      case 8:
        return  _ProcessamentoPage(onVoltar: () => setState(() => _pagina = 0),);
      case 9:
        return  _GeracaoPage(onVoltar: () => setState(() => _pagina = 0),);
      case 10:
        return  _VisualizacaoPage(onVoltar: () => setState(() => _pagina = 0),);

      default:
        return _home();
    }
  }

 // ================= HOME =================
   Widget _home() {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _hero(),

          const SizedBox(height: 30),

          _titulo("O que é o ciclo da vida?"),

          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _card("Ciclos", Icons.loop, 3),
              _card("Futuro", Icons.visibility, 4),
              _card("Natureza", Icons.eco, 5),
              _card("Tempo", Icons.access_time, 6),
            ],
          ),

          const SizedBox(height: 30),

          _titulo("Como funciona?"),

          _link("Cadastro inicial", 7),
          _link("Processamento dos dados", 8),
          _link("Geração dos ciclos", 9),
          _link("Visualização completa", 10),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bem-vindo 👋", style: TextStyle(color: Colors.white70)),
          SizedBox(height: 10),
          Text(
            "Controle total da sua jornada",
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
        ],
      ),
    );
  }

  Widget _titulo(String t) {
    return Text(
      t,
      style: const TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _card(String t, IconData icon, int pagina) {
    return InkWell(
      onTap: () => setState(() => _pagina = pagina),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.cyan, size: 32),
            const SizedBox(height: 10),
            Text(t, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _link(String t, int pagina) {
    return ListTile(
      title: Text(t, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward, color: Colors.white54),
      onTap: () => setState(() => _pagina = pagina),
    );
  }


  // ================= NAV =================
  void _open(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Text(
              nome.isNotEmpty ? nome[0].toUpperCase() : "U",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bem-vindo, $nome 👋",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Controle total da sua jornada",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= TITLE =================
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  // ================= CARD AÇÃO =================
  Widget _quickCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 1.0, end: 1.0),
      duration: const Duration(milliseconds: 150),
      builder: (context, scale, child) {
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 30),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= BENEFIT =================
  Widget _benefitCard(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ================= INFO =================
  Widget _infoCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.blueGrey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "📚 Como funciona?",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text("1. Cadastro inicial", style: TextStyle(color: Colors.white70)),
          Text("2. Processamento dos dados", style: TextStyle(color: Colors.white70)),
          Text("3. Geração dos ciclos", style: TextStyle(color: Colors.white70)),
          Text("4. Visualização completa", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
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


}



// ================= CONFIG GLOBAL =================
const double fontSizeGlobal = 15;
const Color fontColorGlobal = Colors.white70;
const String fontFamilyGlobal = 'Arial';

// ================= BASE PADRÃO =================
Widget _pageModelo({
  required String titulo,
  required IconData icone,
  required String imagem,
  required List<String> textos,
  required VoidCallback onVoltar, // 🔥 NOVO
}) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        // 🔥 BOTÃO VOLTAR CORRETO
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: onVoltar,
            icon: const Icon(Icons.arrow_back),
            label: const Text("Voltar"),
          ),
        ),

        const SizedBox(height: 20),

        Icon(icone, size: 80, color: Colors.cyan),

        const SizedBox(height: 16),

        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(imagem, height: 200, fit: BoxFit.cover),
        ),

        const SizedBox(height: 20),

        ...textos.map((t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                t,
                textAlign: TextAlign.justify,
                style: const TextStyle(color: Colors.white70),
              ),
            )),
      ],
    ),
  );
}

class _CiclosPage extends StatelessWidget {
  final VoidCallback onVoltar;

  const _CiclosPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // 🔥 ESSENCIAL
            children: [

              // ================= VOLTAR =================
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: onVoltar,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Voltar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= ÍCONE =================
              const Icon(
                Icons.loop,
                size: 80,
                color: Colors.cyan,
              ),

              const SizedBox(height: 16),

              // ================= TÍTULO =================
              const Text(
                "Ciclos da Vida",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // ================= IMAGEM =================
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee",
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              // ================= TEXTO =================
              _texto(
                "A vida é construída sobre ciclos que se repetem constantemente ao longo do tempo. "
                "Esses ciclos não são aleatórios, mas seguem padrões organizados que podem ser observados com atenção. "
                "Desde os movimentos da natureza até as emoções humanas, tudo parece obedecer a uma lógica cíclica invisível.",
              ),

              _texto(
                "Quando você começa a perceber esses padrões, passa a entender melhor os momentos de crescimento, pausa e transformação. "
                "Nada acontece de forma isolada, tudo faz parte de um fluxo contínuo que se repete com pequenas variações.",
              ),

              _texto(
                "Os ciclos também explicam por que certas situações voltam a acontecer na sua vida. "
                "Isso não significa erro, mas sim oportunidade de aprendizado e evolução pessoal.",
              ),

              _texto(
                "Ao compreender os ciclos, você ganha clareza sobre decisões importantes, evitando agir por impulso. "
                "Você passa a agir com estratégia, respeitando o momento certo de avançar ou recuar.",
              ),

              _texto(
                "Existe um tempo para plantar, um tempo para crescer e um tempo para colher. "
                "Ignorar isso pode gerar frustração, enquanto respeitar os ciclos gera resultados mais consistentes.",
              ),

              _texto(
                "Os ciclos não são apenas externos, mas também internos. "
                "Seus pensamentos, emoções e comportamentos também seguem padrões repetitivos que podem ser identificados.",
              ),

              _texto(
                "Com o tempo, você percebe que dominar os ciclos é, na verdade, dominar a si mesmo. "
                "E essa é uma das habilidades mais poderosas que alguém pode desenvolver.",
              ),

              _texto(
                "Ao reconhecer padrões, você deixa de ser refém das circunstâncias e passa a ter controle sobre sua trajetória. "
                "Isso traz mais segurança, confiança e direção para sua vida.",
              ),

              _texto(
                "A repetição não é um problema — ela é um sinal. "
                "Um indicativo de que existe algo a ser compreendido e integrado.",
              ),

              _texto(
                "No final, entender os ciclos significa enxergar a vida com mais profundidade, clareza e consciência, "
                "permitindo que você evolua de forma constante e estruturada.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= MÉTODO TEXTO =================
  Widget _texto(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          texto,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white70,
            height: 1.5, // 🔥 melhora MUITO leitura
          ),
        ),
      ),
    );
  }

}

class _FuturoPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _FuturoPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // 🔥 ESSENCIAL
            children: [

              // ================= VOLTAR =================
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: onVoltar,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Voltar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= ÍCONE =================
              const Icon(
                Icons.visibility,
                size: 80,
                color: Colors.cyan,
              ),

              const SizedBox(height: 16),

              // ================= TÍTULO =================
              const Text(
                "Previsão do Futuro",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // ================= IMAGEM =================
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              // ================= TEXTO =================
              _texto(
                "O futuro não é totalmente aleatório."
                "Ele é influenciado por padrões que já aconteceram antes."
                "A repetição de eventos permite projeções mais precisas."
                "Ao entender o passado, você antecipa o futuro."
                "A análise correta reduz riscos e incertezas."
                "Não se trata de adivinhação, mas de lógica e observação."
                "Os sinais estão sempre presentes, basta saber ler."
                "Decisões melhores surgem com visão ampliada."
                "O futuro é uma consequência do presente."
                "Quem entende padrões, controla probabilidades."
              ),

            ],
          ),
        ),
      ),
    );
  }

  // ================= MÉTODO TEXTO =================
  Widget _texto(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          texto,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white70,
            height: 1.5, // 🔥 melhora MUITO leitura
          ),
        ),
      ),
    );
  }

}

class _NaturezaPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _NaturezaPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // 🔥 ESSENCIAL
            children: [

              // ================= VOLTAR =================
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: onVoltar,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Voltar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= ÍCONE =================
              const Icon(
                Icons.eco,
                size: 80,
                color: Colors.cyan,
              ),

              const SizedBox(height: 16),

              // ================= TÍTULO =================
              const Text(
                "Ritmos da Natureza",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // ================= IMAGEM =================
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  "https://images.unsplash.com/photo-1441974231531-c6227db76b6e",
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              // ================= TEXTO =================
              _texto(
                "A natureza funciona em ciclos perfeitos."
                "As estações são um exemplo claro disso."
                "Tudo cresce, amadurece e se transforma."
                "Nada acontece por acaso."
                "Existe uma ordem invisível guiando os processos."
                "O ser humano também faz parte desses ritmos."
                "Ignorar isso gera desequilíbrio."
                "Seguir os ciclos traz harmonia."
                "A natureza ensina adaptação constante."
                "Observar a natureza é aprender sobre a vida."
              ),

            ],
          ),
        ),
      ),
    );
  }

  // ================= MÉTODO TEXTO =================
  Widget _texto(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          texto,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white70,
            height: 1.5, // 🔥 melhora MUITO leitura
          ),
        ),
      ),
    );
  }



}

class _TempoPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _TempoPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // 🔥 ESSENCIAL
            children: [

              // ================= VOLTAR =================
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: onVoltar,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Voltar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= ÍCONE =================
              const Icon(
                Icons.access_time,
                size: 80,
                color: Colors.cyan,
              ),

              const SizedBox(height: 16),

              // ================= TÍTULO =================
              const Text(
                "Tempo e Padrões",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // ================= IMAGEM =================
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  "https://images.unsplash.com/photo-1501139083538-0139583c060f",
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              // ================= TEXTO =================
              _texto(
                  "O tempo é a base de todos os ciclos."
                  "Ele organiza eventos em sequência lógica."
                  "Sem tempo não há mudança."
                  "Tudo acontece dentro de intervalos."
                  "Os padrões são distribuídos ao longo do tempo."
                  "Compreender isso é essencial para análise."
                  "O tempo revela padrões ocultos."
                  "Cada momento tem seu propósito."
                  "A percepção do tempo muda decisões."
                  "Quem entende o tempo, entende a vida."
              ),

            ],
          ),
        ),
      ),
    );
  }

  // ================= MÉTODO TEXTO =================
  Widget _texto(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          texto,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white70,
            height: 1.5, // 🔥 melhora MUITO leitura
          ),
        ),
      ),
    );
  }


}

class _CadastroPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _CadastroPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // 🔥 ESSENCIAL
            children: [

              // ================= VOLTAR =================
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: onVoltar,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Voltar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= ÍCONE =================
              const Icon(
                Icons.person_add,
                size: 80,
                color: Colors.cyan,
              ),

              const SizedBox(height: 16),

              // ================= TÍTULO =================
              const Text(
                "Cadastro Inicial",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // ================= IMAGEM =================
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  "https://images.unsplash.com/photo-1521737604893-d14cc237f11d",
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              // ================= TEXTO =================
              _texto(
                "O início de tudo está nos dados."
                "Informações corretas geram resultados precisos."
                "Cada detalhe influencia o cálculo."
                "O sistema depende da base inicial."
                "Quanto mais preciso, melhor o resultado."
                "Os dados representam sua realidade."
                "Eles são transformados em padrões."
                "O cadastro é o primeiro passo."
                "Sem ele não há análise."
                "Tudo começa aqui."
              ),

            ],
          ),
        ),
      ),
    );
  }

  // ================= MÉTODO TEXTO =================
  Widget _texto(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          texto,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white70,
            height: 1.5, // 🔥 melhora MUITO leitura
          ),
        ),
      ),
    );
  }



}

class _ProcessamentoPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _ProcessamentoPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // 🔥 ESSENCIAL
            children: [

              // ================= VOLTAR =================
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: onVoltar,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Voltar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= ÍCONE =================
              const Icon(
                Icons.settings,
                size: 80,
                color: Colors.cyan,
              ),

              const SizedBox(height: 16),

              // ================= TÍTULO =================
              const Text(
                "Processamento",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // ================= IMAGEM =================
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  "https://images.unsplash.com/photo-1518770660439-4636190af475",
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              // ================= TEXTO =================
              _texto(
                "Os dados passam por análise complexa."
                "Algoritmos identificam padrões."
                "Tudo é transformado em informação útil."
                "O processamento é o coração do sistema."
                "Ele conecta dados e resultados."
                "Cada cálculo segue uma lógica definida."
                "Nada é feito de forma aleatória."
                "O sistema organiza tudo automaticamente."
                "A precisão depende desse processo."
                "É aqui que tudo ganha sentido."
              ),

            ],
          ),
        ),
      ),
    );
  }

  // ================= MÉTODO TEXTO =================
  Widget _texto(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          texto,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white70,
            height: 1.5, // 🔥 melhora MUITO leitura
          ),
        ),
      ),
    );
  }





}

class _GeracaoPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _GeracaoPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // 🔥 ESSENCIAL
            children: [

              // ================= VOLTAR =================
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: onVoltar,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Voltar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= ÍCONE =================
              const Icon(
                Icons.autorenew,
                size: 80,
                color: Colors.cyan,
              ),

              const SizedBox(height: 16),

              // ================= TÍTULO =================
              const Text(
                "Geração de Ciclos",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // ================= IMAGEM =================
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  "https://images.unsplash.com/photo-1504384308090-c894fdcc538d",
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              // ================= TEXTO =================
              _texto(
                "Os ciclos são gerados automaticamente."
                "Baseados nos dados processados."
                "Cada ciclo representa uma fase."
                "As fases se conectam entre si."
                "Nada é isolado."
                "Tudo segue continuidade."
                "A geração revela padrões ocultos."
                "Permite prever comportamentos."
                "Organiza a informação."
                "Transforma dados em visão."
              ),

            ],
          ),
        ),
      ),
    );
  }

  // ================= MÉTODO TEXTO =================
  Widget _texto(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          texto,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white70,
            height: 1.5, // 🔥 melhora MUITO leitura
          ),
        ),
      ),
    );
  }



}

class _VisualizacaoPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _VisualizacaoPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // 🔥 ESSENCIAL
            children: [

              // ================= VOLTAR =================
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: onVoltar,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Voltar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= ÍCONE =================
              const Icon(
                Icons.bar_chart,
                size: 80,
                color: Colors.cyan,
              ),

              const SizedBox(height: 16),

              // ================= TÍTULO =================
              const Text(
                "Visualização",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // ================= IMAGEM =================
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  "https://images.unsplash.com/photo-1551288049-bebda4e38f71",
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              // ================= TEXTO =================
              _texto(
                "Os dados são exibidos de forma clara."
                "Gráficos facilitam entendimento."
                "Tudo é organizado visualmente."
                "A interpretação se torna simples."
                "Os padrões ficam evidentes."
                "Visualizar é compreender."
                "Informação bem apresentada é poderosa."
                "A análise se torna intuitiva."
                "Tudo está ao seu alcance."
                "Agora você vê o todo."
              ),

            ],
          ),
        ),
      ),
    );
  }

  // ================= MÉTODO TEXTO =================
  Widget _texto(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          texto,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white70,
            height: 1.5, // 🔥 melhora MUITO leitura
          ),
        ),
      ),
    );
  }




}

class _MapaPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _MapaPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // 🔥 ESSENCIAL
            children: [

              // ================= VOLTAR =================
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: onVoltar,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Voltar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= ÍCONE =================
              const Icon(
                Icons.map,
                size: 80,
                color: Colors.cyan,
              ),

              const SizedBox(height: 16),

              // ================= TÍTULO =================
              const Text(
                "Meu Mapa",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // ================= IMAGEM =================
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  "https://images.unsplash.com/photo-1501785888041-af3ef285b470",
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              // ================= TEXTO =================
              _texto(
                  "Seu mapa representa sua jornada."
                  "Ele reúne todos os dados."
                  "Mostra padrões pessoais."
                  "Ajuda na tomada de decisão."
                  "Organiza sua vida."
                  "Tudo está conectado."
                  "O mapa é único."
                  "Reflete sua realidade."
                  "Permite análise profunda."
                  "É sua ferramenta principal."
              ),

            ],
          ),
        ),
      ),
    );
  }

  // ================= MÉTODO TEXTO =================
  Widget _texto(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          texto,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white70,
            height: 1.5, // 🔥 melhora MUITO leitura
          ),
        ),
      ),
    );
  }




}

class _PerfilPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _PerfilPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // 🔥 ESSENCIAL
            children: [

              // ================= VOLTAR =================
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: onVoltar,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Voltar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= ÍCONE =================
              const Icon(
                Icons.person,
                size: 80,
                color: Colors.cyan,
              ),

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
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  "https://images.unsplash.com/photo-1494790108377-be9c29b29330",
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              // ================= TEXTO =================
              _texto(
                  "Seu perfil contém suas informações."
                  "Ele personaliza sua experiência."
                  "Define como o sistema responde."
                  "É a base do seu uso."
                  "Permite ajustes."
                  "Centraliza dados."
                  "Mantém consistência."
                  "Facilita atualizações."
                  "Garante precisão."
                  "Representa você no sistema."
              ),

            ],
          ),
        ),
      ),
    );
  }

  // ================= MÉTODO TEXTO =================
  Widget _texto(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          texto,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white70,
            height: 1.5, // 🔥 melhora MUITO leitura
          ),
        ),
      ),
    );
  }



}
*/











/*
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onMenuItemSelected;

  const DashboardScreen({super.key, required this.onMenuItemSelected,});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _pagina = 0;

  final Map<String, int> rotas = {
    "home": 0,
    "mapa": 1,
    "perfil": 2,

    "ciclos": 3,
    "futuro": 4,
    "natureza": 5,
    "tempo": 6,

    "cadastro": 7,
    "processamento": 8,
    "geracao": 9,
    "visualizacao": 10,
  };

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        title: const Text("Controle total da sua jornada"),
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

      body: _buildPagina(),

      /*bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: _pagina > 2 ? 0 : _pagina,
              backgroundColor: Colors.blueGrey.shade900,
              selectedItemColor: Colors.cyan,
              unselectedItemColor: Colors.white54,
              onTap: (i) => setState(() => _pagina = i),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(icon: Icon(Icons.map), label: "Mapa"),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
              ],
            )
          : null,*/
    );
  }

  Widget _menuButton(String title, int index) {
    return TextButton(
      onPressed: () => setState(() => _pagina = index),
      child: Text(title, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildPagina() {
    switch (_pagina) {
      case 0:
        return _home();
      case 1:
        return  _MapaPage(onVoltar: () => setState(() => _pagina = 0),);
      case 2:
        return  _PerfilPage(onVoltar: () => setState(() => _pagina = 0),);

      case 3:
        return  _CiclosPage(onVoltar: () => setState(() => _pagina = 0),);
      case 4:
        return  _FuturoPage(onVoltar: () => setState(() => _pagina = 0),);
      case 5:
        return  _NaturezaPage(onVoltar: () => setState(() => _pagina = 0),);
      case 6:
        return  _TempoPage(onVoltar: () => setState(() => _pagina = 0),);

      case 7:
        return  _CadastroPage(onVoltar: () => setState(() => _pagina = 0),);
      case 8:
        return  _ProcessamentoPage(onVoltar: () => setState(() => _pagina = 0),);
      case 9:
        return  _GeracaoPage(onVoltar: () => setState(() => _pagina = 0),);
      case 10:
        return  _VisualizacaoPage(onVoltar: () => setState(() => _pagina = 0),);

      default:
        return _home();
    }
  }

  // ================= HOME =================
  Widget _home() {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _hero(),

          const SizedBox(height: 30),

          _titulo("O que é o ciclo da vida?"),

          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _card("Ciclos", Icons.loop, 3),
              _card("Futuro", Icons.visibility, 4),
              _card("Natureza", Icons.eco, 5),
              _card("Tempo", Icons.access_time, 6),
            ],
          ),

          const SizedBox(height: 30),

          _titulo("Como funciona?"),

          _link("Cadastro inicial", 7),
          _link("Processamento dos dados", 8),
          _link("Geração dos ciclos", 9),
          _link("Visualização completa", 10),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bem-vindo 👋", style: TextStyle(color: Colors.white70)),
          SizedBox(height: 10),
          Text(
            "Controle total da sua jornada",
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
        ],
      ),
    );
  }

  Widget _titulo(String t) {
    return Text(
      t,
      style: const TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _card(String t, IconData icon, int pagina) {
    return InkWell(
      onTap: () => setState(() => _pagina = pagina),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.cyan, size: 32),
            const SizedBox(height: 10),
            Text(t, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _link(String t, int pagina) {
    return ListTile(
      title: Text(t, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward, color: Colors.white54),
      onTap: () => setState(() => _pagina = pagina),
    );
  }
}

// ================= PÁGINAS =================
/*
Widget _pageBase(String titulo, IconData icon, String texto) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Icon(icon, size: 80, color: Colors.cyan),
        const SizedBox(height: 20),
        Text(
          titulo,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(texto, textAlign: TextAlign.center),
      ],
    ),
  );
}
*/

// ================= CONFIG GLOBAL =================
const double fontSizeGlobal = 15;
const Color fontColorGlobal = Colors.white70;
const String fontFamilyGlobal = 'Arial';

// ================= BASE PADRÃO =================
Widget _pageModelo({
  required String titulo,
  required IconData icone,
  required String imagem,
  required List<String> textos,
  required VoidCallback onVoltar, // 🔥 NOVO
}) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        // 🔥 BOTÃO VOLTAR CORRETO
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: onVoltar,
            icon: const Icon(Icons.arrow_back),
            label: const Text("Voltar"),
          ),
        ),

        const SizedBox(height: 20),

        Icon(icone, size: 80, color: Colors.cyan),

        const SizedBox(height: 16),

        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(imagem, height: 200, fit: BoxFit.cover),
        ),

        const SizedBox(height: 20),

        ...textos.map((t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                t,
                textAlign: TextAlign.justify,
                style: const TextStyle(color: Colors.white70),
              ),
            )),
      ],
    ),
  );
}

/*
Widget _pageModelo({
  required BuildContext context,
  required String titulo,
  required IconData icone,
  required String imagem,
  required List<String> textos,
}) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        // BOTÃO VOLTAR
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            //onPressed: () =>Navigator.push( context, MaterialPageRoute(builder: (_) => page),  );
            icon: const Icon(Icons.arrow_back),
            label: const Text("Voltar"),
          ),
        ),

        const SizedBox(height: 20),

        Icon(icone, size: 80, color: Colors.cyan),

        const SizedBox(height: 16),

        Text(
          titulo,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamilyGlobal,
          ),
        ),

        const SizedBox(height: 20),

        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(imagem, height: 200, fit: BoxFit.cover),
        ),

        const SizedBox(height: 20),

        ...textos.map((t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                t,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: fontSizeGlobal,
                  color: fontColorGlobal,
                  fontFamily: fontFamilyGlobal,
                ),
              ),
            )),
      ],
    ),
  );
}
*/

/*
class _CiclosPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _CiclosPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return _pageModelo(
     // context: context,
      titulo: "Ciclos da Vida",
      icone: Icons.loop,
      imagem: "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee",
      textos: [
        "A vida é construída sobre ciclos que se repetem constantemente.",
        "Tudo o que existe segue padrões que podem ser observados e compreendidos.",
        "Os ciclos não são apenas naturais, mas também emocionais e mentais.",
        "Entender esses ciclos permite maior controle sobre decisões importantes.",
        "Os momentos de crescimento e retração fazem parte da mesma dinâmica.",
        "Nada permanece estático, tudo está em transformação contínua.",
        "Ao reconhecer padrões, evitamos erros repetitivos.",
        "Os ciclos também indicam oportunidades futuras.",
        "A repetição não é falha, mas um mecanismo de aprendizado.",
        "Dominar os ciclos é dominar a própria jornada."
      ],
      onVoltar: onVoltar, // 🔥 AQUI
    );
  }
}
*/

class _CiclosPage extends StatelessWidget {
  final VoidCallback onVoltar;

  const _CiclosPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // 🔥 ESSENCIAL
            children: [

              // ================= VOLTAR =================
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: onVoltar,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Voltar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= ÍCONE =================
              const Icon(
                Icons.loop,
                size: 80,
                color: Colors.cyan,
              ),

              const SizedBox(height: 16),

              // ================= TÍTULO =================
              const Text(
                "Ciclos da Vida",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // ================= IMAGEM =================
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee",
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              // ================= TEXTO =================
              _texto(
                "A vida é construída sobre ciclos que se repetem constantemente ao longo do tempo. "
                "Esses ciclos não são aleatórios, mas seguem padrões organizados que podem ser observados com atenção. "
                "Desde os movimentos da natureza até as emoções humanas, tudo parece obedecer a uma lógica cíclica invisível.",
              ),

              _texto(
                "Quando você começa a perceber esses padrões, passa a entender melhor os momentos de crescimento, pausa e transformação. "
                "Nada acontece de forma isolada, tudo faz parte de um fluxo contínuo que se repete com pequenas variações.",
              ),

              _texto(
                "Os ciclos também explicam por que certas situações voltam a acontecer na sua vida. "
                "Isso não significa erro, mas sim oportunidade de aprendizado e evolução pessoal.",
              ),

              _texto(
                "Ao compreender os ciclos, você ganha clareza sobre decisões importantes, evitando agir por impulso. "
                "Você passa a agir com estratégia, respeitando o momento certo de avançar ou recuar.",
              ),

              _texto(
                "Existe um tempo para plantar, um tempo para crescer e um tempo para colher. "
                "Ignorar isso pode gerar frustração, enquanto respeitar os ciclos gera resultados mais consistentes.",
              ),

              _texto(
                "Os ciclos não são apenas externos, mas também internos. "
                "Seus pensamentos, emoções e comportamentos também seguem padrões repetitivos que podem ser identificados.",
              ),

              _texto(
                "Com o tempo, você percebe que dominar os ciclos é, na verdade, dominar a si mesmo. "
                "E essa é uma das habilidades mais poderosas que alguém pode desenvolver.",
              ),

              _texto(
                "Ao reconhecer padrões, você deixa de ser refém das circunstâncias e passa a ter controle sobre sua trajetória. "
                "Isso traz mais segurança, confiança e direção para sua vida.",
              ),

              _texto(
                "A repetição não é um problema — ela é um sinal. "
                "Um indicativo de que existe algo a ser compreendido e integrado.",
              ),

              _texto(
                "No final, entender os ciclos significa enxergar a vida com mais profundidade, clareza e consciência, "
                "permitindo que você evolua de forma constante e estruturada.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= MÉTODO TEXTO =================
  Widget _texto(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          texto,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white70,
            height: 1.5, // 🔥 melhora MUITO leitura
          ),
        ),
      ),
    );
  }
}

class _FuturoPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _FuturoPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return _pageModelo(
      //context: context,
      titulo: "Previsão do Futuro",
      icone: Icons.visibility,
      imagem: "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
      textos: [
        "O futuro não é totalmente aleatório.",
        "Ele é influenciado por padrões que já aconteceram antes.",
        "A repetição de eventos permite projeções mais precisas.",
        "Ao entender o passado, você antecipa o futuro.",
        "A análise correta reduz riscos e incertezas.",
        "Não se trata de adivinhação, mas de lógica e observação.",
        "Os sinais estão sempre presentes, basta saber ler.",
        "Decisões melhores surgem com visão ampliada.",
        "O futuro é uma consequência do presente.",
        "Quem entende padrões, controla probabilidades."
      ],
      onVoltar: onVoltar,
    );
  }
}

class _NaturezaPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _NaturezaPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return _pageModelo(
      //context: context,
      titulo: "Ritmos da Natureza",
      icone: Icons.eco,
      imagem: "https://images.unsplash.com/photo-1441974231531-c6227db76b6e",
      textos: [
        "A natureza funciona em ciclos perfeitos.",
        "As estações são um exemplo claro disso.",
        "Tudo cresce, amadurece e se transforma.",
        "Nada acontece por acaso.",
        "Existe uma ordem invisível guiando os processos.",
        "O ser humano também faz parte desses ritmos.",
        "Ignorar isso gera desequilíbrio.",
        "Seguir os ciclos traz harmonia.",
        "A natureza ensina adaptação constante.",
        "Observar a natureza é aprender sobre a vida."
      ],
      onVoltar: onVoltar,
    );
  }
}

class _TempoPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _TempoPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return _pageModelo(
      //context: context,
      titulo: "Tempo e Padrões",
      icone: Icons.access_time,
      imagem: "https://images.unsplash.com/photo-1501139083538-0139583c060f",
      textos: [
        "O tempo é a base de todos os ciclos.",
        "Ele organiza eventos em sequência lógica.",
        "Sem tempo não há mudança.",
        "Tudo acontece dentro de intervalos.",
        "Os padrões são distribuídos ao longo do tempo.",
        "Compreender isso é essencial para análise.",
        "O tempo revela padrões ocultos.",
        "Cada momento tem seu propósito.",
        "A percepção do tempo muda decisões.",
        "Quem entende o tempo, entende a vida."
      ],
      onVoltar: onVoltar,
    );
  }
}

class _CadastroPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _CadastroPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return _pageModelo(
      //context: context,
      titulo: "Cadastro Inicial",
      icone: Icons.person_add,
      imagem: "https://images.unsplash.com/photo-1521737604893-d14cc237f11d",
      textos: [
        "O início de tudo está nos dados.",
        "Informações corretas geram resultados precisos.",
        "Cada detalhe influencia o cálculo.",
        "O sistema depende da base inicial.",
        "Quanto mais preciso, melhor o resultado.",
        "Os dados representam sua realidade.",
        "Eles são transformados em padrões.",
        "O cadastro é o primeiro passo.",
        "Sem ele não há análise.",
        "Tudo começa aqui."
      ],
      onVoltar: onVoltar,
    );
  }
}

class _ProcessamentoPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _ProcessamentoPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return _pageModelo(
      //context: context,
      titulo: "Processamento",
      icone: Icons.settings,
      imagem: "https://images.unsplash.com/photo-1518770660439-4636190af475",
      textos: [
        "Os dados passam por análise complexa.",
        "Algoritmos identificam padrões.",
        "Tudo é transformado em informação útil.",
        "O processamento é o coração do sistema.",
        "Ele conecta dados e resultados.",
        "Cada cálculo segue uma lógica definida.",
        "Nada é feito de forma aleatória.",
        "O sistema organiza tudo automaticamente.",
        "A precisão depende desse processo.",
        "É aqui que tudo ganha sentido."
      ],
      onVoltar: onVoltar,
    );
  }
}

class _GeracaoPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _GeracaoPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return _pageModelo(
      //context: context,
      titulo: "Geração de Ciclos",
      icone: Icons.autorenew,
      imagem: "https://images.unsplash.com/photo-1504384308090-c894fdcc538d",
      textos: [
        "Os ciclos são gerados automaticamente.",
        "Baseados nos dados processados.",
        "Cada ciclo representa uma fase.",
        "As fases se conectam entre si.",
        "Nada é isolado.",
        "Tudo segue continuidade.",
        "A geração revela padrões ocultos.",
        "Permite prever comportamentos.",
        "Organiza a informação.",
        "Transforma dados em visão."
      ],
      onVoltar: onVoltar,
    );
  }
}

class _VisualizacaoPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _VisualizacaoPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return _pageModelo(
      //context: context,
      titulo: "Visualização",
      icone: Icons.bar_chart,
      imagem: "https://images.unsplash.com/photo-1551288049-bebda4e38f71",
      textos: [
        "Os dados são exibidos de forma clara.",
        "Gráficos facilitam entendimento.",
        "Tudo é organizado visualmente.",
        "A interpretação se torna simples.",
        "Os padrões ficam evidentes.",
        "Visualizar é compreender.",
        "Informação bem apresentada é poderosa.",
        "A análise se torna intuitiva.",
        "Tudo está ao seu alcance.",
        "Agora você vê o todo."
      ],
      onVoltar: onVoltar,
    );
  }
}

class _MapaPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _MapaPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return _pageModelo(
      //context: context,
      titulo: "Meu Mapa",
      icone: Icons.map,
      imagem: "https://images.unsplash.com/photo-1501785888041-af3ef285b470",
      textos: [
        "Seu mapa representa sua jornada.",
        "Ele reúne todos os dados.",
        "Mostra padrões pessoais.",
        "Ajuda na tomada de decisão.",
        "Organiza sua vida.",
        "Tudo está conectado.",
        "O mapa é único.",
        "Reflete sua realidade.",
        "Permite análise profunda.",
        "É sua ferramenta principal."
      ],
      onVoltar: onVoltar,
    );
  }
}

class _PerfilPage extends StatelessWidget {
  final VoidCallback onVoltar;
  const _PerfilPage({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return _pageModelo(
      //context: context,
      titulo: "Meu Perfil",
      icone: Icons.person,
      imagem: "https://images.unsplash.com/photo-1494790108377-be9c29b29330",
      textos: [
        "Seu perfil contém suas informações.",
        "Ele personaliza sua experiência.",
        "Define como o sistema responde.",
        "É a base do seu uso.",
        "Permite ajustes.",
        "Centraliza dados.",
        "Mantém consistência.",
        "Facilita atualizações.",
        "Garante precisão.",
        "Representa você no sistema."
      ],
      onVoltar: onVoltar,
    );
  }
}

*/






