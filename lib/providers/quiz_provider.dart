import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/question.dart';
import '../models/module.dart';
import '../models/answer.dart';
import '../services/image_service.dart';

class QuizProvider extends ChangeNotifier {
  List<Module> _modules = [];
  List<Question> _questions = [];
  Module? _currentModule;
  int _currentQuestionIndex = 0;
  List<int> _userAnswers = [];
  bool _isQuizActive = false;
  bool _isLoading = false;
  Map<String, int> _moduleProgress = {};

  List<Module> get modules => _modules;
  List<Question> get questions => _questions;
  Module? get currentModule => _currentModule;
  int get currentQuestionIndex => _currentQuestionIndex;
  List<int> get userAnswers => _userAnswers;
  bool get isQuizActive => _isQuizActive;
  bool get isLoading => _isLoading;
  Question? get currentQuestion => 
      _questions.isNotEmpty && _currentQuestionIndex < _questions.length 
          ? _questions[_currentQuestionIndex] 
          : null;
  
  Map<String, int> get moduleProgress => _moduleProgress;

  // Загрузка модулей
  Future<void> loadModules() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Загружаем данные изображений
      await ImageService().loadImageData();
      
      // Загружаем сохраненный прогресс
      await _loadProgress();
      
      // Имитация загрузки модулей
      await Future.delayed(const Duration(seconds: 1));
      
