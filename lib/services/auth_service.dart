import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario_model.dart';
import '../config.dart';
import 'token_interceptor.dart'; // ✅ novo arquivo que criaremos

class AuthService {
  static const String apiUrl = AppConfig.baseUrl;
  static const String Url = '${AppConfig.baseUrl}/auth';
  static const String Url2 = '${AppConfig.baseUrl}/auth/verificaremail';
  static const String Url3 = '${AppConfig.baseUrl}/auth/dropdown';
  static const String Url4 = '${AppConfig.baseUrl}/auth/buscarinfo';

  // ===============================
  // LOGIN (atualizado com permissões)
  // ===============================
  static Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final url = Uri.parse('$apiUrl/auth/login');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      Map<String, dynamic> body;
      try {
        body = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        return {
          'success': false,
          'message':
              'Erro ao interpretar resposta do servidor. Resposta inesperada:\n${response.body}',
        };
      }

      if (response.statusCode == 200 && body['success'] == true) {
        final usuario = {
          'nome': body['nome'],
          'email': body['email'],
          'sexo': body['sexo'],
          'endereco': body['endereco'],
          'data_nascimento': body['data_nascimento'],
          'codusuario': body['codusuario'],
          'datainicial': body['datainicial'],
          'anos': body['anos'],
        };

        final token = body['fctoken'];


        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('codusuario', usuario['codusuario'] ?? 0);
        await prefs.setString('nome', usuario['nome'] ?? '');
        await prefs.setString('email', usuario['email'] ?? '');
        await prefs.setString('fctoken', token ?? '');
        await prefs.setString('sexo', usuario['sexo'] ?? '');
        await prefs.setString('data_nascimento', usuario['data_nascimento'] ?? '');
        await prefs.setString('endereco', usuario['endereco'] ?? '');
        await prefs.setString('datainicial', usuario['datainicial'] ?? '');
        await prefs.setInt('anos', usuario['anos'] ?? 0);


        return {
          'success': true,
          'message': body['message'] ?? 'Login realizado com sucesso',
          'user': usuario,
          'token': token,
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Erro ao realizar login',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  // ===============================
  // LOGOUT
  // ===============================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ===============================
  // RETORNAR DADOS LOCAIS DO USUÁRIO
  // ===============================
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'codusuario': prefs.getInt('codusuario'),
      'nome': prefs.getString('nome'),
      'email': prefs.getString('email'),
      'fctoken': prefs.getString('fctoken'),
      'sexo': prefs.getString('sexo'),
      'data_nascimento': prefs.getString('data_nascimento'),
      'endereco': prefs.getString('endereco'),
      'datainicial': prefs.getString('datainicial'),
      'anos': prefs.getInt('anos'),
    };
  }

  static Future<bool> deleteUsuario(int id) async {
    final response = await TokenInterceptor.delete(Uri.parse('$Url/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('$apiUrl/auth/forgot-password');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> resetPassword(
      String token, String newPassword) async {
    try {
      final url = Uri.parse('$apiUrl/auth/reset-password');
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'newPassword': newPassword}),
      );
      return jsonDecode(utf8.decode(resp.bodyBytes))
          as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Erro ao conectar ao servidor.'};
    }
  }

  static Future<String?> getEmail({required String email}) async {
    final queryParams = {'email': email};
    final uri = Uri.parse(Url2).replace(queryParameters: queryParams);

    final response = await TokenInterceptor.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['success'] == true) {
        return jsonData['email'];
      } else {
        return null;
      }
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Erro ao consultar email: ${response.statusCode}');
    }
  }

  static Future<bool> createUsuarios(Usuario usuario) async {
    //print('03.01');
    final urlCreate = Uri.parse('$apiUrl/auth/create');
    //print(urlCreate.toString());

    final response = await TokenInterceptor.post(
      urlCreate,
     // headers: {
     //   'Content-Type': 'application/json',
     //   'Accept': 'application/json',
     // },
      body: json.encode(usuario.toJson()),
    );

    /*final response = await TokenInterceptor.post(
      Uri.parse(url),
      body: json.encode(usuario.toJson()),
    );*/
    //print(response.body);
    return response.statusCode == 201;
  }

  static Future<bool> updateUsuario(Usuario usuario) async {
    final response = await TokenInterceptor.put(
      Uri.parse('$Url/${usuario.codusuario}'),
      body: json.encode(usuario.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<Usuario> getUsuarioById(String codusuario) async {
    final uri = Uri.parse('$Url4/$codusuario'); // <--- URL com o ID na rota
    //print(uri.toString());
    final response = await http.get(uri);
    //print(response.body);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Usuario.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      throw Exception('Usuário não encontrado');
    } else {
      throw Exception('Erro ao buscar usuário: ${response.reasonPhrase}');
    }
  }


}
