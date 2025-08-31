import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String username; // уникальный логин на английском языке
  final String name;
  final String userType; // 'student' или 'seeker'
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? password; // пароль (может быть null для существующих пользователей)
  final DateTime createdAt;
  final Map<String, int> moduleProgress; // прогресс по модулям

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.userType,
    this.password,
    required this.createdAt,
    required this.moduleProgress,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? username,
    String? name,
    String? userType,
    String? password,
    DateTime? createdAt,
    Map<String, int>? moduleProgress,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      userType: userType ?? this.userType,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      moduleProgress: moduleProgress ?? this.moduleProgress,
    );
  }
}
