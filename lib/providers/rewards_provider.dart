import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/rewards.dart';

class RewardsProvider extends ChangeNotifier {
  UserStats _userStats = UserStats.initial();
  bool _isLoading = false;

  UserStats get userStats => _userStats;
  bool get isLoading => _isLoading;

  // Инициализация
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadUserStats();
      await _checkDailyLogin();
    } catch (e) {
      print('Ошибка инициализации RewardsProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Загрузка статистики пользователя
  Future<void> _loadUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsString = prefs.getString('user_stats');
      
      if (statsString != null) {
        final statsMap = Map<String, dynamic>.from(
          jsonDecode(statsString) as Map,
        );
        _userStats = UserStats.fromJson(statsMap);
      } else {
        _userStats = UserStats.initial();
        await _saveUserStats();
      }
    } catch (e) {
      print('Ошибка загрузки статистики: $e');
      _userStats = UserStats.initial();
    }
  }

  // Сохранение статистики пользователя
  Future<void> _saveUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsString = jsonEncode(_userStats.toJson());
      await prefs.setString('user_stats', statsString);
    } catch (e) {
      print('Ошибка сохранения статистики: $e');
    }
  }

  // Проверка ежедневного входа
  Future<void> _checkDailyLogin() async {
    final today = DateTime.now();
    final lastLogin = DateTime(
      _userStats.lastLoginDate.year,
      _userStats.lastLoginDate.month,
      _userStats.lastLoginDate.day,
    );
    final todayDate = DateTime(today.year, today.month, today.day);

    if (todayDate.difference(lastLogin).inDays >= 1) {
      final reward = RewardsCalculator.calculateDailyLoginReward(
        currentLevel: _userStats.currentLevel,
        currentXP: _userStats.currentXP,
        streakDays: _userStats.streakDays,
        lastLoginDate: _userStats.lastLoginDate,
      );

      await _applyReward(reward);
      
      // Обновляем дату последнего входа
      _userStats = _userStats.copyWith(
        lastLoginDate: today,
        streakDays: todayDate.difference(lastLogin).inDays == 1 
            ? _userStats.streakDays + 1 
            : 1,
      );
      await _saveUserStats();
    }
  }

  // Применение награды
  Future<void> _applyReward(RewardResult reward) async {
    int newXP = _userStats.currentXP + reward.xpGained;
    int newLevel = reward.newLevel;
    
    // Если повысился уровень, переносим лишний XP
    if (reward.levelUp) {
      final requiredXP = RewardsCalculator.getRequiredXP(_userStats.currentLevel);
      newXP = newXP - requiredXP;
    }

    _userStats = _userStats.copyWith(
      currentXP: newXP,
      currentLevel: newLevel,
      totalPoints: _userStats.totalPoints + reward.pointsGained,
    );

    await _saveUserStats();
    notifyListeners();
  }

  // Награда за ответ на вопрос
  Future<RewardResult> rewardQuestionAnswer({
    required bool isCorrect,
    required int answerTimeSeconds,
  }) async {
    final reward = RewardsCalculator.calculateQuestionReward(
      isCorrect: isCorrect,
      answerTimeSeconds: answerTimeSeconds,
      currentCombo: _userStats.currentCombo,
      currentLevel: _userStats.currentLevel,
      currentXP: _userStats.currentXP,
    );

    // Обновляем комбо
    int newCombo = isCorrect ? _userStats.currentCombo + 1 : 0;
    int newMaxCombo = _userStats.maxCombo;
    
    if (isCorrect && newCombo > _userStats.maxCombo) {
      newMaxCombo = newCombo;
    }

    _userStats = _userStats.copyWith(
      currentCombo: newCombo,
      maxCombo: newMaxCombo,
    );

    await _applyReward(reward);
    return reward;
  }

  // Награда за завершение теста
  Future<RewardResult> rewardTestCompletion({
    required int correctAnswers,
    required int totalQuestions,
    required String moduleId,
  }) async {
    final reward = RewardsCalculator.calculateTestCompletionReward(
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      currentLevel: _userStats.currentLevel,
      currentXP: _userStats.currentXP,
      dailyCompletions: _userStats.dailyCompletions,
    );

    // Обновляем счетчик завершений за день
    final today = DateTime.now().toIso8601String().split('T')[0];
    final todayCompletions = Map<String, int>.from(_userStats.dailyCompletions);
    todayCompletions[today] = (todayCompletions[today] ?? 0) + 1;

    _userStats = _userStats.copyWith(
      dailyCompletions: todayCompletions,
    );

    await _applyReward(reward);
    return reward;
  }

  // Награда за ежедневные задания
  Future<RewardResult> rewardDailyTasks() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final todayActions = Map<String, DateTime>.from(_userStats.dailyActions);
    
    // Проверяем, не получали ли уже награду сегодня
    if (todayActions['daily_tasks']?.toIso8601String().split('T')[0] == today) {
      return RewardResult(
        xpGained: 0,
        pointsGained: 0,
        newLevel: _userStats.currentLevel,
        levelUp: false,
        bonuses: ['Уже выполнено сегодня'],
      );
    }

    todayActions['daily_tasks'] = DateTime.now();

    _userStats = _userStats.copyWith(
      dailyActions: todayActions,
    );

    final reward = RewardResult(
      xpGained: RewardsCalculator.DAILY_TASKS_XP,
      pointsGained: RewardsCalculator.DAILY_TASKS_POINTS,
      newLevel: _userStats.currentLevel,
      levelUp: false,
      bonuses: ['Ежедневные задания: +${RewardsCalculator.DAILY_TASKS_XP} XP, +${RewardsCalculator.DAILY_TASKS_POINTS} очков'],
    );

    await _applyReward(reward);
    return reward;
  }

  // Награда за поделиться
  Future<RewardResult> rewardShare() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final todayActions = Map<String, DateTime>.from(_userStats.dailyActions);
    
    // Проверяем, не делились ли уже сегодня
    if (todayActions['share']?.toIso8601String().split('T')[0] == today) {
      return RewardResult(
        xpGained: 0,
        pointsGained: 0,
        newLevel: _userStats.currentLevel,
        levelUp: false,
        bonuses: ['Уже поделились сегодня'],
      );
    }

    todayActions['share'] = DateTime.now();

    _userStats = _userStats.copyWith(
      dailyActions: todayActions,
    );

    final reward = RewardResult(
      xpGained: RewardsCalculator.SHARE_XP,
      pointsGained: RewardsCalculator.SHARE_POINTS,
      newLevel: _userStats.currentLevel,
      levelUp: false,
      bonuses: ['Поделиться: +${RewardsCalculator.SHARE_XP} XP, +${RewardsCalculator.SHARE_POINTS} очков'],
    );

    await _applyReward(reward);
    return reward;
  }

  // Получение прогресса до следующего уровня
  double getLevelProgress() {
    final currentLevelXP = _userStats.currentXP;
    final requiredXP = RewardsCalculator.getRequiredXP(_userStats.currentLevel);
    return currentLevelXP / requiredXP;
  }

  // Получение требуемого XP для следующего уровня
  int getRequiredXPForNextLevel() {
    return RewardsCalculator.getRequiredXP(_userStats.currentLevel);
  }

  // Сброс комбо (при неправильном ответе)
  void resetCombo() {
    _userStats = _userStats.copyWith(currentCombo: 0);
    _saveUserStats();
    notifyListeners();
  }
}
