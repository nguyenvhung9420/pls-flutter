import 'package:flutter/material.dart';
import 'package:pls_flutter/services/api_domain_url.dart';
import 'package:pls_flutter/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenRepository {
  String sharedPreferenceTokenKey = "TOKEN";

  /// saving token to sharedpreference
  Future<bool> saveAuthToken({required String token}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    debugPrint(">>> this token is saving: ${token}");
    return await preferences.setString(sharedPreferenceTokenKey, token);
  }

  /// saving token to sharedpreference
  void saveAuthTokenWithCallback(
      {required String token, required Function callback}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences
        .setString(sharedPreferenceTokenKey, token)
        .then((value) => callback());
  }

  Future<String?> getCurrentAuthToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString(sharedPreferenceTokenKey);
    debugPrint(">>> getCurrentAuthToken = ${token}");
    return token;
  }

  /// remove token from sharedpreference
  Future<bool> removeAuthToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.remove(sharedPreferenceTokenKey);
  }
}
