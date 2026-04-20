import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/graupermanente_model.dart';
import '../config.dart'; // importa o arquivo de configuração

class GrauPermanenteService {

  static const String Url = '${AppConfig.baseUrl}/api/grauspermanentes';  
  
  static Future<List<GrauPermanente>> getGrausPermanentesDropDown() async {
    //final prefs = await SharedPreferences.getInstance();

    final uri = Uri.parse(Url).replace();
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      return jsonData.map((e) => GrauPermanente.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar graus perpetuos');
    }
  }

  static Future<List<GrauPermanente>> getGrausPermanentes({int? dia, int? mes}) async {
    //final prefs = await SharedPreferences.getInstance();
    //print(" service getGrausPermanentes ::: Parâmetros para Grau Permanente: dia=$dia, mes=$mes"); // debug para verificar os parâmetros
    final queryParams = {
      'dia': dia.toString() ?? '',
      'mes': mes.toString() ?? '',
    };

    final uri = Uri.parse(Url).replace(queryParameters: queryParams);
    //print("URL Requisição Grau Permanente: $uri"); // debug para verificar a URL da requisição

    final response = await http.get(uri);
    //print("Resposta Grau Permanente: ${response.body}"); // debug para verificar a resposta do servidor

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      return jsonData.map((e) => GrauPermanente.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar graus permanente');
    }
  }

}
