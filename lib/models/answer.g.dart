// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Answer _$AnswerFromJson(Map<String, dynamic> json) => Answer(
  id: (json['id'] as num).toInt(),
  text: json['text'] as String,
  correct: json['correct'] as bool,
);

Map<String, dynamic> _$AnswerToJson(Answer instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'correct': instance.correct,
};
