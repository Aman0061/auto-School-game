// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  username: json['username'] as String,
  name: json['name'] as String,
  userType: json['userType'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  moduleProgress: Map<String, int>.from(json['moduleProgress'] as Map),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'name': instance.name,
  'userType': instance.userType,
  'createdAt': instance.createdAt.toIso8601String(),
  'moduleProgress': instance.moduleProgress,
};
