import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/answer.dart';

class ExamAnswersReviewScreen extends StatefulWidget {
  final List<Question> questions;
  final List<Answer> userAnswers;

  const ExamAnswersReviewScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
  });

  @override
  State<ExamAnswersReviewScreen> createState() => _ExamAnswersReviewScreenState();
}

class _ExamAnswersReviewScreenState extends State<ExamAnswersReviewScreen> {
  int _currentQuestionIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Просмотр ответов',
          style: TextStyle(
            color: Color(0xFF0D1C0D),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0D1C0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Прогресс и навигация
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Вопрос ${_currentQuestionIndex + 1} из ${widget.questions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0D1C0D),
                      ),
                    ),
                    Text(
                      '${widget.userAnswers.where((a) => a.correct).length}/${widget.questions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF019863),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / widget.questions.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF019863)),
                  minHeight: 8,
                ),
              ],
            ),
          ),
          
          // Вопрос
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                                    // Текст вопроса
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      widget.questions[_currentQuestionIndex].text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0D1C0D),
                        height: 1.4,
                      ),
                    ),
                  ),
                  
                  // Изображение на всю ширину экрана
                  if (widget.questions[_currentQuestionIndex].hasImage) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 300,
                      child: Image.network(
                        widget.questions[_currentQuestionIndex].cloudflareImageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 300,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: double.infinity,
                            height: 300,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Варианты ответов
                  ...widget.questions[_currentQuestionIndex].answers.map((answer) {
                    final userAnswer = widget.userAnswers[_currentQuestionIndex];
                    final isUserAnswer = userAnswer.text == answer.text;
                    final isCorrectAnswer = answer.correct;
                    
                    Color backgroundColor;
                    Color borderColor;
                    IconData? icon;
                    Color iconColor;
                    
                    if (isCorrectAnswer) {
                      backgroundColor = const Color(0xFFE8F5E8);
                      borderColor = const Color(0xFF019863);
                      icon = Icons.check_circle;
                      iconColor = const Color(0xFF019863);
                    } else if (isUserAnswer && !isCorrectAnswer) {
                      backgroundColor = const Color(0xFFFFEBEE);
                      borderColor = Colors.red;
                      icon = Icons.cancel;
                      iconColor = Colors.red;
                    } else {
                      backgroundColor = Colors.white;
                      borderColor = Colors.grey.shade300;
                      icon = null;
                      iconColor = Colors.transparent;
                    }
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: borderColor,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (icon != null) ...[
                              Icon(icon, color: iconColor, size: 20),
                              const SizedBox(width: 12),
                            ] else ...[
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade200,
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Text(
                                answer.text,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isCorrectAnswer || isUserAnswer
                                      ? const Color(0xFF0D1C0D)
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: 24),
                  
                  // Статус ответа
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.userAnswers[_currentQuestionIndex].correct
                          ? const Color(0xFFE8F5E8)
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.userAnswers[_currentQuestionIndex].correct
                            ? const Color(0xFF019863)
                            : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.userAnswers[_currentQuestionIndex].correct
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: widget.userAnswers[_currentQuestionIndex].correct
                              ? const Color(0xFF019863)
                              : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.userAnswers[_currentQuestionIndex].correct
                                ? 'Правильный ответ'
                                : 'Неправильный ответ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: widget.userAnswers[_currentQuestionIndex].correct
                                  ? const Color(0xFF019863)
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Навигация
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentQuestionIndex > 0
                        ? () {
                            setState(() {
                              _currentQuestionIndex--;
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF019863),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Предыдущий',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentQuestionIndex < widget.questions.length - 1
                        ? () {
                            setState(() {
                              _currentQuestionIndex++;
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF019863),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Следующий',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
