import 'package:flutter/material.dart';
import '../models/driving_school.dart';
import '../services/driving_school_service.dart';

class DrivingSchoolProvider extends ChangeNotifier {
  List<DrivingSchool> _schools = [];
  List<LicenseCategory> _categories = [];
  Map<String, List<SchoolPrice>> _schoolPrices = {};
  bool _isLoading = false;
  final DrivingSchoolService _service = DrivingSchoolService();

  List<DrivingSchool> get schools => _schools;
  List<LicenseCategory> get categories => _categories;
  bool get isLoading => _isLoading;

  // Загрузка автошкол
  Future<void> loadDrivingSchools() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Загружаем данные из Supabase
      _schools = await _service.getDrivingSchools();
      
      // Загружаем категории
      _categories = await _service.getLicenseCategories();
      
      // Загружаем цены для каждой автошколы
      for (final school in _schools) {
        final prices = await _service.getSchoolPrices(school.id);
        _schoolPrices[school.id] = prices;
        print('Загружены цены для школы ${school.name}: ${prices.length} цен');
      }
    } catch (e) {
      print('Ошибка при загрузке автошкол: $e');
      // В случае ошибки используем тестовые данные
      _schools = _service.getMockData();
      _categories = _service.getMockCategories();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Получение автошколы по ID
  DrivingSchool? getSchoolById(String id) {
    try {
      return _schools.firstWhere((school) => school.id == id);
    } catch (e) {
      return null;
    }
  }

  // Получение цен для автошколы
  List<SchoolPrice> getSchoolPrices(String schoolId) {
    return _schoolPrices[schoolId] ?? [];
  }

  // Получение категорий для автошколы (из цен)
  List<String> getSchoolCategories(String schoolId) {
    final prices = _schoolPrices[schoolId];
    if (prices == null) return [];
    
    final categoryIds = prices
        .where((p) => p.categoryId != null && p.isActive)
        .map((p) => p.categoryId!)
        .toSet();
    
    return _categories
        .where((cat) => categoryIds.contains(cat.id))
        .map((cat) => cat.code)
        .toList();
  }

  // Получение цены по категории для автошколы
  int? getPriceForCategory(String schoolId, String categoryCode) {
    final prices = _schoolPrices[schoolId];
    if (prices == null) return null;
    
    final category = _categories.firstWhere(
      (cat) => cat.code == categoryCode,
      orElse: () => LicenseCategory(id: 0, code: '', name: ''),
    );
    
    if (category.id == 0) return null;
    
    final price = prices.firstWhere(
      (p) => p.categoryId == category.id && p.isActive,
      orElse: () => SchoolPrice(
        id: 0,
        schoolId: schoolId,
        categoryId: category.id,
        price: 0,
        createdAt: null,
      ),
    );
    
    return price.price > 0 ? price.price : null;
  }

  // Создание новой автошколы
  Future<bool> createDrivingSchool(DrivingSchool school) async {
    final success = await _service.createDrivingSchool(school);
    if (success) {
      await loadDrivingSchools(); // Перезагружаем список
    }
    return success;
  }

  // Создание цены для автошколы
  Future<bool> createSchoolPrice(SchoolPrice price) async {
    final success = await _service.createSchoolPrice(price);
    if (success) {
      await loadDrivingSchools(); // Перезагружаем список
    }
    return success;
  }

  // Обновление автошколы
  Future<bool> updateDrivingSchool(String id, DrivingSchool school) async {
    final success = await _service.updateDrivingSchool(id, school);
    if (success) {
      await loadDrivingSchools(); // Перезагружаем список
    }
    return success;
  }

  // Удаление автошколы
  Future<bool> deleteDrivingSchool(String id) async {
    final success = await _service.deleteDrivingSchool(id);
    if (success) {
      await loadDrivingSchools(); // Перезагружаем список
    }
    return success;
  }

  // Фильтрация автошкол по цене
  List<DrivingSchool> getSchoolsByPriceRange(double minPrice, double maxPrice) {
    return _schools.where((school) => 
      school.price >= minPrice && school.price <= maxPrice
    ).toList();
  }

  // Фильтрация автошкол по рейтингу
  List<DrivingSchool> getSchoolsByRating(double minRating) {
    return _schools.where((school) => (school.rating ?? 0) >= minRating).toList();
  }

  // Сортировка автошкол по цене
  List<DrivingSchool> getSchoolsSortedByPrice({bool ascending = true}) {
    final sorted = List<DrivingSchool>.from(_schools);
    if (ascending) {
      sorted.sort((a, b) => a.price.compareTo(b.price));
    } else {
      sorted.sort((a, b) => b.price.compareTo(a.price));
    }
    return sorted;
  }

  // Сортировка автошкол по рейтингу
  List<DrivingSchool> getSchoolsSortedByRating({bool ascending = false}) {
    final sorted = List<DrivingSchool>.from(_schools);
    if (ascending) {
      sorted.sort((a, b) => (a.rating ?? 0).compareTo(b.rating ?? 0));
    } else {
      sorted.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    }
    return sorted;
  }
}
