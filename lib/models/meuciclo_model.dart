class MeuCiclo {
  final int? codciclo;
  final String? nome;
  final int? grau;
  final DateTime? data_0;
  final DateTime? data;
  final DateTime? data_1;
  final int? fase;
  final String? letra;
  String? datastring;

  MeuCiclo({
    this.codciclo,
    this.nome,
    this.grau,
    this.data_0,
    this.data,
    this.data_1,
    this.fase,
    this.letra,
    this.datastring,
  });

  factory MeuCiclo.fromJson(Map<String, dynamic> json) {
    return MeuCiclo(
      codciclo: json['codciclo'] as int?,
      nome: json['nome'] as String?,
      grau: json['grau'] as int?,
      data_0: json['data_0'] != null ? DateTime.parse(json['data_0']) : null,
      data: json['data'] != null ? DateTime.parse(json['data']) : null,
      data_1: json['data_1'] != null ? DateTime.parse(json['data_1']) : null,
      fase: json['fase'] as int?,
      letra: json['letra'] as String?,
      datastring: json['datastring'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codciclo': codciclo,
      'nome': nome,
      'grau': grau,
      'data_0': data_0,
      'data': data,
      'data_1': data_1,
      'fase': fase,
      'letra': letra,
      'datastring': datastring,
    };
  }
}
