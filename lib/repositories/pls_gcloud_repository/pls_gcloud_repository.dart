import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pls_flutter/data/models/boostrap_summary.dart';
import 'package:pls_flutter/data/models/predict_models_comparison.dart';
import 'package:pls_flutter/data/models/predict_summary.dart';
import 'package:pls_flutter/data/models/seminr_summary.dart';
import 'package:pls_flutter/data/models/specific_effect_significance.dart';
import 'package:pls_flutter/services/api_domain_url.dart';
import 'package:pls_flutter/services/api_service.dart';

class PLSRepository {
  final String healthPath = "/health";
  final String summaryModelPath = "/model_summary";
  final String summaryBootstrapPath = "/bootstrap_summary";
  final String indicatorWeightsSignificancePath =
      "/indicator_weights_significance";
  final String comparePredictModels = "/compare_predict_models";
  final String analyzeModeration = "/analyze_moderation";
  final String testFileUpload = "/upload";
  final String generalPrediction = "/predict_summary";
  final String specificEffectSignificance =
      "/get_specific_effect_significance"; // for Mediation alalysis
  final String plotReliability = "/plot_reliability";

  APIService apiService = APIService(baseUrl: APIDomain.apiDomainUrl);

  Future<SeminrSummary?> uploadFile(
      {required String userToken, required String filePath}) async {
    SeminrSummary? finalResponse;
    try {
      final response = await apiService.postWithFile(
        urlPath: testFileUpload,
        filePath: filePath,
        queryParams: {'manual_token': userToken},
        requestBody: {},
        fileName: 'Corporate_reputation_data.csv',
      );

      Map<String, dynamic> toReturn = jsonDecode(response.toString());
      finalResponse = SeminrSummary.fromJson(toReturn);

      return finalResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<SeminrSummary?> getSummaryPaths(
      {required String userToken,
      required String instructions,
      required String filePath}) async {
    SeminrSummary? finalResponse;
    try {
      final response = await apiService.postWithFile(
        requestBody: {},
        filePath: filePath,
        fileName: 'Corporate_reputation_data.csv',
        urlPath: summaryModelPath,
        queryParams: {
          'manual_token': userToken,
          'instructions': instructions,
        },
      );

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

  Future<BootstrapSummary?> getBoostrapSummary(
      {required String userToken,
      required String filePath,
      required String instructions}) async {
    BootstrapSummary? finalResponse;
    try {
      final response = await apiService.postWithFile(
        requestBody: {},
        filePath: filePath,
        fileName: 'Corporate_reputation_data.csv',
        queryParams: {
          'instructions': instructions,
          'manual_token': userToken,
          'alpha': 0.1,
          'cores_mode': 'parallelDetectCores'
        },
        urlPath: summaryBootstrapPath,
      );

      Map<String, dynamic> toReturn = jsonDecode(response.toString());
      finalResponse = BootstrapSummary.fromJson(toReturn);

      return finalResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<BootstrapSummary?> getSignificanceRelevanceOfIndicatorWeights(
      {required String userToken,
      required String filePath,
      required String instructions}) async {
    BootstrapSummary? finalResponse;
    try {
      final response = await apiService.postWithFile(
        requestBody: {},
        filePath: filePath,
        fileName: 'Corporate_reputation_data.csv',
        queryParams: {
          'instructions': instructions,
          'manual_token': userToken,
          'alpha': 0.1,
          'cores_mode': 'parallelDetectCores'
        },
        urlPath: summaryBootstrapPath,
      );

      Map<String, dynamic> toReturn = jsonDecode(response.toString());
      finalResponse = BootstrapSummary.fromJson(toReturn);

      return finalResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<PredictSummary?> getGeneralPrediction(
      {required String userToken,
      required String filePath,
      required String instructions}) async {
    PredictSummary? finalResponse;
    try {
      final response = await apiService.postWithFile(
          requestBody: {},
          filePath: filePath,
          fileName: 'Corporate_reputation_data.csv',
          queryParams: {
            'noFolds': 10,
            'reps': 10,
            'instructions': instructions,
            'manual_token': userToken,
            'alpha': 0.1,
            'cores_mode': 'parallelDetectCores'
          },
          urlPath: generalPrediction);

      Map<String, dynamic> toReturn = jsonDecode(response.toString());
      finalResponse = PredictSummary.fromJson(toReturn);

      return finalResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<PredictModelsComparison?> getComparePredictModels(
      {required String userToken}) async {
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

  // specific_effect_significance
  Future<SpecificEffectSignificance?> getSpecificEffectSignificance({
    required String userToken,
    required String filePath,
    required String instructions,
    required String from,
    required String through,
    required String to,
  }) async {
    SpecificEffectSignificance? finalResponse;
    try {
      final response = await apiService.postWithFile(
        requestBody: {},
        filePath: filePath,
        fileName: 'Corporate_reputation_data.csv',
        queryParams: {
          'instructions': instructions,
          'manual_token': userToken,
          'cores_mode': "parallelDetectCores",
          'from': from,
          'through': through,
          'to': to,
          'alpha': 0.05
        },
        urlPath: specificEffectSignificance,
      );

      Map<String, dynamic> toReturn = jsonDecode(response.toString());
      finalResponse = SpecificEffectSignificance.fromJson(toReturn);
      return finalResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<BootstrapSummary?> getModerationAnalysis(
      {required String userToken,
      required String filePath,
      required String instructions}) async {
    BootstrapSummary? finalResponse;
    try {
      final response = await apiService.postWithFile(
          requestBody: {},
          filePath: filePath,
          fileName: 'Corporate_reputation_data.csv',
          queryParams: {
            'instructions': instructions,
            'manual_token': userToken,
          },
          urlPath: analyzeModeration);

      Map<String, dynamic> toReturn = jsonDecode(response.toString());
      finalResponse = BootstrapSummary.fromJson(toReturn);

      return finalResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getPlotReliability(
      {required String userToken,
      required String filePath,
      required String instructions}) async {
    // Image finalResponse;

    try {
      final response = await apiService.postWithFile(
          requestBody: {},
          filePath: filePath,
          fileName: 'Corporate_reputation_data.csv',
          queryParams: {
            'instructions': instructions,
            'manual_token': userToken,
          },
          urlPath: plotReliability);

      return response;

      // Map<String, dynamic> toReturn = jsonDecode(response.toString());
      // finalResponse = BootstrapSummary.fromJson(toReturn);

      // return finalResponse;
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
