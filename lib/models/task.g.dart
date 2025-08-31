// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$TaskTypeEnumMap, json['type']),
  category: $enumDecode(_$TaskCategoryEnumMap, json['category']),
  targetValue: (json['targetValue'] as num).toInt(),
  currentValue: (json['currentValue'] as num?)?.toInt() ?? 0,
  xpReward: (json['xpReward'] as num).toInt(),
  pointsReward: (json['pointsReward'] as num).toInt(),
  iconPath: json['iconPath'] as String?,
  isCompleted: json['isCompleted'] as bool? ?? false,
  completedAt:
      json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
  expiresAt:
      json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'type': _$TaskTypeEnumMap[instance.type]!,
  'category': _$TaskCategoryEnumMap[instance.category]!,
  'targetValue': instance.targetValue,
  'currentValue': instance.currentValue,
  'xpReward': instance.xpReward,
  'pointsReward': instance.pointsReward,
  'iconPath': instance.iconPath,
  'isCompleted': instance.isCompleted,
  'completedAt': instance.completedAt?.toIso8601String(),
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'metadata': instance.metadata,
};

const _$TaskTypeEnumMap = {
  TaskType.daily: 'daily',
  TaskType.weekly: 'weekly',
  TaskType.achievement: 'achievement',
  TaskType.special: 'special',
};

const _$TaskCategoryEnumMap = {
  TaskCategory.quiz: 'quiz',
  TaskCategory.social: 'social',
  TaskCategory.learning: 'learning',
  TaskCategory.practice: 'practice',
  TaskCategory.exploration: 'exploration',
};
