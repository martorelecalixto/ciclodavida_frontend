import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/graucalculado_model.dart';
import '../config.dart'; // importa o arquivo de configuração

class GrauCalculadoService {

  static const String Url = '${AppConfig.baseUrl}/api/grauscalculados';  
  
  static Future<List<GrauCalculado>> getGrausCalculadosDropDown() async {
    //final prefs = await SharedPreferences.getInstance();

    final uri = Uri.parse(Url).replace();
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      return jsonData.map((e) => GrauCalculado.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar graus calculados');
    }
  }

  static Future<List<GrauCalculado>> getGrausCalculados({String? grau_a}) async {
    //final prefs = await SharedPreferences.getInstance();

    final queryParams = {
      'grau_a': grau_a ?? '',
    };

    final uri = Uri.parse(Url).replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      return jsonData.map((e) => GrauCalculado.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar graus calculados');
    }
  }

}
