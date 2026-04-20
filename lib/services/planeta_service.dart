import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/planeta_model.dart';
import '../config.dart'; // importa o arquivo de configuração

class PlanetaService {

  static const String Url = '${AppConfig.baseUrl}/api/planetas';  
  
  static Future<List<Planeta>> getPlanetasDropDown() async {
    //final prefs = await SharedPreferences.getInstance();

    final uri = Uri.parse(Url).replace();
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      return jsonData.map((e) => Planeta.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar planetas');
    }
  }

  static Future<List<Planeta>> getPlanetas({String? nome}) async {
    //final prefs = await SharedPreferences.getInstance();

    final queryParams = {
      'nome': nome ?? '',
    };

    final uri = Uri.parse(Url).replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      return jsonData.map((e) => Planeta.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar planetas');
    }
  }

}
