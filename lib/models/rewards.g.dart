// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rewards.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
  currentXP: (json['currentXP'] as num).toInt(),
  currentLevel: (json['currentLevel'] as num).toInt(),
  totalPoints: (json['totalPoints'] as num).toInt(),
  streakDays: (json['streakDays'] as num).toInt(),
  lastLoginDate: DateTime.parse(json['lastLoginDate'] as String),
  dailyCompletions: Map<String, int>.from(json['dailyCompletions'] as Map),
  dailyActions: (json['dailyActions'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, DateTime.parse(e as String)),
  ),
  currentCombo: (json['currentCombo'] as num).toInt(),
  maxCombo: (json['maxCombo'] as num).toInt(),
);

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
  'currentXP': instance.currentXP,
  'currentLevel': instance.currentLevel,
  'totalPoints': instance.totalPoints,
  'streakDays': instance.streakDays,
  'lastLoginDate': instance.lastLoginDate.toIso8601String(),
  'dailyCompletions': instance.dailyCompletions,
  'dailyActions': instance.dailyActions.map(
    (k, e) => MapEntry(k, e.toIso8601String()),
  ),
  'currentCombo': instance.currentCombo,
  'maxCombo': instance.maxCombo,
};

RewardResult _$RewardResultFromJson(Map<String, dynamic> json) => RewardResult(
  xpGained: (json['xpGained'] as num).toInt(),
  pointsGained: (json['pointsGained'] as num).toInt(),
  newLevel: (json['newLevel'] as num).toInt(),
  levelUp: json['levelUp'] as bool,
  bonuses: (json['bonuses'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$RewardResultToJson(RewardResult instance) =>
    <String, dynamic>{
      'xpGained': instance.xpGained,
      'pointsGained': instance.pointsGained,
      'newLevel': instance.newLevel,
      'levelUp': instance.levelUp,
      'bonuses': instance.bonuses,
    };
