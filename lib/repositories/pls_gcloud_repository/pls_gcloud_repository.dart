import 'dart:async';
import 'dart:convert';
import 'package:pls_flutter/data/models/seminr_summary.dart';
import 'package:pls_flutter/services/api_domain_url.dart';
import 'package:pls_flutter/services/api_service.dart';

class PLSRepository {
  final String healthPath = "/health";
  final String summaryPathsPath = "/summary_paths";

  APIService apiService = APIService(baseUrl: APIDomain.apiDomainUrl);

  Future<SeminrSummary?> getSummaryPaths({required String userToken}) async {
    SeminrSummary? finalResponse;
    try {
      final response = await apiService
          .get(queryParams: {'manual_token': userToken}, url: summaryPathsPath);

      Map<String, dynamic> toReturn = jsonDecode(response.toString());
      finalResponse = SeminrSummary.fromJson(toReturn);

      return finalResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getHealth(
      {required Map<String, dynamic> healthRequest,
      required String userToken}) async {
    Map<String, dynamic>? finalResponse;
    try {
      final response = await apiService.post(
          queryParams: {'manual_token': userToken},
          urlPath: healthPath,
          requestBody: healthRequest);

      dynamic res = await response;
      Map<String, dynamic> toReturn = jsonDecode(res.toString());
      finalResponse = toReturn;

      return finalResponse;
    } catch (e) {
      rethrow;
    }
  }
}
