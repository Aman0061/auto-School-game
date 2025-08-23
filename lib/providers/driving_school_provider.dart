import 'package:flutter/material.dart';
import '../models/driving_school.dart';

class DrivingSchoolProvider extends ChangeNotifier {
  List<DrivingSchool> _schools = [];
  bool _isLoading = false;

  List<DrivingSchool> get schools => _schools;
  bool get isLoading => _isLoading;

  // Загрузка автошкол
  Future<void> loadDrivingSchools() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Имитация загрузки данных
      await Future.delayed(const Duration(seconds: 1));
      
      _schools = [
        DrivingSchool(
          id: 'school_1',
          name: 'Автошкола "Эксперт"',
          description: 'Профессиональное обучение вождению с индивидуальным подходом. Опытные инструкторы, современные автомобили, удобное расписание.',
          price: 25000.0,
          rating: 4.8,
          reviewCount: 127,
          imagePath: 'assets/images/school_1.jpg',
          address: 'ул. Ленина, 15, Москва',
          phone: '+7 (495) 123-45-67',
          features: [
            'Индивидуальный подход',
            'Современные автомобили',
            'Опытные инструкторы',
            'Гибкое расписание',
            'Практика в реальных условиях'
          ],
          category: 'B',
        ),
        DrivingSchool(
          id: 'school_2',
          name: 'Центр вождения "Мастер"',
          description: 'Крупнейшая сеть автошкол в России. Более 20 лет опыта, тысячи успешных выпускников, гарантия качества.',
          price: 22000.0,
          rating: 4.6,
          reviewCount: 89,
          imagePath: 'assets/images/school_2.jpg',
          address: 'пр. Мира, 42, Москва',
          phone: '+7 (495) 987-65-43',
          features: [
            'Большая сеть филиалов',
            'Опыт более 20 лет',
            'Гарантия качества',
            'Удобные площадки',
            'Поддержка 24/7'
          ],
          category: 'B, C',
        ),
        DrivingSchool(
          id: 'school_3',
          name: 'Автошкола "Старт"',
          description: 'Быстрое и качественное обучение вождению. Интенсивные курсы, доступные цены, высокий процент сдачи экзаменов.',
          price: 18000.0,
          rating: 4.4,
          reviewCount: 56,
          imagePath: 'assets/images/school_3.jpg',
          address: 'ул. Пушкина, 8, Москва',
          phone: '+7 (495) 555-12-34',
          features: [
            'Интенсивные курсы',
            'Доступные цены',
            'Высокий процент сдачи',
            'Молодые инструкторы',
            'Современные методики'
          ],
          category: 'B',
        ),
        DrivingSchool(
          id: 'school_4',
          name: 'Академия вождения "Профи"',
          description: 'Элитная автошкола с премиум-обслуживанием. Персональные инструкторы, VIP-программы, эксклюзивные автомобили.',
          price: 45000.0,
          rating: 4.9,
          reviewCount: 34,
          imagePath: 'assets/images/school_4.jpg',
          address: 'Кутузовский пр., 25, Москва',
          phone: '+7 (495) 777-88-99',
          features: [
            'Премиум-обслуживание',
            'Персональные инструкторы',
            'VIP-программы',
            'Эксклюзивные автомобили',
            'Индивидуальный график'
          ],
          category: 'B, C, D',
        ),
        DrivingSchool(
          id: 'school_5',
          name: 'Автошкола "Надежность"',
          description: 'Проверенная временем автошкола с традиционным подходом к обучению. Стабильное качество, проверенные методики.',
          price: 20000.0,
          rating: 4.5,
          reviewCount: 78,
          imagePath: 'assets/images/school_5.jpg',
          address: 'ул. Тверская, 12, Москва',
          phone: '+7 (495) 333-44-55',
          features: [
            'Проверенные методики',
            'Стабильное качество',
            'Опытные преподаватели',
            'Классический подход',
            'Надежность и стабильность'
          ],
          category: 'B',
        ),
      ];
    } catch (e) {
      // Обработка ошибок
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

  // Фильтрация автошкол по цене
  List<DrivingSchool> getSchoolsByPriceRange(double minPrice, double maxPrice) {
    return _schools.where((school) => 
      school.price >= minPrice && school.price <= maxPrice
    ).toList();
  }

  // Фильтрация автошкол по рейтингу
  List<DrivingSchool> getSchoolsByRating(double minRating) {
    return _schools.where((school) => school.rating >= minRating).toList();
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
      sorted.sort((a, b) => a.rating.compareTo(b.rating));
    } else {
      sorted.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return sorted;
  }
}
