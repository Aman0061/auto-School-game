import 'package:json_annotation/json_annotation.dart';
import 'answer.dart';

part 'question.g.dart';

@JsonSerializable()
class Question {
  final int id;
  final String text;
  final List<Answer> answers;
  final String? image;

  Question({
    required this.id,
    required this.text,
    required this.answers,
    this.image,
  });

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  // Геттеры для совместимости с существующим кодом
  List<String> get options => answers.map((a) => a.text).toList();
  int get correctAnswerIndex => answers.indexWhere((a) => a.correct);
  String? get imagePath => image;
  String? get explanation => null; // Пока без объяснений
  String get moduleId => 'ticket'; // Временное значение для совместимости

  bool isCorrect(int selectedIndex) {
    return selectedIndex == correctAnswerIndex;
  }
}
