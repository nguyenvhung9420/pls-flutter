import 'package:pls_flutter/services/api_domain_url.dart';
import 'package:pls_flutter/services/api_service.dart';
import 'dart:async';
import 'dart:convert';

class AuthRepository {
  final String loginPath = "/get_token";

  APIService apiService = APIService(baseUrl: APIDomain.apiDomainUrl);

  Future<String?> login({required Map<String, dynamic> loginBody}) async {
    try {
      final response = await apiService.post(
        requestBody: {
          "username": loginBody["username"],
          "password": loginBody["password"]
        },
        urlPath: loginPath,
      );
      Map<String, dynamic> json = jsonDecode(response.toString());
      if (json.containsKey('token')) {
        String token = json['token'][0];
        return token;
      } else {
        throw Exception("Token not found in response");
      }
    } catch (e) {
      rethrow;
    }
  }
}
