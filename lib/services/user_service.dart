import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../config/supabase_config.dart';

class UserService {
  static const String baseUrl = SupabaseConfig.url;
  static const String apiKey = SupabaseConfig.anonKey;

  // Регистрация нового пользователя
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String phone,
    required String userType,
    String? email,
    String? password,
  }) async {
    try {
      // Сначала проверяем, существует ли пользователь с таким телефоном
      final existingUser = await loginByPhone(phone);
      if (existingUser != null) {
        return {
          'success': false,
          'error': 'Пользователь с таким номером телефона уже существует',
          'user': existingUser,
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/rest/v1/users'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': apiKey,
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'user_type': userType,
          'email': email ?? 'user_${DateTime.now().millisecondsSinceEpoch}@example.com',
          'password': password ?? 'default_password_${DateTime.now().millisecondsSinceEpoch}',
          'created_at': DateTime.now().toIso8601String(),
          'module_progress': {},
        }),
      );

      print('Регистрация пользователя - статус: ${response.statusCode}');
      print('Регистрация пользователя - ответ: ${response.body}');

      if (response.statusCode == 201) {
        // После успешного создания всегда получаем пользователя по телефону
        // Это обходит проблему с парсингом поля password
        print('Пользователь создан, получаем данные по телефону...');
        final createdUser = await loginByPhone(phone);
        if (createdUser != null) {
          return {
            'success': true,
            'user': createdUser,
          };
        } else {
          return {
            'success': false,
            'error': 'Пользователь создан, но не удалось получить его данные',
          };
        }
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Ошибка регистрации';
        
        if (errorData['code'] == '23505' && errorData['message'].contains('phone')) {
          errorMessage = 'Пользователь с таким номером телефона уже существует';
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }
        
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      print('Исключение при регистрации: $e');
      
      // Если это ошибка парсинга, попробуем получить пользователя по телефону
      if (e.toString().contains('FormatException')) {
        try {
          final createdUser = await loginByPhone(phone);
          if (createdUser != null) {
            return {
              'success': true,
              'user': createdUser,
            };
          }
        } catch (retryError) {
          print('Ошибка при повторной попытке: $retryError');
        }
      }
      
      return {
        'success': false,
        'error': 'Ошибка сети: ${e.toString()}',
      };
    }
  }

  // Авторизация пользователя по телефону
  static Future<User?> loginByPhone(String phone) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rest/v1/users?phone=eq.$phone&select=*'),
        headers: {
          'apikey': apiKey,
          'Authorization': 'Bearer $apiKey',
        },
      );

      print('Авторизация по телефону - статус: ${response.statusCode}');
      print('Авторизация по телефону - ответ: ${response.body}');

      if (response.statusCode == 200) {
        // Проверяем, что ответ не пустой
        if (response.body.isNotEmpty) {
          try {
            final List<dynamic> users = jsonDecode(response.body);
            if (users.isNotEmpty) {
              final userData = users.first as Map<String, dynamic>;
              // Создаем безопасную копию данных без проблемных полей
              final safeUserData = <String, dynamic>{
                'id': userData['id'],
                'email': userData['email'],
                'name': userData['name'],
                'phone': userData['phone'],
                'userType': userData['user_type'],
                'createdAt': userData['created_at'],
                'moduleProgress': userData['module_progress'] ?? {},
              };
              print('Безопасные данные пользователя: $safeUserData');
              return User.fromJson(safeUserData);
            }
          } catch (e) {
            print('Ошибка парсинга пользователя: $e');
            print('Данные пользователя: ${response.body}');
          }
        } else {
          print('Пустой ответ от сервера при поиске пользователя');
        }
      }
      return null;
    } catch (e) {
      print('Исключение при авторизации: $e');
      return null;
    }
  }

  // Получение пользователя по ID
  static Future<User?> getUserById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rest/v1/users?id=eq.$userId&select=*'),
        headers: {
          'apikey': apiKey,
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        if (users.isNotEmpty) {
          return User.fromJson(users.first);
        }
      }
      return null;
    } catch (e) {
      print('Исключение при получении пользователя: $e');
      return null;
    }
  }

  // Обновление профиля пользователя
  static Future<bool> updateUser(User user) async {
    try {
      print('Начинаем обновление пользователя с ID: ${user.id}');
      print('Данные для обновления: name=${user.name}, email=${user.email}, phone=${user.phone}, userType=${user.userType}');
      
      // Проверяем, что у нас есть валидный ID
      if (user.id.isEmpty || user.id == 'demo_user') {
        print('Ошибка: Невалидный ID пользователя: ${user.id}');
        return false;
      }
      
      final response = await http.patch(
        Uri.parse('$baseUrl/rest/v1/users?id=eq.${user.id}'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': apiKey,
          'Authorization': 'Bearer $apiKey',
          'Prefer': 'return=minimal',
        },
        body: jsonEncode({
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'user_type': user.userType,
          'updated_at': DateTime.now().toIso8601String(),
        }),
      );

      print('Обновление пользователя - статус: ${response.statusCode}');
      print('Обновление пользователя - заголовки: ${response.headers}');
      print('Обновление пользователя - ответ: ${response.body}');

      // Supabase может возвращать 200 или 204 для успешного обновления
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Пользователь успешно обновлен в базе данных');
        
        // Дополнительная проверка: получаем обновленного пользователя
        final updatedUser = await loginByPhone(user.phone);
        if (updatedUser != null) {
          print('Подтверждение: пользователь успешно получен из базы данных');
          print('Обновленные данные: name=${updatedUser.name}, email=${updatedUser.email}');
        }
        
        return true;
      } else {
        print('Ошибка обновления: ${response.statusCode} - ${response.body}');
        
        // Попробуем получить детали ошибки
        try {
          final errorData = jsonDecode(response.body);
          print('Детали ошибки: $errorData');
        } catch (e) {
          print('Не удалось распарсить детали ошибки: $e');
        }
        
        return false;
      }
    } catch (e) {
      print('Исключение при обновлении пользователя: $e');
      return false;
    }
  }

  // Обновление прогресса пользователя
  static Future<bool> updateUserProgress(String userId, Map<String, int> progress) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/rest/v1/users?id=eq.$userId'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': apiKey,
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'module_progress': progress,
          'updated_at': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Исключение при обновлении прогресса: $e');
      return false;
    }
  }

  // Получение статистики пользователей
  static Future<Map<String, int>> getUserStatistics() async {
    try {
      // Получаем общее количество пользователей
      final totalResponse = await http.get(
        Uri.parse('$baseUrl/rest/v1/users?select=id'),
        headers: {
          'apikey': apiKey,
          'Authorization': 'Bearer $apiKey',
        },
      );

      // Получаем количество студентов
      final studentsResponse = await http.get(
        Uri.parse('$baseUrl/rest/v1/users?user_type=eq.student&select=id'),
        headers: {
          'apikey': apiKey,
          'Authorization': 'Bearer $apiKey',
        },
      );

      // Получаем количество ищущих автошколу
      final seekersResponse = await http.get(
        Uri.parse('$baseUrl/rest/v1/users?user_type=eq.seeker&select=id'),
        headers: {
          'apikey': apiKey,
          'Authorization': 'Bearer $apiKey',
        },
      );

      int total = 0;
      int students = 0;
      int seekers = 0;

      if (totalResponse.statusCode == 200) {
        final List<dynamic> totalUsers = jsonDecode(totalResponse.body);
        total = totalUsers.length;
      }

      if (studentsResponse.statusCode == 200) {
        final List<dynamic> studentUsers = jsonDecode(studentsResponse.body);
        students = studentUsers.length;
      }

      if (seekersResponse.statusCode == 200) {
        final List<dynamic> seekerUsers = jsonDecode(seekersResponse.body);
        seekers = seekerUsers.length;
      }

      return {
        'total': total,
        'students': students,
        'seekers': seekers,
      };
    } catch (e) {
      print('Исключение при получении статистики: $e');
      return {
        'total': 0,
        'students': 0,
        'seekers': 0,
      };
    }
  }
}
