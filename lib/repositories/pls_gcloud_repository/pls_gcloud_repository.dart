import 'dart:async';
import 'dart:convert';
import 'package:pls_flutter/data/models/boostrap_summary.dart';
import 'package:pls_flutter/data/models/predict_models_comparison.dart';
import 'package:pls_flutter/data/models/seminr_summary.dart';
import 'package:pls_flutter/services/api_domain_url.dart';
import 'package:pls_flutter/services/api_service.dart';

class PLSRepository {
  final String healthPath = "/health";
  final String summaryModelPath = "/model_summary";
  final String summaryBootstrapPath = "/bootstrap_summary";
  final String indicatorWeightsSignificancePath = "/indicator_weights_significance";
  final String comparePredictModels = "/compare_predict_models";
  final String analyzeModeration = "/analyze_moderation";

  APIService apiService = APIService(baseUrl: APIDomain.apiDomainUrl);

  Future<SeminrSummary?> getSummaryPaths({required String userToken}) async {
    SeminrSummary? finalResponse;
    try {
      final response = await apiService.get(queryParams: {'manual_token': userToken}, url: summaryModelPath);

      Map<String, dynamic> toReturn = jsonDecode(response.toString());
      finalResponse = SeminrSummary.fromJson(toReturn);

      return finalResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<SeminrSummary?> getSummaryPathsSpecificConstruct(
      {required String userToken, required String constructName}) async {
    SeminrSummary? finalResponse;
    try {
      final response = await apiService.get(queryParams: {
        'manual_token': userToken,
        'construct_name': constructName,
      }, url: summaryModelPath);

      Map<String, dynamic> toReturn = jsonDecode(response.toString());
      finalResponse = SeminrSummary.fromJson(toReturn);

      return finalResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<BootstrapSummary?> getBoostrapSummary({required String userToken}) async {
    BootstrapSummary? finalResponse;
    try {
      final response = await apiService.get(
          queryParams: {'manual_token': userToken, 'alpha': 0.1, 'cores_mode': 'parallelDetectCores'},
          url: summaryBootstrapPath);

      Map<String, dynamic> toReturn = jsonDecode(response.toString());
      finalResponse = BootstrapSummary.fromJson(toReturn);

      return finalResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<BootstrapSummary?> getSignificanceRelevanceOfIndicatorWeights({required String userToken}) async {
    BootstrapSummary? finalResponse;
    try {
      final response = await apiService.get(
        queryParams: {'manual_token': userToken, 'alpha': 0.05, 'cores_mode': 'parallelDetectCores'},
        url: indicatorWeightsSignificancePath,
      );

      Map<String, dynamic> toReturn = jsonDecode(response.toString());
      finalResponse = BootstrapSummary.fromJson(toReturn);

      return finalResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<PredictModelsComparison?> getComparePredictModels({required String userToken}) async {
    PredictModelsComparison? finalResponse;
    try {
      final response = await apiService.get(
        queryParams: {'manual_token': userToken},
        url: comparePredictModels,
      );

      Map<String, dynamic> toReturn = jsonDecode(response.toString());
      finalResponse = PredictModelsComparison.fromJson(toReturn);

      return finalResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<BootstrapSummary?> getModerationAnalysis({required String userToken}) async {
    BootstrapSummary? finalResponse;
    try {
      final response = await apiService.get(queryParams: {'manual_token': userToken}, url: summaryBootstrapPath);

      Map<String, dynamic> toReturn = jsonDecode(response.toString());
      finalResponse = BootstrapSummary.fromJson(toReturn);

      return finalResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getHealth(
      {required Map<String, dynamic> healthRequest, required String userToken}) async {
    Map<String, dynamic>? finalResponse;
    try {
      final response = await apiService
          .post(queryParams: {'manual_token': userToken}, urlPath: healthPath, requestBody: healthRequest);

      dynamic res = await response;
      Map<String, dynamic> toReturn = jsonDecode(res.toString());
      finalResponse = toReturn;

      return finalResponse;
    } catch (e) {
      rethrow;
    }
  }
}
