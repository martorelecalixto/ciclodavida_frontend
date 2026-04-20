import 'dart:io';
import 'package:http/http.dart' as http;
import '../config.dart';

class EmailService {
  static const String baseUrl = '${AppConfig.baseUrl}/api/email';

  static Future<void> enviarEmail({
    required String from,
    required String to,
    required String subject,
    required String body,
    List<File>? anexos,
  }) async {
    print('ENTROU enviarEmail');

    final request = http.MultipartRequest('POST', Uri.parse(baseUrl))
      ..fields['from'] = from
      ..fields['to'] = to
      ..fields['subject'] = subject
      ..fields['body'] = body;

    if (anexos != null && anexos.isNotEmpty) {
      for (final file in anexos) {
        print('Adicionando anexo: ${file.path}');
        request.files.add(await http.MultipartFile.fromPath('attachments', file.path));
      }
    }

    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    print('Resposta: $respStr');

    if (response.statusCode != 200) {
      throw Exception('Falha ao enviar e-mail: $respStr');
    }
  }
}


/*versao 1
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';


class EmailService {
  static const String baseUrl = '${AppConfig.baseUrl}/api/email';//'http://localhost:3001/api/email/send';

  static Future<void> enviarEmail({
    required String from,
    required String to,
    required String subject,
    required String body,
    List<File>? anexos,
  }) async {
    print('ENTROU enviarEmail');
    final request = http.MultipartRequest('POST', Uri.parse(baseUrl))
      ..fields['from'] = from
      ..fields['to'] = to
      ..fields['subject'] = subject
      ..fields['body'] = body;

    print(baseUrl);
    if (anexos != null){
      for (final file in anexos) {
        request.files.add(await http.MultipartFile.fromPath('attachments', file.path));
      }
    }

    final response = await request.send();
    print(response.toString());
    if (response.statusCode != 200) {
      throw Exception('Falha ao enviar e-mail.');
    }
  }
}
*/