import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String _configCacheKey = 'app_config';
  static const String _apiBaseUrlKey = 'api_base_url';
  static const String _wsBaseUrlKey = 'ws_base_url';
  static const String _authTokenKey = 'auth_token';
  static const String _employeeIdKey = 'employee_id';
  static const String _companyIdKey = 'company_id';

  static final ConfigService _instance = ConfigService._internal();
  late SharedPreferences _prefs;
  Map<String, dynamic>? _cachedConfig;

  factory ConfigService() {
    return _instance;
  }

  ConfigService._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final configJson = _prefs.getString(_configCacheKey);
      if (configJson != null) {
        _cachedConfig = jsonDecode(configJson);
      }
    } catch (e) {
      print('Error loading cached config: $e');
    }
  }

  Future<void> fetchAndCacheConfig() async {
    try {
      final apiUrl = await getApiBaseUrl();
      final response = await http.get(
        Uri.parse('$apiUrl/config/app-settings'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final config = jsonDecode(response.body);
        _cachedConfig = config;
        await _prefs.setString(_configCacheKey, response.body);
      }
    } catch (e) {
      print('Error fetching config: $e');
    }
  }

  // API URLs
  Future<String> getApiBaseUrl() async {
    return _prefs.getString(_apiBaseUrlKey) ?? 'http://localhost:8080/api';
  }

  Future<void> setApiBaseUrl(String url) async {
    await _prefs.setString(_apiBaseUrlKey, url);
  }

  Future<String> getWsBaseUrl() async {
    return _prefs.getString(_wsBaseUrlKey) ?? 'ws://localhost:8080/ws';
  }

  Future<void> setWsBaseUrl(String url) async {
    await _prefs.setString(_wsBaseUrlKey, url);
  }

  // Authentication
  Future<String?> getAuthToken() async {
    return _prefs.getString(_authTokenKey);
  }

  Future<void> setAuthToken(String token) async {
    await _prefs.setString(_authTokenKey, token);
  }

  Future<void> clearAuthToken() async {
    await _prefs.remove(_authTokenKey);
  }

  // Employee Data
  Future<String?> getEmployeeId() async {
    return _prefs.getString(_employeeIdKey);
  }

  Future<void> setEmployeeId(String id) async {
    await _prefs.setString(_employeeIdKey, id);
  }

  Future<String?> getCompanyId() async {
    return _prefs.getString(_companyIdKey);
  }

  Future<void> setCompanyId(String id) async {
    await _prefs.setString(_companyIdKey, id);
  }

  // Config Values from Backend
  int getLocationUpdateInterval() {
    return _cachedConfig?['locationUpdateInterval'] ?? 30000;
  }

  int getZoneCheckInterval() {
    return _cachedConfig?['zoneCheckInterval'] ?? 10000;
  }

  bool isFeatureEnabled(String featurePath) {
    // e.g., "tracking.realTimeLocation"
    final parts = featurePath.split('.');
    var config = _cachedConfig?['features'];
    for (var part in parts) {
      config = config?[part];
    }
    return config ?? true;
  }

  // Logout
  Future<void> logout() async {
    await _prefs.remove(_authTokenKey);
    await _prefs.remove(_employeeIdKey);
    await _prefs.remove(_companyIdKey);
  }

  // Clear all
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
