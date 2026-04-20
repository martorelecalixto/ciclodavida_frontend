class GrauPlaneta {
  final int? codtabela;
  final int? codciclo;
  final int? dia;
  final int? mes;
  final int? ano;
  final int? grau;
  final DateTime? data;
  final String? nome;

  GrauPlaneta({
    this.codtabela,
    this.codciclo,
    this.dia,
    this.mes,
    this.ano,
    this.grau,
    this.data,
    this.nome,
  });

  factory GrauPlaneta.fromJson(Map<String, dynamic> json) {
    return GrauPlaneta(
      codtabela: json['codtabela'] as int?,
      codciclo: json['codciclo'] as int?,
      dia: json['dia'] as int?,
      mes: json['mes'] as int?,
      ano: json['ano'] as int?,
      grau: json['grau'] as int?,
      data: json['data'] != null ? DateTime.parse(json['data']) : null,
      nome: json['nome'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codtabela': codtabela,
      'codciclo': codciclo,
      'dia': dia,
      'mes': mes,
      'ano': ano,
      'grau': grau,
      'data': data,
      'nome': nome,
    };
  }
}
