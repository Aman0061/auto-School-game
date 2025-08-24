import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket.dart';
import '../models/question.dart';
import '../models/answer.dart';

class TicketProvider extends ChangeNotifier {
  List<Ticket> _tickets = [];
  List<Ticket> _medicalTickets = [];
  bool _isLoading = false;
  Ticket? _currentTicket;
  int _currentQuestionIndex = 0;
  List<int> _userAnswers = [];
  bool _isQuizActive = false;
  Map<String, int> _ticketProgress = {}; // Прогресс по билетам
  Map<String, int> _ticketTime = {}; // Время прохождения билетов в секундах

  List<Ticket> get tickets => _tickets;
  List<Ticket> get medicalTickets => _medicalTickets;
  bool get isLoading => _isLoading;
  Ticket? get currentTicket => _currentTicket;
  int get currentQuestionIndex => _currentQuestionIndex;
  List<int> get userAnswers => _userAnswers;
  bool get isQuizActive => _isQuizActive;

  // Загрузка всех билетов
  Future<void> loadTickets() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Загружаем прогресс
      await _loadProgress();
      
      // Загружаем основные билеты
      final questionsJson = await rootBundle.loadString('assets/data/questions.json');
      final questionsList = jsonDecode(questionsJson) as List;
      
      // Создаем 26 билетов по 20 вопросов (последний 16)
      _tickets = [];
      int questionIndex = 0;
      
      for (int i = 1; i <= 26; i++) {
        final questionsInTicket = i == 26 ? 16 : 20;
        final ticketQuestions = <Question>[];
        
        for (int j = 0; j < questionsInTicket && questionIndex < questionsList.length; j++) {
          final questionData = questionsList[questionIndex];
          final answers = (questionData['answers'] as List).map((answerData) {
            return Answer.fromJson(answerData);
          }).toList();
          
          ticketQuestions.add(Question.fromJson({
            ...questionData,
            'answers': answers.map((a) => a.toJson()).toList(),
          }));
          
          questionIndex++;
        }
        
        _tickets.add(Ticket(
          id: 'ticket_$i',
          title: 'Билет $i',
          description: 'Вопросы по ПДД',
          questions: ticketQuestions,
        ));
      }

      // Загружаем медицинский билет
      final medicalJson = await rootBundle.loadString('assets/data/medical.json');
      final medicalList = jsonDecode(medicalJson) as List;
      
      final medicalQuestions = medicalList.map((questionData) {
        final answers = (questionData['answers'] as List).map((answerData) {
          return Answer.fromJson(answerData);
        }).toList();
        
        return Question.fromJson({
          ...questionData,
          'answers': answers.map((a) => a.toJson()).toList(),
        });
      }).toList();

