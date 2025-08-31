import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/rewards.dart';
import 'rewards_provider.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;

  TaskProvider() {
    print('TaskProvider: Конструктор вызван');
    // Инициализируем задания сразу при создании
    initializeTasks();
  }

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  // Получение заданий по типу
  List<Task> getTasksByType(TaskType type) {
    print('TaskProvider: getTasksByType вызван для типа $type. Всего заданий: ${_tasks.length}');
    final tasks = _tasks.where((task) => task.type == type).toList();
    print('TaskProvider: Найдено заданий типа $type: ${tasks.length}');
    return tasks;
  }

  // Получение активных заданий
  List<Task> get activeTasks => _tasks.where((task) => task.isActive).toList();

  // Получение выполненных заданий
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();

  // Инициализация заданий
  Future<void> initializeTasks() async {
    print('TaskProvider: Начинаем инициализацию заданий');
    _isLoading = true;
    notifyListeners();

    // Создаем 15 различных заданий
    print('TaskProvider: Создаем задания...');
    _tasks = [
      // Ежедневные задания
      Task(
        id: 'daily_quiz_3',
        title: 'Пройдите 3 теста',
        description: 'Завершите 3 теста сегодня',
        type: TaskType.daily,
        category: TaskCategory.quiz,
        targetValue: 3,
        xpReward: 50,
        pointsReward: 25,
        iconPath: 'assets/images/icons/checklist_icon.svg',
        expiresAt: _getEndOfDay(),
      ),
      
      Task(
        id: 'daily_share',
        title: 'Поделитесь приложением',
        description: 'Поделитесь приложением с друзьями',
        type: TaskType.daily,
        category: TaskCategory.social,
        targetValue: 1,
        xpReward: 30,
        pointsReward: 15,
        iconPath: 'assets/images/icons/share_icon.png',
        expiresAt: _getEndOfDay(),
      ),

      Task(
        id: 'daily_perfect_score',
        title: 'Получите 100% в тесте',
        description: 'Пройдите любой тест без ошибок',
        type: TaskType.daily,
        category: TaskCategory.quiz,
        targetValue: 1,
        xpReward: 100,
        pointsReward: 50,
        iconPath: 'assets/images/icons/trophy_icon.png',
        expiresAt: _getEndOfDay(),
      ),

      // Еженедельные задания
      Task(
        id: 'weekly_quiz_20',
        title: 'Пройдите 20 тестов',
        description: 'Завершите 20 тестов за неделю',
        type: TaskType.weekly,
        category: TaskCategory.quiz,
        targetValue: 20,
        xpReward: 200,
        pointsReward: 100,
        iconPath: 'assets/images/icons/checklist_icon.svg',
        expiresAt: _getEndOfWeek(),
      ),

      Task(
        id: 'weekly_medical',
        title: 'Изучите медицинский билет',
        description: 'Пройдите медицинский билет полностью',
        type: TaskType.weekly,
        category: TaskCategory.learning,
        targetValue: 1,
        xpReward: 150,
        pointsReward: 75,
        iconPath: 'assets/images/icons/car_icon.png',
        expiresAt: _getEndOfWeek(),
      ),

      Task(
        id: 'weekly_combo_10',
        title: 'Достигните комбо 10',
        description: 'Ответьте правильно на 10 вопросов подряд',
        type: TaskType.weekly,
        category: TaskCategory.practice,
        targetValue: 1,
        xpReward: 120,
        pointsReward: 60,
        iconPath: 'assets/images/icons/target_icon.png',
        expiresAt: _getEndOfWeek(),
      ),

      // Достижения
      Task(
        id: 'achievement_first_quiz',
        title: 'Первый тест',
        description: 'Пройдите свой первый тест',
        type: TaskType.achievement,
        category: TaskCategory.quiz,
        targetValue: 1,
        xpReward: 50,
        pointsReward: 25,
        iconPath: 'assets/images/icons/trophy_icon.png',
      ),

      Task(
        id: 'achievement_level_5',
        title: 'Достигните 5 уровня',
        description: 'Поднимитесь до 5 уровня',
        type: TaskType.achievement,
        category: TaskCategory.learning,
        targetValue: 1,
        xpReward: 300,
        pointsReward: 150,
        iconPath: 'assets/images/icons/rocket_icon.png',
      ),

      Task(
        id: 'achievement_all_tickets',
        title: 'Все билеты пройдены',
        description: 'Пройдите все 26 билетов',
        type: TaskType.achievement,
        category: TaskCategory.quiz,
        targetValue: 26,
        xpReward: 1000,
        pointsReward: 500,
        iconPath: 'assets/images/icons/trophy_icon.png',
      ),

      Task(
        id: 'achievement_7_days',
        title: 'Неделя обучения',
        description: 'Заходите в приложение 7 дней подряд',
        type: TaskType.achievement,
        category: TaskCategory.exploration,
        targetValue: 7,
        xpReward: 200,
        pointsReward: 100,
        iconPath: 'assets/images/icons/checklist_icon.svg',
      ),

      // Специальные задания
      Task(
        id: 'special_profile',
        title: 'Заполните профиль',
        description: 'Заполните всю информацию в профиле',
        type: TaskType.special,
        category: TaskCategory.exploration,
        targetValue: 1,
        xpReward: 80,
        pointsReward: 40,
        iconPath: 'assets/images/icons/user_icon.png',
      ),

      Task(
        id: 'special_schools',
        title: 'Изучите автошколы',
        description: 'Посмотрите информацию о 5 автошколах',
        type: TaskType.special,
        category: TaskCategory.exploration,
        targetValue: 5,
        xpReward: 60,
        pointsReward: 30,
        iconPath: 'assets/images/icons/school_logo.png',
      ),

      Task(
        id: 'special_fast_quiz',
        title: 'Быстрый тест',
        description: 'Пройдите тест менее чем за 2 минуты',
        type: TaskType.special,
        category: TaskCategory.quiz,
        targetValue: 1,
        xpReward: 90,
        pointsReward: 45,
        iconPath: 'assets/images/icons/rocket_icon.png',
      ),

      Task(
        id: 'special_help',
        title: 'Помощь другим',
        description: 'Посетите раздел "Помощь и поддержка"',
        type: TaskType.special,
        category: TaskCategory.exploration,
        targetValue: 1,
        xpReward: 40,
        pointsReward: 20,
        iconPath: 'assets/images/icons/checklist_icon.svg',
      ),

      Task(
        id: 'special_about',
        title: 'Узнайте о приложении',
        description: 'Прочитайте информацию о приложении',
        type: TaskType.special,
        category: TaskCategory.exploration,
        targetValue: 1,
        xpReward: 30,
        pointsReward: 15,
        iconPath: 'assets/images/icons/user_icon.png',
              ),
      ];
      print('TaskProvider: Задания созданы. Количество: ${_tasks.length}');

    // Загружаем прогресс из SharedPreferences
    await _loadProgress();
    
    print('TaskProvider: Инициализация завершена. Создано ${_tasks.length} заданий');
    _isLoading = false;
    notifyListeners();
  }

  // Обновление прогресса задания
  Future<void> updateTaskProgress(String taskId, int progress, {RewardsProvider? rewardsProvider}) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1) return;

    final task = _tasks[taskIndex];
    if (task.isCompleted) return;

    final newCurrentValue = (task.currentValue + progress).clamp(0, task.targetValue);
    final isNowCompleted = newCurrentValue >= task.targetValue && !task.isCompleted;

    _tasks[taskIndex] = task.copyWith(
      currentValue: newCurrentValue,
      isCompleted: isNowCompleted,
      completedAt: isNowCompleted ? DateTime.now() : null,
    );

    await _saveProgress();
    notifyListeners();

    // Если задание выполнено, начисляем награды
    if (isNowCompleted && rewardsProvider != null) {
      await rewardsProvider.addReward(
        task.xpReward,
        task.pointsReward,
        'Задание "${task.title}" выполнено! +${task.xpReward} XP, +${task.pointsReward} очков',
      );
    }
  }

  // Автоматическое обновление прогресса для тестов
  Future<void> updateQuizProgress({RewardsProvider? rewardsProvider}) async {
    // Обновляем задание "Пройдите 3 теста"
    await updateTaskProgress('daily_quiz_3', 1, rewardsProvider: rewardsProvider);
    
    // Обновляем задание "Пройдите 20 тестов"
    await updateTaskProgress('weekly_quiz_20', 1, rewardsProvider: rewardsProvider);
  }

  // Автоматическое обновление прогресса для 100% результата
  Future<void> updatePerfectScoreProgress({RewardsProvider? rewardsProvider}) async {
    await updateTaskProgress('daily_perfect_score', 1, rewardsProvider: rewardsProvider);
  }

  // Автоматическое обновление прогресса для медицинского билета
  Future<void> updateMedicalProgress({RewardsProvider? rewardsProvider}) async {
    await updateTaskProgress('weekly_medical', 1, rewardsProvider: rewardsProvider);
  }

  // Автоматическое обновление прогресса для комбо
  Future<void> updateComboProgress(int comboCount, {RewardsProvider? rewardsProvider}) async {
    if (comboCount >= 10) {
      await updateTaskProgress('weekly_combo_10', 1, rewardsProvider: rewardsProvider);
    }
  }

  // Автоматическое обновление прогресса для первого теста
  Future<void> updateFirstQuizProgress({RewardsProvider? rewardsProvider}) async {
    await updateTaskProgress('achievement_first_quiz', 1, rewardsProvider: rewardsProvider);
  }

  // Автоматическое обновление прогресса для уровня
  Future<void> updateLevelProgress(int currentLevel, {RewardsProvider? rewardsProvider}) async {
    if (currentLevel >= 5) {
      await updateTaskProgress('achievement_level_5', 1, rewardsProvider: rewardsProvider);
    }
  }

  // Автоматическое обновление прогресса для всех билетов
  Future<void> updateAllTicketsProgress(int completedTickets, {RewardsProvider? rewardsProvider}) async {
    print('TaskProvider: Проверяем прогресс всех билетов. Завершено: $completedTickets из 26');
    if (completedTickets >= 26) {
      print('TaskProvider: Все билеты пройдены! Выполняем задание');
      await updateTaskProgress('achievement_all_tickets', 1, rewardsProvider: rewardsProvider);
    }
  }

  // Автоматическое обновление прогресса для ежедневного входа
  Future<void> updateDailyLoginProgress({RewardsProvider? rewardsProvider}) async {
    await updateTaskProgress('achievement_7_days', 1, rewardsProvider: rewardsProvider);
  }

  // Обновление прогресса недели обучения (вызывается из RewardsProvider)
  Future<void> updateWeekLearningProgress({RewardsProvider? rewardsProvider}) async {
    await updateTaskProgress('achievement_7_days', 1, rewardsProvider: rewardsProvider);
  }

  // Выполнение задания (для кнопки "Выполнить")
  Future<void> completeTask(String taskId, {RewardsProvider? rewardsProvider}) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1) return;

    final task = _tasks[taskIndex];
    if (task.isCompleted) return;

    // Устанавливаем прогресс на максимальное значение
    _tasks[taskIndex] = task.copyWith(
      currentValue: task.targetValue,
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    await _saveProgress();
    notifyListeners();
    
    // Начисляем награды
    if (rewardsProvider != null) {
      await rewardsProvider.addReward(
        task.xpReward,
        task.pointsReward,
        'Задание выполнено: +${task.xpReward} XP, +${task.pointsReward} очков',
      );
    }
    
    print('TaskProvider: Задание "${task.title}" выполнено! Награда: ${task.xpReward} XP, ${task.pointsReward} очков');
  }

  // Проверка, можно ли выполнить задание
  bool canCompleteTask(String taskId) {
    final task = _tasks.firstWhere((task) => task.id == taskId);
    return !task.isCompleted && task.isActive;
  }

  // Сброс ежедневных заданий
  Future<void> resetDailyTasks() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      if (task.type == TaskType.daily && 
          task.completedAt != null &&
          task.completedAt!.isBefore(today)) {
        _tasks[i] = task.copyWith(
          currentValue: 0,
          isCompleted: false,
          completedAt: null,
          expiresAt: _getEndOfDay(),
        );
      }
    }

    await _saveProgress();
    notifyListeners();
  }

  // Сброс еженедельных заданий
  Future<void> resetWeeklyTasks() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);

    for (int i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      if (task.type == TaskType.weekly && 
          task.completedAt != null &&
          task.completedAt!.isBefore(weekStartDate)) {
        _tasks[i] = task.copyWith(
          currentValue: 0,
          isCompleted: false,
          completedAt: null,
          expiresAt: _getEndOfWeek(),
        );
      }
    }

    await _saveProgress();
    notifyListeners();
  }

  // Получение конца дня
  DateTime _getEndOfDay() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  // Получение конца недели
  DateTime _getEndOfWeek() {
    final now = DateTime.now();
    final daysUntilWeekend = 7 - now.weekday;
    return DateTime(now.year, now.month, now.day + daysUntilWeekend, 23, 59, 59);
  }

  // Загрузка прогресса из SharedPreferences
  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    for (int i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      final taskKey = 'task_${task.id}';
      
      final currentValue = prefs.getInt('${taskKey}_current') ?? 0;
      final isCompleted = prefs.getBool('${taskKey}_completed') ?? false;
      final completedAtString = prefs.getString('${taskKey}_completed_at');
      
      DateTime? completedAt;
      if (completedAtString != null) {
        completedAt = DateTime.tryParse(completedAtString);
      }

      _tasks[i] = task.copyWith(
        currentValue: currentValue,
        isCompleted: isCompleted,
        completedAt: completedAt,
      );
    }
  }

  // Сохранение прогресса в SharedPreferences
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    for (final task in _tasks) {
      final taskKey = 'task_${task.id}';
      
      await prefs.setInt('${taskKey}_current', task.currentValue);
      await prefs.setBool('${taskKey}_completed', task.isCompleted);
      
      if (task.completedAt != null) {
        await prefs.setString('${taskKey}_completed_at', task.completedAt!.toIso8601String());
      } else {
        await prefs.remove('${taskKey}_completed_at');
      }
    }
  }
}
