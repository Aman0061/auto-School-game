import 'package:flutter/material.dart';
import '../models/driving_school.dart';
import '../services/driving_school_service.dart';

class DrivingSchoolProvider extends ChangeNotifier {
  final DrivingSchoolService _service = DrivingSchoolService();
  
  List<DrivingSchool> _schools = [];
  List<LicenseCategory> _categories = [];
  Map<String, List<SchoolPrice>> _schoolPrices = {}; // Кэш цен по ID школы
  
  bool _isLoading = false;
  int _pageSize = 10; // Размер страницы для пагинации
  int _currentOffset = 0;
  bool _hasMoreData = true; // Добавляем поле для отслеживания наличия больше данных
  
  // Геттеры
  List<DrivingSchool> get schools => _schools;
  List<LicenseCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;

  // Загрузка автошкол (только первые 10)
  Future<void> loadDrivingSchools() async {
    // Если данные уже загружены и не пустые, не загружаем повторно
    if (_schools.isNotEmpty && !_isLoading) {
      print('Данные уже загружены, пропускаем повторную загрузку');
      return;
    }
    
    _isLoading = true;
    _schools.clear();
    _currentOffset = 0;
    _hasMoreData = true;
    notifyListeners();

    try {
      // Загружаем только первые 10 автошкол
      final schools = await _service.getDrivingSchoolsPaginated(offset: 0, limit: _pageSize);
      _schools.addAll(schools);
      
      // Проверяем, есть ли еще данные
      _hasMoreData = schools.length == _pageSize;
      _currentOffset = _pageSize;
      
      // Загружаем категории
      _categories = await _service.getLicenseCategories();
      
      print('Загружено ${_schools.length} автошкол');
      print('Есть еще данные: $_hasMoreData');
      
    } catch (e) {
      print('Ошибка при загрузке автошкол: $e');
      // В случае ошибки используем тестовые данные
      final mockData = _service.getMockData();
      _schools.addAll(mockData);
      _categories = _service.getMockCategories();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Загрузка дополнительных автошкол
  Future<void> loadMoreDrivingSchools() async {
    if (_isLoading || !_hasMoreData) {
      return;
    }
    
    _isLoading = true;
    // НЕ вызываем notifyListeners() здесь, чтобы избежать перестройки UI

    try {
      final moreSchools = await _service.getDrivingSchoolsPaginated(
        offset: _currentOffset, 
        limit: _pageSize
      );
      
      if (moreSchools.isNotEmpty) {
        _schools.addAll(moreSchools);
        _currentOffset += moreSchools.length;
        _hasMoreData = moreSchools.length == _pageSize;
        
        print('Загружено еще ${moreSchools.length} автошкол');
        print('Всего автошкол: ${_schools.length}');
        print('Есть еще данные: $_hasMoreData');
      } else {
        _hasMoreData = false;
        print('Больше данных нет');
      }
      
    } catch (e) {
      print('Ошибка при загрузке дополнительных автошкол: $e');
    }

    _isLoading = false;
    // Вызываем notifyListeners() только в конце
    notifyListeners();
  }

  // Загрузка цен для конкретной школы
  Future<List<SchoolPrice>> loadSchoolPrices(String schoolId) async {
    // Если цены уже загружены, возвращаем из кэша
    if (_schoolPrices.containsKey(schoolId)) {
      return _schoolPrices[schoolId]!;
    }

    try {
      final prices = await _service.getSchoolPrices(schoolId);
      _schoolPrices[schoolId] = prices;
      return prices;
    } catch (e) {
      print('Ошибка при загрузке цен для школы $schoolId: $e');
      return [];
    }
  }

  // Получение категорий для конкретной школы
  Future<List<String>> getSchoolCategories(String schoolId) async {
    final prices = await loadSchoolPrices(schoolId);
    return prices.map((price) => price.categoryId?.toString() ?? '').where((id) => id.isNotEmpty).toList();
  }

  // Получение цены для конкретной категории
  Future<int?> getPriceForCategory(String schoolId, String categoryCode) async {
    final prices = await loadSchoolPrices(schoolId);
    final categoryId = int.tryParse(categoryCode);
    if (categoryId == null) return null;
    
    final price = prices.firstWhere(
      (price) => price.categoryId == categoryId,
      orElse: () => SchoolPrice(id: 0, price: 0),
    );
    return price.price > 0 ? price.price : null;
  }

  // Сброс фильтров
  void resetFilters() {
    loadDrivingSchools();
  }
}
