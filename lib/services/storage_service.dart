import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token management
  static Future<void> setAccessToken(String token) async {
    await _prefs?.setString(AppConstants.accessTokenKey, token);
  }

  static String? getAccessToken() {
    final token = _prefs?.getString(AppConstants.accessTokenKey);
    print('🔑 StorageService.getAccessToken() called');
    print('🔑 Token found: ${token != null ? "YES (${token.substring(0, 20)}...)" : "NO"}');
    return token;
  }

  static Future<void> setRefreshToken(String token) async {
    await _prefs?.setString(AppConstants.refreshTokenKey, token);
  }

  static String? getRefreshToken() {
    return _prefs?.getString(AppConstants.refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await _prefs?.remove(AppConstants.accessTokenKey);
    await _prefs?.remove(AppConstants.refreshTokenKey);
  }

  // User data management
  static Future<void> setUserData(Map<String, dynamic> userData) async {
    await _prefs?.setString(AppConstants.userDataKey, jsonEncode(userData));
  }

  static Map<String, dynamic>? getUserData() {
    final userDataString = _prefs?.getString(AppConstants.userDataKey);
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> clearUserData() async {
    await _prefs?.remove(AppConstants.userDataKey);
  }

  // Onboarding status
  static Future<void> setOnboardingComplete(bool isComplete) async {
    await _prefs?.setBool(AppConstants.onboardingCompleteKey, isComplete);
  }

  static bool isOnboardingComplete() {
    return _prefs?.getBool(AppConstants.onboardingCompleteKey) ?? false;
  }

  // Generic methods
  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    final token = getAccessToken();
    final userData = getUserData();
    return token != null && userData != null;
  }

  // Logout - clear all user related data
  static Future<void> logout() async {
    await clearTokens();
    await clearUserData();
    // Keep onboarding status as user has already completed it
  }
}
