class GrauCalculado {
  final int? grau_a;
  final int? grau_b;
  final int? grau_c;
  final int? grau_x1;
  final int? grau_d;
  final int? grau_e;
  final int? grau_f;
  final int? grau_x2;
  final int? grau_g;
  final int? grau_h;

  GrauCalculado({
    this.grau_a,
    this.grau_b,
    this.grau_c,
    this.grau_x1,
    this.grau_d,
    this.grau_e,
    this.grau_f,
    this.grau_x2,
    this.grau_g,
    this.grau_h,
  });

  factory GrauCalculado.fromJson(Map<String, dynamic> json) {
    return GrauCalculado(
      grau_a: json['grau_a'] as int?,
      grau_b: json['grau_b'] as int?,
      grau_c: json['grau_c'] as int?,
      grau_x1: json['grau_x1'] as int?,
      grau_d: json['grau_d'] as int?,
      grau_e: json['grau_e'] as int?,
      grau_f: json['grau_f'] as int?,
      grau_x2: json['grau_x2'] as int?,
      grau_g: json['grau_g'] as int?,
      grau_h: json['grau_h'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grau_a': grau_a,
      'grau_b': grau_b,
      'grau_c': grau_c,
      'grau_x1': grau_x1,
      'grau_d': grau_d,
      'grau_e': grau_e,
      'grau_f': grau_f,
      'grau_x2': grau_x2,
      'grau_g': grau_g,
      'grau_h': grau_h,
    };
  }
}
