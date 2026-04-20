import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/grauplaneta_model.dart';
import '../config.dart'; // importa o arquivo de configuração

class GrauPlanetaService {

  static const String Url = '${AppConfig.baseUrl}/api/grausplanetas';  
  
  static Future<List<GrauPlaneta>> getGrausPlanetasDropDown() async {
    //final prefs = await SharedPreferences.getInstance();

    final uri = Uri.parse(Url).replace();
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      return jsonData.map((e) => GrauPlaneta.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar graus de planetas');
    }
  }

  static Future<List<GrauPlaneta>> getGrausPlanetas({String? codciclo}) async {
    //final prefs = await SharedPreferences.getInstance();

    final queryParams = {
      'codciclo': codciclo ?? '',
    };

    final uri = Uri.parse(Url).replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      return jsonData.map((e) => GrauPlaneta.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar graus de planetas');
    }
  }

}
