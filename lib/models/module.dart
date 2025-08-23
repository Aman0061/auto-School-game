import 'package:json_annotation/json_annotation.dart';

part 'module.g.dart';

@JsonSerializable()
class Module {
  final String id;
  final String title;
  final String description;
  final int questionCount;
  final String? iconPath;
  final bool isExam; // специальный модуль для экзамена

  Module({
    required this.id,
    required this.title,
    required this.description,
    required this.questionCount,
    this.iconPath,
    this.isExam = false,
  });

  factory Module.fromJson(Map<String, dynamic> json) => _$ModuleFromJson(json);
  Map<String, dynamic> toJson() => _$ModuleToJson(this);
}
