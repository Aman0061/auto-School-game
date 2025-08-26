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
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Вызываем API для регистрации
      final result = await UserService.registerUser(
        name: name,
        phone: phone,
        userType: userType,
        email: email,
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

  // Вход пользователя по телефону
  Future<bool> loginByPhone(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Вызываем API для входа по телефону
      final user = await UserService.loginByPhone(phone);

      if (user != null) {
        _currentUser = user;
        
        await _secureStorage.write(key: 'auth_token', value: 'user_token_${user.id}');
        await _saveUserData(user);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Пользователь с таким номером телефона не найден';
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

  // Вход пользователя (для обратной совместимости)
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    // Для демо создаем пользователя
    final user = User(
      id: 'demo_user',
      email: email,
      name: 'Демо Пользователь',
      phone: '+996700466412',
      userType: 'seeker',
      createdAt: DateTime.now(),
      moduleProgress: {'module_1': 0, 'module_2': 0, 'module_3': 0},
    );

    _currentUser = user;
    
    await _secureStorage.write(key: 'auth_token', value: 'dummy_token');
    await _saveUserData(user);

    return true;
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

  // Обновление профиля пользователя
  Future<bool> updateProfile(User updatedUser) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('AuthProvider: Начинаем обновление профиля для пользователя ${updatedUser.id}');
      
      // Вызываем API для обновления профиля
      final success = await UserService.updateUser(updatedUser);

      if (success) {
        print('AuthProvider: Профиль успешно обновлен в базе данных');
        _currentUser = updatedUser;
        await _saveUserData(updatedUser);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        print('AuthProvider: Не удалось обновить профиль в базе данных');
        _error = 'Не удалось обновить профиль в базе данных';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('AuthProvider: Ошибка обновления профиля: $e');
      _error = 'Ошибка обновления профиля: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
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
