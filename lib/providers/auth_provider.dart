import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Регистрация пользователя
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Здесь будет API вызов для регистрации
      // Пока используем локальную логику
      await Future.delayed(const Duration(seconds: 1)); // имитация API

      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        createdAt: DateTime.now(),
        moduleProgress: {},
      );

      _currentUser = user;
      
      // Сохраняем токен и данные пользователя
      await _secureStorage.write(key: 'auth_token', value: 'dummy_token');
      await _saveUserData(user);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Ошибка регистрации: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Вход пользователя
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Здесь будет API вызов для входа
      await Future.delayed(const Duration(seconds: 1)); // имитация API

      // Для демо создаем пользователя
      final user = User(
        id: 'demo_user',
        email: email,
        name: 'Демо Пользователь',
        createdAt: DateTime.now(),
        moduleProgress: {'module_1': 0, 'module_2': 0, 'module_3': 0},
      );

      _currentUser = user;
      
      await _secureStorage.write(key: 'auth_token', value: 'dummy_token');
      await _saveUserData(user);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Ошибка входа: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Выход пользователя
  Future<void> logout() async {
    _currentUser = null;
    await _secureStorage.delete(key: 'auth_token');
    await _clearUserData();
    notifyListeners();
  }

  // Проверка авторизации при запуске
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token != null) {
        final userData = await _loadUserData();
        if (userData != null) {
          _currentUser = userData;
        }
      }
    } catch (e) {
      _error = 'Ошибка проверки авторизации: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Обновление прогресса модуля
  void updateModuleProgress(String moduleId, int progress) {
    if (_currentUser != null) {
      final updatedProgress = Map<String, int>.from(_currentUser!.moduleProgress);
      updatedProgress[moduleId] = progress;
      
      _currentUser = _currentUser!.copyWith(moduleProgress: updatedProgress);
      _saveUserData(_currentUser!);
      notifyListeners();
    }
  }

  // Сохранение данных пользователя
  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', user.toJson().toString());
  }

  // Загрузка данных пользователя
  Future<User?> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      try {
        final userData = Map<String, dynamic>.from(
          jsonDecode(userDataString) as Map,
        );
        return User.fromJson(userData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Очистка данных пользователя
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
