import 'package:json_annotation/json_annotation.dart';

part 'rewards.g.dart';

@JsonSerializable()
class UserStats {
  final int currentXP;
  final int currentLevel;
  final int totalPoints;
  final int streakDays;
  final DateTime lastLoginDate;
  final Map<String, int> dailyCompletions; // тесты за день
  final Map<String, DateTime> dailyActions; // действия за день
  final int currentCombo; // текущий комбо-стрик
  final int maxCombo; // максимальный комбо-стрик

  UserStats({
    required this.currentXP,
    required this.currentLevel,
    required this.totalPoints,
    required this.streakDays,
    required this.lastLoginDate,
    required this.dailyCompletions,
    required this.dailyActions,
    required this.currentCombo,
    required this.maxCombo,
  });

  factory UserStats.initial() {
    return UserStats(
      currentXP: 0,
      currentLevel: 1,
      totalPoints: 0,
      streakDays: 0,
      lastLoginDate: DateTime.now(),
      dailyCompletions: {},
      dailyActions: {},
      currentCombo: 0,
      maxCombo: 0,
    );
  }

  factory UserStats.fromJson(Map<String, dynamic> json) => _$UserStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsToJson(this);

  UserStats copyWith({
    int? currentXP,
    int? currentLevel,
    int? totalPoints,
    int? streakDays,
    DateTime? lastLoginDate,
    Map<String, int>? dailyCompletions,
    Map<String, DateTime>? dailyActions,
    int? currentCombo,
    int? maxCombo,
  }) {
    return UserStats(
      currentXP: currentXP ?? this.currentXP,
      currentLevel: currentLevel ?? this.currentLevel,
      totalPoints: totalPoints ?? this.totalPoints,
      streakDays: streakDays ?? this.streakDays,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      dailyCompletions: dailyCompletions ?? this.dailyCompletions,
      dailyActions: dailyActions ?? this.dailyActions,
      currentCombo: currentCombo ?? this.currentCombo,
      maxCombo: maxCombo ?? this.maxCombo,
    );
  }
}

@JsonSerializable()
class RewardResult {
  final int xpGained;
  final int pointsGained;
  final int newLevel;
  final bool levelUp;
  final List<String> bonuses; // список полученных бонусов

  RewardResult({
    required this.xpGained,
    required this.pointsGained,
    required this.newLevel,
    required this.levelUp,
    required this.bonuses,
  });

  factory RewardResult.fromJson(Map<String, dynamic> json) => _$RewardResultFromJson(json);
  Map<String, dynamic> toJson() => _$RewardResultToJson(this);
}

class RewardsCalculator {
  // Константы начислений
  static const int CORRECT_ANSWER_XP = 10;
  static const int CORRECT_ANSWER_POINTS = 5;
  static const int WRONG_ANSWER_XP = 2;
  static const int SPEED_BONUS_XP = 3;
  static const int SPEED_THRESHOLD_SECONDS = 5;
  static const int MIN_TIME_SECONDS = 2;

  // Комбо-стрики
  static const Map<int, int> COMBO_BONUSES = {
    3: 5,
    5: 10,
    10: 25,
  };

  // Бонусы за завершение теста
  static const int TEST_COMPLETION_XP = 20;
  static const Map<String, Map<String, int>> ACCURACY_BONUSES = {
    '90+': {'xp': 30, 'points': 20},
    '70-89': {'xp': 15, 'points': 10},
    '<70': {'xp': 5, 'points': 0},
  };

  // Ежедневные бонусы
  static const int DAILY_LOGIN_XP = 5;
  static const Map<int, int> STREAK_BONUSES = {
    3: 10,
    7: 25,
    14: 50,
    30: 150,
  };

  // Другие бонусы
  static const int DAILY_TASKS_XP = 20;
  static const int DAILY_TASKS_POINTS = 10;
  static const int SHARE_XP = 5;
  static const int SHARE_POINTS = 5;
  static const int THREE_TESTS_XP = 15;
  static const int THREE_TESTS_POINTS = 10;

  // Формула для расчета требуемого XP для уровня
  static int getRequiredXP(int level) {
    return 100 + (level * level * 50);
  }

