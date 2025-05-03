import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Настройки
  static const String _baseUrl = 'https://edu.gidhalal.kz/user/api/';
  static const Duration _requestTimeout = Duration(seconds: 15);
  static const int _maxRetries = 2;
  static const Duration _retryDelay = Duration(seconds: 1);

  // Тестовый режим
  static bool _testMode = false;
  static Map<String, dynamic>? _customMockData;

  /// Включить тестовый режим [enableTestMode(mockUser: {...})]
  static void enableTestMode({Map<String, dynamic>? mockUser}) {
    _testMode = true;
    _customMockData = mockUser ?? _defaultMockUser;
  }

  static void disableTestMode() {
    _testMode = false;
    _customMockData = null;
  }

  // Основные методы
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    if (_testMode) return _getMockResponse('login', username: username);

    return _executeWithRetry(
      request: () => http.post(
        Uri.parse('${_baseUrl}login/'),
        headers: _headers,
        body: jsonEncode({'username': username, 'password': password}),
      ),
      operation: 'Авторизация',
    );
  }

  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String password2,
  }) async {
    if (_testMode) return _getMockResponse('register', username: username, email: email);

    return _executeWithRetry(
      request: () => http.post(
        Uri.parse('${_baseUrl}register/'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'password2': password2,
        }),
      ),
      operation: 'Регистрация',
    );
  }

  // ================== ВНУТРЕННИЕ МЕТОДЫ ==================
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, dynamic>> _executeWithRetry({
    required Future<http.Response> Function() request,
    required String operation,
  }) async {
    int attempt = 0;
    
    while (attempt <= _maxRetries) {
      try {
        final response = await request().timeout(_requestTimeout);
        return _parseResponse(response);
      } on TimeoutException {
        attempt++;
        _log('$operation: попытка $attempt/$_maxRetries (таймаут)');
        if (attempt <= _maxRetries) await Future.delayed(_retryDelay * attempt);
      } catch (e) {
        throw _handleError(e, operation);
      }
    }
    throw ApiTimeoutException(operation: operation);
  }

  static Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }
      throw ApiException(
        statusCode: response.statusCode,
        message: data['error'] ?? 'Ошибка сервера',
        response: data,
      );
    } on FormatException {
      throw const ApiException(message: 'Некорректный формат ответа');
    }
  }

  static Never _handleError(dynamic error, String operation) {
    if (error is ApiException) throw error;
    if (error is http.Response) {
      throw ApiException(
        statusCode: error.statusCode,
        message: 'Ошибка $operation',
        response: {'body': error.body},
      );
    }
    throw ApiException(message: 'Неизвестная ошибка: ${error.toString()}');
  }

  // ================== ФЕЙКОВЫЕ ДАННЫЕ ==================
  static final Map<String, dynamic> _defaultMockUser = {
  'token': 'fake_token_${DateTime.now().millisecondsSinceEpoch}',
  'user': {
    'id': 999,
    'username': 'testuser',
    'email': 'test@edu.kz',
    'is_active': true,
    'roles': ['student'], // Роли пользователя
    'password': 'test1234', // Добавлен пароль для тестов
  },
};

// Метод для получения мок-данных
static Map<String, dynamic> _getMockResponse(
  String endpoint, {
  String? username,
  String? email,
}) {
  final data = _customMockData ?? _defaultMockUser;
  return {
    ...data,
    'meta': {
      'endpoint': endpoint,
      'timestamp': DateTime.now().toIso8601String(),
      'mock': true,
    },
    if (username != null) 'user': {
      ...data['user'],
      'username': username,
      'email': email ?? '$username@test.kz',
    },
  };
}

  static void _log(String message) {
    if (kDebugMode) debugPrint('[ApiService] $message');
  }
}

// Классы ошибок
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final Map<String, dynamic>? response;

  const ApiException({
    required this.message,
    this.statusCode,
    this.response,
  });

  @override
  String toString() {
    if (statusCode != null) return '$message (код $statusCode)';
    return message;
  }
}

class ApiTimeoutException extends ApiException {
  final String operation;

  ApiTimeoutException({required this.operation})
      : super(
          message: '$operation: превышено время ожидания',
          statusCode: 504,
        );

  String get retrySuggestion => 'Повторите попытку через 1-2 минуты';
}