      _modules = [
        Module(
          id: 'exam',
          title: 'ЭКЗАМЕН',
          description: 'Итоговый экзамен по всем темам',
          questionCount: 20,
          isExam: true,
        ),
        Module(
          id: 'module_1',
          title: 'Билет 1',
          description: 'Основы безопасности дорожного движения',
          questionCount: 10,
        ),
        Module(
          id: 'module_2',
          title: 'Билет 2',
          description: 'Правила дорожного движения',
          questionCount: 10,
        ),
        Module(
          id: 'module_3',
          title: 'Билет 3',
          description: 'Дорожные знаки и разметка',
          questionCount: 10,
        ),
        Module(
          id: 'module_4',
          title: 'Билет 4',
          description: 'Сигналы светофора и регулировщика',
          questionCount: 10,
        ),
        Module(
          id: 'module_5',
          title: 'Билет 5',
          description: 'Начало движения и маневрирование',
          questionCount: 10,
        ),
        Module(
          id: 'module_6',
          title: 'Билет 6',
          description: 'Расположение транспортных средств',
          questionCount: 10,
        ),
        Module(
          id: 'module_7',
          title: 'Билет 7',
          description: 'Скорость движения',
          questionCount: 10,
        ),
        Module(
          id: 'module_8',
          title: 'Билет 8',
          description: 'Обгон и опережение',
          questionCount: 10,
        ),
        Module(
          id: 'module_9',
          title: 'Билет 9',
          description: 'Остановка и стоянка',
          questionCount: 10,
        ),
        Module(
          id: 'module_10',
          title: 'Билет 10',
          description: 'Проезд перекрестков',
          questionCount: 10,
        ),
        Module(
          id: 'module_11',
          title: 'Билет 11',
          description: 'Пешеходные переходы',
          questionCount: 10,
        ),
        Module(
          id: 'module_12',
          title: 'Билет 12',
          description: 'Железнодорожные переезды',
          questionCount: 10,
        ),
        Module(
          id: 'module_13',
          title: 'Билет 13',
          description: 'Движение по автомагистралям',
          questionCount: 10,
        ),
        Module(
          id: 'module_14',
          title: 'Билет 14',
          description: 'Движение в жилых зонах',
          questionCount: 10,
        ),
        Module(
          id: 'module_15',
          title: 'Билет 15',
          description: 'Перевозка пассажиров',
          questionCount: 10,
        ),
        Module(
          id: 'module_16',
          title: 'Билет 16',
          description: 'Перевозка грузов',
          questionCount: 10,
        ),
        Module(
          id: 'module_17',
          title: 'Билет 17',
          description: 'Буксировка механических транспортных средств',
          questionCount: 10,
        ),
        Module(
          id: 'module_18',
          title: 'Билет 18',
          description: 'Учебная езда',
          questionCount: 10,
        ),
        Module(
          id: 'module_19',
          title: 'Билет 19',
          description: 'Движение транспортных средств в колоннах',
          questionCount: 10,
        ),
        Module(
          id: 'module_20',
          title: 'Билет 20',
          description: 'Движение по тихим улицам',
          questionCount: 10,
        ),
        Module(
          id: 'module_21',
          title: 'Билет 21',
          description: 'Движение в темное время суток',
          questionCount: 10,
        ),
        Module(
          id: 'module_22',
          title: 'Билет 22',
          description: 'Движение в условиях недостаточной видимости',
          questionCount: 10,
        ),
        Module(
          id: 'module_23',
          title: 'Билет 23',
          description: 'Движение в сложных дорожных условиях',
          questionCount: 10,
        ),
        Module(
          id: 'module_24',
          title: 'Билет 24',
          description: 'Движение по горным дорогам',
          questionCount: 10,
        ),
        Module(
          id: 'module_25',
          title: 'Билет 25',
          description: 'Движение по ледовым переправам',
          questionCount: 10,
        ),
        Module(
          id: 'module_26',
          title: 'Билет 26',
          description: 'Движение по маршрутам регулярных перевозок',
          questionCount: 10,
        ),
        Module(
          id: 'medical',
          title: 'Доврачебная помощь',
          description: 'Основы оказания первой помощи',
          questionCount: 10,
        ),
      ];
    } catch (e) {
      // Обработка ошибок
    }

    _isLoading = false;
    notifyListeners();
  }

  // Загрузка вопросов для модуля
  Future<void> loadQuestionsForModule(String moduleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // Генерируем демо-вопросы
      _questions = _generateDemoQuestions(moduleId);
      _currentModule = _modules.firstWhere((module) => module.id == moduleId);
      _currentQuestionIndex = 0;
      _userAnswers = List.filled(_questions.length, -1);
      _isQuizActive = true;
    } catch (e) {
      // Обработка ошибок
    }

    _isLoading = false;
    notifyListeners();
  }

  // Ответ на вопрос
  void answerQuestion(int answerIndex) {
    if (_currentQuestionIndex < _userAnswers.length) {
      _userAnswers[_currentQuestionIndex] = answerIndex;
      notifyListeners();
    }
  }

  // Следующий вопрос
  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  // Предыдущий вопрос
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  // Завершение квиза
  void finishQuiz() {
    _isQuizActive = false;
    notifyListeners();
  }

  // Сброс квиза
  void resetQuiz() {
    _currentQuestionIndex = 0;
    _userAnswers = [];
    _isQuizActive = false;
    _questions = [];
    _currentModule = null;
    notifyListeners();
  }

  // Получение результатов
  QuizResult getQuizResult() {
    int correctAnswers = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == _questions[i].correctAnswerIndex) {
        correctAnswers++;
      }
    }
    
    return QuizResult(
      totalQuestions: _questions.length,
      correctAnswers: correctAnswers,
      percentage: (_questions.length > 0) 
          ? (correctAnswers / _questions.length * 100).round() 
          : 0,
    );
  }

  // Генерация демо-вопросов
  List<Question> _generateDemoQuestions(String moduleId) {
    final questions = <Question>[];
    final imageService = ImageService();
    
    for (int i = 0; i < 10; i++) {
      // Выбираем изображение в зависимости от типа модуля
      String? imagePath;
      if (moduleId.contains('module_1') || moduleId.contains('module_3')) {
        // Для модулей со знаками используем изображения знаков
        imagePath = imageService.getRandomImageByCategory('traffic_signs');
      } else if (moduleId.contains('module_2') || moduleId.contains('module_4')) {
        // Для модулей с ситуациями используем дорожные ситуации
        imagePath = imageService.getRandomImageByCategory('road_situations');
      } else if (moduleId.contains('medical')) {
        // Для медицинского модуля используем пешеходные переходы
        imagePath = imageService.getRandomImageByCategory('pedestrian');
      } else {
        // Для остальных модулей случайное изображение
        imagePath = imageService.getRandomImage();
      }
      
      // 30% вопросов без изображений для разнообразия
      if (i % 3 == 0) {
        imagePath = null;
      }
      
      // Создаем ответы для вопроса
      final options = _generateQuestionOptions(moduleId, i + 1);
      final answers = options.asMap().entries.map((entry) {
        return Answer(
          id: entry.key + 1,
          text: entry.value,
          correct: entry.key == (i % 4),
        );
      }).toList();
      
      questions.add(Question(
        id: i + 1,
        text: _generateQuestionText(moduleId, i + 1),
        answers: answers,
        image: imagePath,
      ));
    }
    
    return questions;
  }

  // Генерация текста вопроса в зависимости от модуля
  String _generateQuestionText(String moduleId, int questionNumber) {
    final moduleQuestions = {
      'module_1': [
        'Что означает данный дорожный знак?',
        'Какое действие должен предпринять водитель в данной ситуации?',
        'Какой знак предупреждает о приближении к пешеходному переходу?',
        'Что запрещает данный знак?',
        'Какой знак устанавливается перед железнодорожным переездом?',
        'Что означает желтый мигающий сигнал светофора?',
        'Какой знак указывает на главную дорогу?',
        'Что означает знак "Ограничение скорости"?',
        'Какой знак предупреждает о крутом повороте?',
        'Что означает знак "Движение запрещено"?',
      ],
      'module_2': [
        'В каком месте разрешена остановка транспортного средства?',
        'Какая максимальная скорость разрешена в населенном пункте?',
        'Как должен поступить водитель при приближении к пешеходному переходу?',
        'В каком случае разрешен обгон?',
        'Какой должна быть дистанция между транспортными средствами?',
        'Что означает сплошная линия разметки?',
        'Как должен поступить водитель при желтом сигнале светофора?',
        'В каком месте запрещена стоянка?',
        'Какой знак дает преимущество в движении?',
        'Что означает прерывистая линия разметки?',
      ],
      'exam': [
        'Комплексный вопрос по всем темам ПДД №$questionNumber',
        'Ситуационная задача по дорожному движению №$questionNumber',
        'Вопрос на знание дорожных знаков №$questionNumber',
        'Задача по правилам проезда перекрестков №$questionNumber',
        'Вопрос по оказанию первой помощи №$questionNumber',
        'Ситуация на дороге с пешеходами №$questionNumber',
        'Вопрос по сигналам светофора №$questionNumber',
        'Задача по обгону и опережению №$questionNumber',
        'Вопрос по остановке и стоянке №$questionNumber',
        'Ситуация с железнодорожным переездом №$questionNumber',
      ],
    };

    return moduleQuestions[moduleId]?[questionNumber - 1] ?? 
           'Вопрос $questionNumber для модуля $moduleId. Какой правильный ответ?';
  }

  // Генерация вариантов ответов
  List<String> _generateQuestionOptions(String moduleId, int questionNumber) {
    final options = [
      'Правильный ответ',
      'Неправильный вариант',
      'Частично правильный ответ',
      'Полностью неправильный ответ',
    ];
    
    // Перемешиваем варианты ответов для разнообразия
    final shuffled = List<String>.from(options);
    shuffled.shuffle();
    
    return shuffled;
  }

  // Генерация объяснений
  String _generateExplanation(String moduleId, int questionNumber) {
    return 'Подробное объяснение правильного ответа на вопрос $questionNumber модуля $moduleId. '
           'Это поможет лучше понять правила дорожного движения и избежать подобных ошибок в будущем.';
  }

  // Загрузка прогресса
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressString = prefs.getString('module_progress');
      if (progressString != null) {
        final progressMap = Map<String, dynamic>.from(
          jsonDecode(progressString) as Map,
        );
        _moduleProgress = progressMap.map((key, value) => MapEntry(key, value as int));
      }
    } catch (e) {
      print('Ошибка загрузки прогресса: $e');
    }
  }

  // Сохранение прогресса
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressString = jsonEncode(_moduleProgress);
      await prefs.setString('module_progress', progressString);
    } catch (e) {
      print('Ошибка сохранения прогресса: $e');
    }
  }

  // Обновление прогресса модуля
  Future<void> updateModuleProgress(String moduleId, int progress) async {
    _moduleProgress[moduleId] = progress;
    await _saveProgress();
    notifyListeners();
  }

  // Получение прогресса модуля
  int getModuleProgress(String moduleId) {
    return _moduleProgress[moduleId] ?? 0;
  }
}

class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int percentage;

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.percentage,
  });
}
