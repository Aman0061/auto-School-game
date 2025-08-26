import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String userType; // 'student' или 'seeker'
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? password; // пароль (может быть null для существующих пользователей)
  final DateTime createdAt;
  final Map<String, int> moduleProgress; // прогресс по модулям

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.userType,
    this.password,
    required this.createdAt,
    required this.moduleProgress,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? userType,
    String? password,
    DateTime? createdAt,
    Map<String, int>? moduleProgress,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      moduleProgress: moduleProgress ?? this.moduleProgress,
    );
  }
}
