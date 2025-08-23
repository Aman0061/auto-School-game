import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final Map<String, int> moduleProgress; // прогресс по модулям

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.moduleProgress,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
    Map<String, int>? moduleProgress,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      moduleProgress: moduleProgress ?? this.moduleProgress,
    );
  }
}
