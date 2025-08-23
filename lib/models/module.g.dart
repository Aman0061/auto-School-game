// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Module _$ModuleFromJson(Map<String, dynamic> json) => Module(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  questionCount: (json['questionCount'] as num).toInt(),
  iconPath: json['iconPath'] as String?,
  isExam: json['isExam'] as bool? ?? false,
);

Map<String, dynamic> _$ModuleToJson(Module instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'questionCount': instance.questionCount,
  'iconPath': instance.iconPath,
  'isExam': instance.isExam,
};
