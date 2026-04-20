class Planeta {
  final int? codciclo;
  final String? nome;

  Planeta({
    this.codciclo,
    this.nome,
  });

  factory Planeta.fromJson(Map<String, dynamic> json) {
    return Planeta(
      codciclo: json['codciclo'] as int?,
      nome: json['nome'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codciclo': codciclo,
      'nome': nome,
    };
  }
}
