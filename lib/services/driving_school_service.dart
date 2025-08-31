import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/driving_school.dart';

class DrivingSchoolService {
  static const String _baseUrl = 'https://bpenxrpooolbnldsgtvq.supabase.co/rest/v1';
  static const String _apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJwZW54cnBvb29sYm5sZHNndHZxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwMzU4NDcsImV4cCI6MjA3MTYxMTg0N30.RlohQxcbaloXW7lKpRsqWzHP7AoP_LDkMp2kgVaPWug';

  // Получение автошкол (только первые 10)
  Future<List<DrivingSchool>> getDrivingSchools() async {
    return getDrivingSchoolsPaginated(offset: 0, limit: 10);
  }

  // Получение автошкол с постраничной загрузкой
  Future<List<DrivingSchool>> getDrivingSchoolsPaginated({int offset = 0, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/driving_schools?select=*'),
        headers: {
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Сортируем: сначала оплаченные (payed = true), потом остальные
        final sortedData = List<Map<String, dynamic>>.from(data);
        sortedData.sort((a, b) {
          final aPayed = a['payed'] as bool? ?? false;
          final bPayed = b['payed'] as bool? ?? false;
          if (aPayed && !bPayed) return -1;
          if (!aPayed && bPayed) return 1;
          return 0;
        });
        
        // Применяем постраничную загрузку
        final startIndex = offset;
        final endIndex = offset + limit;
        final limitedData = sortedData.skip(startIndex).take(limit).toList();
        
        print('Загружаем автошколы с $startIndex по $endIndex (всего: ${limitedData.length})');
        
        return limitedData.map((json) => DrivingSchool.fromJson(json)).toList();
      } else {
        print('Ошибка загрузки автошкол: ${response.statusCode} - ${response.body}');
        throw Exception('Ошибка загрузки автошкол: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при получении автошкол: $e');
      // Возвращаем тестовые данные в случае ошибки
      return getMockData();
    }
  }



  // Получение всех категорий прав
  Future<List<LicenseCategory>> getLicenseCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/license_categories?select=*'),
        headers: {
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Получены категории: ${json.encode(data)}');
        return data.map((json) => LicenseCategory.fromJson(json)).toList();
      } else {
        print('Ошибка загрузки категорий: ${response.statusCode} - ${response.body}');
        throw Exception('Ошибка загрузки категорий: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при получении категорий: $e');
      return getMockCategories();
    }
  }

  // Получение цен для конкретной автошколы
  Future<List<SchoolPrice>> getSchoolPrices(String schoolId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/school_prices?school_id=eq.$schoolId&is_active=eq.true&select=*'),
        headers: {
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Получены цены для школы $schoolId: ${json.encode(data)}');
        
        final prices = <SchoolPrice>[];
        for (final item in data) {
          try {
            final price = SchoolPrice.fromJson(item);
            prices.add(price);
          } catch (e) {
            print('Ошибка парсинга цены: $e для данных: $item');
          }
        }
        return prices;
      } else {
        print('Ошибка загрузки цен: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Ошибка при получении цен: $e');
      return [];
    }
  }

  // Получение автошколы по ID
  Future<DrivingSchool?> getDrivingSchoolById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/driving_schools?id=eq.$id&select=*'),
        headers: {
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return DrivingSchool.fromJson(data.first);
        }
      }
      return null;
    } catch (e) {
      print('Ошибка при получении автошколы по ID: $e');
      return null;
    }
  }

  // Создание новой автошколы
  Future<bool> createDrivingSchool(DrivingSchool school) async {
    try {
      final jsonData = school.toJson();
      print('Отправляем данные в базу: ${json.encode(jsonData)}');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/driving_schools'),
        headers: {
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: json.encode(jsonData),
      );

      print('Ответ сервера: ${response.statusCode} - ${response.body}');
      return response.statusCode == 201;
    } catch (e) {
      print('Ошибка при создании автошколы: $e');
      return false;
    }
  }

  // Создание цены для автошколы
  Future<bool> createSchoolPrice(SchoolPrice price) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/school_prices'),
        headers: {
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: json.encode(price.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Ошибка при создании цены: $e');
      return false;
    }
  }

  // Обновление автошколы
  Future<bool> updateDrivingSchool(String id, DrivingSchool school) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/driving_schools?id=eq.$id'),
        headers: {
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: json.encode(school.toJson()),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Ошибка при обновлении автошколы: $e');
      return false;
    }
  }

  // Удаление автошколы
  Future<bool> deleteDrivingSchool(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/driving_schools?id=eq.$id'),
        headers: {
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Ошибка при удалении автошколы: $e');
      return false;
    }
  }

  // Тестовые данные для fallback
  List<DrivingSchool> getMockData() {
    final now = DateTime.now();
    return [
      DrivingSchool(
        id: 'school_1',
        name: 'DriveWise Academy',
        city: 'Bishkek',
        address: 'Abdrahmanova 123',
        phone: '+996 (312) 123-45-67',
        categories: ['B'],
        priceFrom: 25000,
        rating: 4.7,
        reviewsCount: 127,
        description: 'Профессиональное обучение вождению с индивидуальным подходом.',
        payed: true,
        approved: true,
        createdAt: now,
        updatedAt: now,
      ),
      DrivingSchool(
        id: 'school_2',
        name: 'BCD',
        city: 'Bishkek',
        address: 'Abdrahmanova 123',
        phone: '+996 (312) 987-65-43',
        categories: ['B', 'C'],
        priceFrom: 25000,
        rating: 4.7,
        reviewsCount: 89,
        description: 'Крупнейшая сеть автошкол в Кыргызстане.',
        payed: false,
        approved: true,
        createdAt: now,
        updatedAt: now,
      ),
      DrivingSchool(
        id: 'school_3',
        name: 'Форсаж',
        city: 'Bishkek',
        address: 'Abdrahmanova 123',
        phone: '+996 (312) 555-12-34',
        categories: ['B'],
        priceFrom: 22000,
        rating: 4.7,
        reviewsCount: 56,
        description: 'Быстрое и качественное обучение вождению.',
        payed: false,
        approved: true,
        createdAt: now,
        updatedAt: now,
      ),
      DrivingSchool(
        id: 'school_4',
        name: 'Dasmia',
        city: 'Bishkek',
        address: 'Abdrahmanova 123',
        phone: '+996 (312) 777-88-99',
        categories: ['B', 'C', 'D'],
        priceFrom: 30000,
        rating: 4.7,
        reviewsCount: 34,
        description: 'Элитная автошкола с премиум-обслуживанием.',
        payed: false,
        approved: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  // Тестовые категории
  List<LicenseCategory> getMockCategories() {
    return [
      LicenseCategory(
        id: 1,
        code: 'A',
        name: 'Мотоциклы',
        description: 'Мотоциклы, мотороллеры и другие мототранспортные средства',
      ),
      LicenseCategory(
        id: 2,
        code: 'B',
        name: 'Легковые автомобили',
        description: 'Легковые автомобили с разрешенной максимальной массой не более 3500 кг',
      ),
      LicenseCategory(
        id: 3,
        code: 'C',
        name: 'Грузовые автомобили',
        description: 'Грузовые автомобили с разрешенной максимальной массой более 3500 кг',
      ),
      LicenseCategory(
        id: 4,
        code: 'D',
        name: 'Автобусы',
        description: 'Автобусы, предназначенные для перевозки пассажиров',
      ),
    ];
  }
}
