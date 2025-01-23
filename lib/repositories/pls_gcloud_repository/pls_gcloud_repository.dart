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
  final String testFileUpload = "/upload";

  APIService apiService = APIService(baseUrl: APIDomain.apiDomainUrl);

  Future<SeminrSummary?> uploadFile({required String userToken, required String filePath}) async {
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

  // import 'package:dio/dio.dart';

  // Future<void> uploadFileWithDio({required String filePath, required String userName}) async {
  //   try {
  //     Dio dio = Dio();
  //     FormData formData = FormData.fromMap({
  //       'file': await MultipartFile.fromFile(filePath, filename: 'Corporate reputation data.csv',
  // contentType: MediaType('text', 'csv')),
  //     });

  //     Response response = await dio.post(
  //       'http://127.0.0.1:5555/upload',
  //       queryParameters: {'name': userName},
  //       data: formData,
  //       options: Options(
  //         headers: {
  //           'accept': '*/*',
  //           'Content-Type': 'multipart/form-data',
  //         },
  //       ),
  //     );

  //     if (response.statusCode != 200) {
  //       throw Exception('Failed to upload file');
  //     }

  //     print('File uploaded successfully');
  //   } catch (e) {
  //     print('Error uploading file: $e');
  //   }
  // }

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
