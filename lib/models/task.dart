import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

enum TaskType {
  daily,      // Ежедневные задания
  weekly,     // Еженедельные задания
  achievement, // Достижения
  special     // Специальные задания
}

enum TaskCategory {
  quiz,       // Тесты и викторины
  social,     // Социальные действия
  learning,   // Обучение
  practice,   // Практика
  exploration // Исследование приложения
}

@JsonSerializable()
class Task {
  final String id;
  final String title;
  final String description;
  final TaskType type;
  final TaskCategory category;
  final int targetValue; // Целевое значение для выполнения
  final int currentValue; // Текущее значение
  final int xpReward; // Награда в XP
  final int pointsReward; // Награда в очках
  final String? iconPath; // Путь к иконке
  final bool isCompleted; // Выполнено ли задание
  final DateTime? completedAt; // Когда выполнено
  final DateTime? expiresAt; // Когда истекает (для ежедневных/еженедельных)
  final Map<String, dynamic>? metadata; // Дополнительные данные

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.targetValue,
    this.currentValue = 0,
    required this.xpReward,
    required this.pointsReward,
    this.iconPath,
    this.isCompleted = false,
    this.completedAt,
    this.expiresAt,
    this.metadata,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);

  // Прогресс выполнения задания (0.0 - 1.0)
  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  // Проверка, можно ли выполнить задание
  bool get canComplete => currentValue >= targetValue && !isCompleted;

  // Проверка, истекло ли задание
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  // Проверка, активно ли задание
  bool get isActive => !isCompleted && !isExpired;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? type,
    TaskCategory? category,
    int? targetValue,
    int? currentValue,
    int? xpReward,
    int? pointsReward,
    String? iconPath,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      xpReward: xpReward ?? this.xpReward,
      pointsReward: pointsReward ?? this.pointsReward,
      iconPath: iconPath ?? this.iconPath,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
