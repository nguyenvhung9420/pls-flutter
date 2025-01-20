import 'dart:async';
import 'dart:convert';
import 'package:pls_flutter/services/api_domain_url.dart';
import 'package:pls_flutter/services/api_service.dart';

class PLSRepository {
  final String healthPath = "/health";

  APIService apiService = APIService(baseUrl: APIDomain.apiDomainUrl);

  Future<Map<String, dynamic>?> getHealth(
      {required Map<String, dynamic> healthRequest, required String userToken}) async {
    Map<String, dynamic>? finalResponse;
    try {
      final response =
          await apiService.post(queryParams: {'token': userToken}, urlPath: healthPath, requestBody: healthRequest);

      dynamic res = await response;
      Map<String, dynamic> toReturn = jsonDecode(res.toString());
      finalResponse = toReturn;

      return finalResponse;
    } catch (e) {
      rethrow;
    }
  }
}
