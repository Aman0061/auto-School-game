import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/user_service.dart';

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
    required String username,
    required String password,
    required String name,
    required String userType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Вызываем API для регистрации
      final result = await UserService.registerUser(
        name: name,
        username: username,
        userType: userType,
        password: password,
      );

      if (result['success'] == true) {
        final user = result['user'] as User;
        _currentUser = user;
        
        // Сохраняем токен и данные пользователя
        await _secureStorage.write(key: 'auth_token', value: 'user_token_${user.id}');
        await _saveUserData(user);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Если пользователь уже существует, авторизуем его
        if (result['user'] != null) {
          final existingUser = result['user'] as User;
          _currentUser = existingUser;
          
          await _secureStorage.write(key: 'auth_token', value: 'user_token_${existingUser.id}');
          await _saveUserData(existingUser);

          _isLoading = false;
          notifyListeners();
          return true;
        }
        
        _error = result['error'] ?? 'Ошибка регистрации';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Ошибка регистрации: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Вход пользователя по username
  Future<bool> loginByUsername(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Вызываем API для входа по username
      final user = await UserService.loginByUsername(username);

      if (user != null) {
        _currentUser = user;
        
        await _secureStorage.write(key: 'auth_token', value: 'user_token_${user.id}');
        await _saveUserData(user);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Пользователь с таким логином не найден';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Ошибка входа: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Демо-вход для тестирования
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Создаем демо-пользователя
      final user = User(
        id: 'demo_user_1',
        username: username,
        name: 'Демо Пользователь',
        userType: 'seeker',
        password: password,
        createdAt: DateTime.now(),
        moduleProgress: {},
      );

      _currentUser = user;
      
      // Сохраняем токен и данные пользователя
      await _secureStorage.write(key: 'auth_token', value: 'demo_token_${user.id}');
      await _saveUserData(user);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Ошибка демо-входа: ${e.toString()}';
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

  // Очистка ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Обновление профиля пользователя
  Future<bool> updateProfile(User updatedUser) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Вызываем API для обновления профиля
      final success = await UserService.updateUser(updatedUser);

      if (success) {
        _currentUser = updatedUser;
        await _saveUserData(updatedUser);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Не удалось обновить профиль';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Ошибка обновления профиля: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Проверка аутентификации при запуске
  Future<void> checkAuthStatus() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token != null) {
        final userData = await _getUserData();
        if (userData != null) {
          _currentUser = userData;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Ошибка проверки статуса аутентификации: $e');
    }
  }

  // Сохранение данных пользователя
  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  // Получение данных пользователя
  Future<User?> _getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        return User.fromJson(userData);
      }
    } catch (e) {
      print('Ошибка получения данных пользователя: $e');
    }
    return null;
  }

  // Очистка данных пользователя
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }
}
