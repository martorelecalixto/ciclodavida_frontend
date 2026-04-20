class MeuGrafico {
  final int? eixo_x;
  final int? eixo_y;
  final String? datastring;
  final String? letra;
  final String? nome;

  MeuGrafico({
    this.eixo_x,
    this.eixo_y,
    this.datastring,
    this.letra,
    this.nome,
  });

  factory MeuGrafico.fromJson(Map<String, dynamic> json) {
    return MeuGrafico(
      eixo_x: json['eixo_x'] as int?,
      eixo_y: json['eixo_y'] as int?,
      datastring: json['datastring'] as String?,
      letra: json['letra'] as String?,
      nome: json['nome'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eixo_x': eixo_x,
      'eixo_y': eixo_y,
      'datastring': datastring,
      'letra': letra,
      'nome': nome,
    };
  }
}
