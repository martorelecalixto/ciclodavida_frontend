class GrauPermanente {
  final int? codciclo;
  final int? dia;
  final int? mes;
  final int? ano;
  final int? grau;

  GrauPermanente({
    this.codciclo,
    this.dia,
    this.mes,
    this.ano,
    this.grau,
  });

  factory GrauPermanente.fromJson(Map<String, dynamic> json) {
    return GrauPermanente(
      codciclo: json['codciclo'] as int?,
      dia: json['dia'] as int?,
      mes: json['mes'] as int?,
      ano: json['ano'] as int?,
      grau: json['grau'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codciclo': codciclo,
      'dia': dia,
      'mes': mes,
      'ano': ano,
      'grau': grau,
    };
  }
}
