class Usuario {
  final int? codusuario;
  final String? nome;
  final String? email;
  final DateTime? data_nascimento;
  final String? senha;
  final String? sexo;
  final String? endereco;
  final DateTime? data_cadastro;
  final DateTime? datainicial;
  final double? credito;
  final int? anos;

  Usuario({
    this.codusuario,
    this.nome,
    this.email,
    this.data_nascimento,
    this.senha,
    this.sexo,
    this.endereco,
    this.data_cadastro,
    this.datainicial,
    this.credito,
    this.anos,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      codusuario: json['codusuario'] as int?,
      nome: json['nome'] as String?,
      email: json['email'] as String?,
      data_nascimento: json['data_nascimento'] is String ? DateTime.parse(json['data_nascimento']) : json['data_nascimento'], 
      senha: json['senha'] as String?,
      sexo: json['sexo'] as String?,
      endereco: json['endereco'] as String?,
      data_cadastro: json['data_cadastro'] is String ? DateTime.parse(json['data_cadastro']) : json['data_cadastro'], 
      datainicial: json['datainicial'] is String ? DateTime.parse(json['datainicial']) : json['datainicial'], 
      credito: (json['credito'] as num?)?.toDouble(),
      anos: json['anos'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codusuario': codusuario,
      'nome': nome,
      'email': email,
      'data_nascimento': data_nascimento?.toIso8601String(),
      'senha': senha,
      'sexo': sexo,
      'endereco': endereco,
      'data_cadastro': data_cadastro?.toIso8601String(),
      'datainicial': datainicial?.toIso8601String(),
      'credito': credito,
      'anos': anos,
    };
  }
}
