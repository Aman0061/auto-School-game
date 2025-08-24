import 'package:json_annotation/json_annotation.dart';
import 'question.dart';

part 'ticket.g.dart';

@JsonSerializable()
class Ticket {
  final String id;
  final String title;
  final String description;
  final List<Question> questions;
  final bool isMedical;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    this.isMedical = false,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);
  Map<String, dynamic> toJson() => _$TicketToJson(this);

  int get questionCount => questions.length;
}
