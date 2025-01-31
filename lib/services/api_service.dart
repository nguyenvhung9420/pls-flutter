import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pls_flutter/data/exceptions/base_error.dart';

class APIService {
  var dio = Dio(BaseOptions(
    sendTimeout: const Duration(seconds: 120),
    connectTimeout: const Duration(seconds: 120),
    receiveTimeout: const Duration(seconds: 120),
  ));
  final apiKey = "";
  String _baseUrl = "";

  APIService({required String baseUrl}) {
    _baseUrl = baseUrl;
  }

  Future<dynamic> get(
      {String url = "", Map<String, dynamic> queryParams = const {}, Map<String, String> headers = const {}}) async {
    dynamic responseJson;
    Response<String>? response;
    final queryParameters = queryParams;
    Map<String, String> finalHeaders = {};
    finalHeaders.addAll(<String, String>{'accept': 'application/json'});
    finalHeaders.addAll(<String, String>{'Access-Control-Allow-Origin': '*'});
    finalHeaders.addAll(headers);
    debugPrint(">>> _baseUrl + url = ${_baseUrl + url}");
    try {
      response = await dio.get(_baseUrl + url, queryParameters: queryParameters);
      debugPrint(">>> _baseUrl + url = ${response.realUri}");
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } catch (e) {
      if (e is DioException) {
        debugPrint(">>> Error with ${response?.realUri}:\n${e.response?.data.toString()}");
        if ([DioExceptionType.connectionTimeout, DioExceptionType.receiveTimeout, DioExceptionType.sendTimeout]
            .contains(e.type)) {
          throw FetchDataException("Connection: Timeout Exception");
        }

        throw FetchDataException(getExceptionMessageFromJsonString(e.response?.data.toString() ?? ""));
      }
      throw FetchDataException(e.toString());
    }

    responseJson = _response(response);
    return responseJson;
  }

  Future<dynamic> post({
    required String urlPath,
    required Map<String, dynamic> requestBody,
    Map<String, String> headers = const {},
    Map<String, dynamic> queryParams = const {},
  }) async {
    dynamic responseJson;
    Response<String>? response;
    Map<String, String> finalHeaders = {};
    finalHeaders.addAll(<String, String>{'Content-Type': 'application/json', "accept": 'application/json'});
    finalHeaders.addAll(<String, String>{'Access-Control-Allow-Origin': '*'});
    finalHeaders.addAll(headers);
    debugPrint(">>> _baseUrl + url = ${_baseUrl + urlPath}");

    try {
      response = await dio.post(
        _baseUrl + urlPath,
        data: requestBody,
        queryParameters: queryParams,
        options: Options(headers: finalHeaders),
      );
      debugPrint(">>> Dio response.data = ${response.data}");
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } catch (e) {
      if (e is DioError) {
        debugPrint(">>> Error: ${e.response?.data.toString()}");
        throw FetchDataException(getExceptionMessageFromJsonString(e.response?.data.toString() ?? ""));
      }
      throw FetchDataException(e.toString());
    }

    responseJson = _response(response);
    return responseJson;
  }

  Future<dynamic> postWithFile({
    required String urlPath,
    required Map<String, dynamic> requestBody,
    required String filePath,
    required String fileName,
    Map<String, String> headers = const {},
    Map<String, dynamic> queryParams = const {},
  }) async {
    dynamic responseJson;
    Response<String>? response;
    Map<String, String> finalHeaders = {};
    // finalHeaders.addAll(<String, String>{'Content-Type': 'application/json', "accept": 'application/json'});
    finalHeaders.addAll(<String, String>{'Content-Type': 'multipart/form-data', 'accept': '*/*'});
    finalHeaders.addAll(<String, String>{'Access-Control-Allow-Origin': '*'});
    finalHeaders.addAll(headers);

    debugPrint(">>> _baseUrl + url = ${_baseUrl + urlPath}");
    debugPrint(">>> file path = $filePath");

    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: DioMediaType('text', 'csv'),
        ),
        'name': 'Hung 23332',
      });

      response = await dio.post(
        _baseUrl + urlPath,
        data: formData,
        queryParameters: queryParams,
        options: Options(headers: finalHeaders),
      );
      debugPrint(">>> Dio response.data = ${response.data}");
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } catch (e) {
      if (e is DioError) {
        debugPrint(">>> Error: ${e.response?.data.toString()}");
        throw FetchDataException(getExceptionMessageFromJsonString(e.response?.data.toString() ?? ""));
      }
      throw FetchDataException(e.toString());
    }

    responseJson = _response(response);
    return responseJson;
  }

  Future<dynamic> delete(
      {String url = "", Map<String, dynamic> queryParams = const {}, Map<String, String> headers = const {}}) async {
    dynamic responseJson;
    Response<String>? response;
    final queryParameters = queryParams;
    Map<String, String> finalHeaders = {};
    finalHeaders.addAll(<String, String>{'accept': 'application/json'});
    finalHeaders.addAll(<String, String>{'Access-Control-Allow-Origin': '*'});
    finalHeaders.addAll(headers);
    debugPrint(">>> _baseUrl + url = ${_baseUrl + url}");
    try {
      response = await dio.delete(_baseUrl + url, queryParameters: queryParameters);
      debugPrint(">>> _baseUrl + url = ${response.realUri}");
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } catch (e) {
      if (e is DioException) {
        debugPrint(">>> Error with ${response?.realUri}:\n${e.response?.data.toString()}");
        if ([DioExceptionType.connectionTimeout, DioExceptionType.receiveTimeout, DioExceptionType.sendTimeout]
            .contains(e.type)) {
          throw FetchDataException("Connection: Timeout Exception");
        }

        throw FetchDataException(getExceptionMessageFromJsonString(e.response?.data.toString() ?? ""));
      }
      throw FetchDataException(e.toString());
    }

    responseJson = _response(response);
    return responseJson;
  }
}

dynamic _response(Response<String> response) {
  debugPrint(">>> Got response data: ${response.data}");

  switch (response.statusCode) {
    case 200:
      return response.data;
    case 422:
      throw BadRequestException(response.data.toString());
    case 400:
      throw BadRequestException(getExceptionMessageFromJsonString(response.data.toString()));
    case 401:
      throw BadRequestException(response.data.toString());
    case 403:
      throw UnauthorisedException(response.data.toString());
    case 500:
    default:
      throw FetchDataException('Error with StatusCode : ${response.statusCode}');
  }
}

String getExceptionMessageFromJsonString(String responseBody) {
  var responseJson = json.decode(responseBody);
  return responseJson["detail"] ?? "Unknown error";
}