      _medicalTickets = [
        Ticket(
          id: 'medical_ticket',
          title: 'Медицинский билет',
          description: 'Оказание первой помощи',
          questions: medicalQuestions,
          isMedical: true,
        ),
      ];

    } catch (e) {
      print('Ошибка загрузки билетов: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Начать тест по билету
  void startTicket(String ticketId) {
    final ticket = _tickets.firstWhere((t) => t.id == ticketId);
    if (ticket == null) return;
    
    _currentTicket = ticket;
    _currentQuestionIndex = 0;
    _userAnswers = List.filled(ticket.questions.length, -1);
    _isQuizActive = true;
    notifyListeners();
  }

  // Начать медицинский тест
  void startMedicalTicket() {
    if (_medicalTickets.isEmpty) return;
    
    final ticket = _medicalTickets.first;
    _currentTicket = ticket;
    _currentQuestionIndex = 0;
    _userAnswers = List.filled(ticket.questions.length, -1);
    _isQuizActive = true;
    notifyListeners();
  }

  // Ответить на вопрос
  void answerQuestion(int answerIndex) {
    if (_currentTicket == null || _currentQuestionIndex >= _userAnswers.length) return;
    
    _userAnswers[_currentQuestionIndex] = answerIndex;
    notifyListeners();
  }

  // Следующий вопрос
  void nextQuestion() {
    if (_currentTicket == null) return;
    
    if (_currentQuestionIndex < _currentTicket!.questions.length - 1) {
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

  // Завершить тест
  void finishTicket() {
    _isQuizActive = false;
    _currentTicket = null;
    _currentQuestionIndex = 0;
    _userAnswers = [];
    notifyListeners();
  }

  // Получить текущий вопрос
  Question? get currentQuestion {
    if (_currentTicket == null || _currentQuestionIndex >= _currentTicket!.questions.length) {
      return null;
    }
    return _currentTicket!.questions[_currentQuestionIndex];
  }

  // Получить результат теста
  TicketResult getTicketResult() {
    if (_currentTicket == null) {
      return TicketResult(correctAnswers: 0, totalQuestions: 0, percentage: 0);
    }

    int correctAnswers = 0;
    for (int i = 0; i < _userAnswers.length; i++) {
      if (_userAnswers[i] != -1 && _currentTicket!.questions[i].isCorrect(_userAnswers[i])) {
        correctAnswers++;
      }
    }

    final percentage = (_userAnswers.where((answer) => answer != -1).length / _userAnswers.length * 100).round();
    
    return TicketResult(
      correctAnswers: correctAnswers,
      totalQuestions: _userAnswers.where((answer) => answer != -1).length,
      percentage: percentage,
    );
  }

  // Получить прогресс билета
  double getTicketProgress(String ticketId) {
    final progress = _ticketProgress[ticketId] ?? 0;
    return progress / 100.0;
  }

  // Получить процент прогресса билета
  int getTicketProgressPercent(String ticketId) {
    return _ticketProgress[ticketId] ?? 0;
  }

  // Проверить, завершен ли билет
  bool isTicketCompleted(String ticketId) {
    final progress = _ticketProgress[ticketId] ?? 0;
    // Считаем завершенным при 80% и более (что соответствует 2 ошибкам или меньше из 20 вопросов)
    return progress >= 80;
  }

  // Проверить, провален ли билет (менее 80%)
  bool isTicketFailed(String ticketId) {
    final progress = _ticketProgress[ticketId] ?? 0;
    return progress > 0 && progress < 80; // Провален если есть попытка, но менее 80%
  }

  // Получить количество завершенных билетов
  int getCompletedTicketsCount() {
    int completed = 0;
    for (final ticket in _tickets) {
      if (isTicketCompleted(ticket.id)) {
        completed++;
      }
    }
    for (final ticket in _medicalTickets) {
      if (isTicketCompleted(ticket.id)) {
        completed++;
      }
    }
    return completed;
  }

  // Загрузить прогресс
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Загружаем прогресс
      final progressString = prefs.getString('ticket_progress');
      if (progressString != null) {
        final progressMap = Map<String, dynamic>.from(
          jsonDecode(progressString) as Map,
        );
        _ticketProgress = progressMap.map((key, value) => MapEntry(key, value as int));
      }
      
      // Загружаем время
      final timeString = prefs.getString('ticket_time');
      if (timeString != null) {
        final timeMap = Map<String, dynamic>.from(
          jsonDecode(timeString) as Map,
        );
        _ticketTime = timeMap.map((key, value) => MapEntry(key, value as int));
      }
    } catch (e) {
      print('Ошибка загрузки прогресса билетов: $e');
    }
  }

  // Сохранить прогресс
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Сохраняем прогресс
      final progressString = jsonEncode(_ticketProgress);
      await prefs.setString('ticket_progress', progressString);
      
      // Сохраняем время
      final timeString = jsonEncode(_ticketTime);
      await prefs.setString('ticket_time', timeString);
    } catch (e) {
      print('Ошибка сохранения прогресса билетов: $e');
    }
  }

  // Обновить прогресс билета
  Future<void> updateTicketProgress(String ticketId, int progress) async {
    _ticketProgress[ticketId] = progress;
    await _saveProgress();
    notifyListeners();
  }

  // Обновить время прохождения билета
  Future<void> updateTicketTime(String ticketId, int timeSeconds) async {
    _ticketTime[ticketId] = timeSeconds;
    await _saveProgress();
    notifyListeners();
  }

  // Получить время прохождения билета
  int getTicketTime(String ticketId) {
    return _ticketTime[ticketId] ?? 0;
  }

  // Форматировать время в читаемый вид
  String formatTicketTime(String ticketId) {
    final seconds = _ticketTime[ticketId] ?? 0;
    if (seconds == 0) return '0 мин';
    
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (minutes == 0) {
      return '${remainingSeconds} сек';
    } else if (remainingSeconds == 0) {
      return '${minutes} мин';
    } else {
      return '${minutes} мин ${remainingSeconds} сек';
    }
  }
}

// Результат теста
class TicketResult {
  final int correctAnswers;
  final int totalQuestions;
  final int percentage;

  TicketResult({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.percentage,
  });
}
