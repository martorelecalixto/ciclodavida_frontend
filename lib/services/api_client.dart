import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'auth_service.dart'; // ajuste o caminho se seu AuthService estiver em outro lugar
import 'package:http/http.dart' as http;

class ApiClient {
  static Dio? _dio;
   static const String baseUrl = '${AppConfig.baseUrl}/api/nfse'; 

  static Dio get instance {
    if (_dio != null) return _dio!;

    print('ENTROU ApiClient');

    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl, // ex: "https://meu-servidor.com" ou "https://meu-servidor.com/api"
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {"Content-Type": "application/json"},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (request, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('accessToken');
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(request);
      },
      onError: (DioException error, handler) async {
        // só trata 401
        if (error.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          final refreshToken = prefs.getString('refreshToken');

          if (refreshToken != null) {
            try {
              // chama endpoint /refresh para obter novo accessToken
              final refreshResp = await Dio().post(
                '${AppConfig.baseUrl}/api/refresh',
                data: json.encode({'token': refreshToken}),
                options: Options(headers: {'Content-Type': 'application/json'}),
              );

              if (refreshResp.statusCode == 200) {
                final newAccessToken = refreshResp.data['accessToken'] ?? refreshResp.data['access_token'];

                if (newAccessToken != null) {
                  await prefs.setString('accessToken', newAccessToken);

                  // atualiza header e reexecuta requisição original
                  final opts = error.requestOptions;
                  opts.headers['Authorization'] = 'Bearer $newAccessToken';
                  final clone = await dio.fetch(opts);
                  return handler.resolve(clone);
                }
              }
            } catch (e) {
              // refresh falhou -> forçar logout
              await AuthService.logout();
              return handler.reject(error);
            }
          }

          // sem refresh token -> logout
          await AuthService.logout();
          return handler.reject(error);
        }

        return handler.next(error);
      },
    ));

    _dio = dio;
    return _dio!;
  }


  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');

    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get(String endpoint) async {
    print('+++$endpoint');
    final url = Uri.parse('$baseUrl$endpoint');
    print('***$url');

    return await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );
  }

}