  // Расчет награды за ответ на вопрос
  static RewardResult calculateQuestionReward({
    required bool isCorrect,
    required int answerTimeSeconds,
    required int currentCombo,
    required int currentLevel,
    required int currentXP,
  }) {
    int xpGained = 0;
    int pointsGained = 0;
    List<String> bonuses = [];

    // Базовые награды
    if (isCorrect) {
      xpGained += CORRECT_ANSWER_XP;
      pointsGained += CORRECT_ANSWER_POINTS;
    } else {
      xpGained += WRONG_ANSWER_XP;
      bonuses.add('Попытка: +$WRONG_ANSWER_XP XP');
    }

    // Бонус за скорость (только для правильных ответов)
    if (isCorrect && answerTimeSeconds < SPEED_THRESHOLD_SECONDS && answerTimeSeconds >= MIN_TIME_SECONDS) {
      xpGained += SPEED_BONUS_XP;
      bonuses.add('Быстрый ответ: +$SPEED_BONUS_XP XP');
    }

    // Комбо-стрик
    if (isCorrect) {
      final newCombo = currentCombo + 1;
      for (final entry in COMBO_BONUSES.entries) {
        if (newCombo == entry.key) {
          xpGained += entry.value;
          bonuses.add('Комбо ${entry.key}: +${entry.value} XP');
          break;
        }
      }
    }

    // Проверка повышения уровня
    final newXP = currentXP + xpGained;
    final requiredXP = getRequiredXP(currentLevel);
    int newLevel = currentLevel;
    bool levelUp = false;

    if (newXP >= requiredXP) {
      newLevel = currentLevel + 1;
      levelUp = true;
      bonuses.add('Новый уровень!');
    }

    return RewardResult(
      xpGained: xpGained,
      pointsGained: pointsGained,
      newLevel: newLevel,
      levelUp: levelUp,
      bonuses: bonuses,
    );
  }

  // Расчет награды за завершение теста
  static RewardResult calculateTestCompletionReward({
    required int correctAnswers,
    required int totalQuestions,
    required int currentLevel,
    required int currentXP,
    required Map<String, int> dailyCompletions,
  }) {
    int xpGained = TEST_COMPLETION_XP;
    int pointsGained = 0;
    List<String> bonuses = ['Завершение теста: +$TEST_COMPLETION_XP XP'];

    // Бонус за точность
    final accuracy = (correctAnswers / totalQuestions * 100).round();
    if (accuracy >= 90) {
      final bonus = ACCURACY_BONUSES['90+']!;
      xpGained += bonus['xp']!;
      pointsGained += bonus['points']!;
      bonuses.add('Отличный результат (≥90%): +${bonus['xp']} XP, +${bonus['points']} очков');
    } else if (accuracy >= 70) {
      final bonus = ACCURACY_BONUSES['70-89']!;
      xpGained += bonus['xp']!;
      pointsGained += bonus['points']!;
      bonuses.add('Хороший результат (70-89%): +${bonus['xp']} XP, +${bonus['points']} очков');
    } else {
      final bonus = ACCURACY_BONUSES['<70']!;
      xpGained += bonus['xp']!;
      bonuses.add('Нужно подтянуть (<70%): +${bonus['xp']} XP');
    }

    // Бонус за 3 теста в день
    final today = DateTime.now().toIso8601String().split('T')[0];
    final todayCompletions = dailyCompletions[today] ?? 0;
    if (todayCompletions == 3) {
      xpGained += THREE_TESTS_XP;
      pointsGained += THREE_TESTS_POINTS;
      bonuses.add('3 теста за день: +$THREE_TESTS_XP XP, +$THREE_TESTS_POINTS очков');
    }

    // Проверка повышения уровня
    final newXP = currentXP + xpGained;
    final requiredXP = getRequiredXP(currentLevel);
    int newLevel = currentLevel;
    bool levelUp = false;

    if (newXP >= requiredXP) {
      newLevel = currentLevel + 1;
      levelUp = true;
      bonuses.add('Новый уровень!');
    }

    return RewardResult(
      xpGained: xpGained,
      pointsGained: pointsGained,
      newLevel: newLevel,
      levelUp: levelUp,
      bonuses: bonuses,
    );
  }

  // Расчет ежедневного бонуса за вход
  static RewardResult calculateDailyLoginReward({
    required int currentLevel,
    required int currentXP,
    required int streakDays,
    required DateTime lastLoginDate,
  }) {
    int xpGained = DAILY_LOGIN_XP;
    int pointsGained = 0;
    List<String> bonuses = ['Ежедневный вход: +$DAILY_LOGIN_XP XP'];

    // Проверяем, новый ли это день
    final today = DateTime.now();
    final lastLogin = DateTime(lastLoginDate.year, lastLoginDate.month, lastLoginDate.day);
    final todayDate = DateTime(today.year, today.month, today.day);

    if (todayDate.difference(lastLogin).inDays == 1) {
      // Подряд дни
      final newStreak = streakDays + 1;
      for (final entry in STREAK_BONUSES.entries) {
        if (newStreak == entry.key) {
          xpGained += entry.value;
          bonuses.add('Стрик ${entry.key} дней: +${entry.value} XP');
          break;
        }
      }
    } else if (todayDate.difference(lastLogin).inDays > 1) {
      // Сброс стрика
      bonuses.add('Стрик сброшен');
    }

    // Проверка повышения уровня
    final newXP = currentXP + xpGained;
    final requiredXP = getRequiredXP(currentLevel);
    int newLevel = currentLevel;
    bool levelUp = false;

    if (newXP >= requiredXP) {
      newLevel = currentLevel + 1;
      levelUp = true;
      bonuses.add('Новый уровень!');
    }

    return RewardResult(
      xpGained: xpGained,
      pointsGained: pointsGained,
      newLevel: newLevel,
      levelUp: levelUp,
      bonuses: bonuses,
    );
  }
}
