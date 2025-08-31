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
    required String username,
    required String userType,
    String? password,
  }) async {
    try {
      // Сначала проверяем, существует ли пользователь с таким username
      final existingUser = await loginByUsername(username);
      if (existingUser != null) {
        return {
          'success': false,
          'error': 'Пользователь с таким логином уже существует',
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
          'username': username,
          'user_type': userType,
          'password': password ?? 'default_password_${DateTime.now().millisecondsSinceEpoch}',
          'created_at': DateTime.now().toIso8601String(),
          'module_progress': {},
        }),
      );

      print('Регистрация пользователя - статус: ${response.statusCode}');
      print('Регистрация пользователя - ответ: ${response.body}');
      
      if (response.statusCode != 201) {
        try {
          final errorData = jsonDecode(response.body);
          print('Детали ошибки: $errorData');
        } catch (e) {
          print('Не удалось распарсить ошибку: $e');
        }
      }

      if (response.statusCode == 201) {
        // После успешного создания всегда получаем пользователя по username
        // Это обходит проблему с парсингом поля password
        print('Пользователь создан, получаем данные по username...');
        final createdUser = await loginByUsername(username);
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
        
        if (errorData['code'] == '23505' && errorData['message'].contains('username')) {
          errorMessage = 'Пользователь с таким логином уже существует';
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
      
      // Если это ошибка парсинга, попробуем получить пользователя по username
      if (e.toString().contains('FormatException')) {
        try {
          final createdUser = await loginByUsername(username);
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
        'error': 'Ошибка регистрации: ${e.toString()}',
      };
    }
  }

  // Вход пользователя по username
  static Future<User?> loginByUsername(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rest/v1/users?username=eq.$username'),
        headers: {
          'apikey': apiKey,
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        print('Получено пользователей: ${users.length}');
        if (users.isNotEmpty) {
          final userData = users.first;
          print('Данные пользователя: $userData');
          
          // Безопасно извлекаем данные пользователя
          final safeUserData = {
            'id': userData['id']?.toString() ?? '',
            'username': userData['username']?.toString() ?? '',
            'name': userData['name']?.toString() ?? '',
            'userType': userData['user_type']?.toString() ?? 'seeker',
            'createdAt': userData['created_at']?.toString() ?? DateTime.now().toIso8601String(),
            'moduleProgress': userData['module_progress'] ?? {},
          };
          
          print('Безопасные данные: $safeUserData');
          
          // Проверяем, что все обязательные поля присутствуют
          if (safeUserData['id']!.isEmpty || 
              safeUserData['username']!.isEmpty || 
              safeUserData['name']!.isEmpty) {
            print('Ошибка: отсутствуют обязательные поля');
            return null;
          }

          return User.fromJson(safeUserData);
        }
      }
      return null;
    } catch (e) {
      print('Ошибка входа по username: $e');
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
          final userData = users.first;
          
          // Безопасно извлекаем данные пользователя
          final safeUserData = {
            'id': userData['id']?.toString() ?? '',
            'username': userData['username']?.toString() ?? '',
            'name': userData['name']?.toString() ?? '',
            'userType': userData['user_type']?.toString() ?? 'seeker',
            'createdAt': userData['created_at']?.toString() ?? DateTime.now().toIso8601String(),
            'moduleProgress': userData['module_progress'] ?? {},
          };

          return User.fromJson(safeUserData);
        }
      }
      return null;
    } catch (e) {
      print('Исключение при получении пользователя: $e');
      return null;
    }
  }

  // Обновление пользователя
  static Future<bool> updateUser(User user) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/rest/v1/users?id=eq.${user.id}'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': apiKey,
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'name': user.name,
          'username': user.username,
          'user_type': user.userType,
          'module_progress': user.moduleProgress,
        }),
      );

      if (response.statusCode == 204) {
        return true;
      }
      return false;
    } catch (e) {
      print('Ошибка обновления пользователя: $e');
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
