import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../providers/ticket_provider.dart';
import '../providers/rewards_provider.dart';
import '../providers/task_provider.dart';
import '../models/ticket.dart';
import '../models/question.dart';
import '../models/answer.dart';
import 'exam_result_screen.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late List<Question> _examQuestions;
  late List<Answer> _userAnswers;
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  int _timeRemaining = 25 * 60; // 25 минут в секундах
  late Timer _timer;
  bool _isExamFinished = false;

  @override
  void initState() {
    super.initState();
    _initializeExam();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _initializeExam() async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    await ticketProvider.loadTickets();
    
    // Получаем все вопросы из всех билетов
    List<Question> allQuestions = [];
    for (final ticket in ticketProvider.tickets) {
      allQuestions.addAll(ticket.questions);
    }
    for (final ticket in ticketProvider.medicalTickets) {
      allQuestions.addAll(ticket.questions);
    }
    
    // Перемешиваем и выбираем 20 случайных вопросов
    allQuestions.shuffle(Random());
    _examQuestions = allQuestions.take(20).toList();
    
    // Инициализируем ответы пользователя
    _userAnswers = List.generate(20, (index) => Answer(
      id: 0,
      text: '',
      correct: false,
    ));
    
    setState(() {
      _isLoading = false;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _finishExam();
      }
    });
  }

  void _finishExam() {
    _timer.cancel();
    setState(() {
      _isExamFinished = true;
    });
    
    _navigateToResult();
  }

  void _navigateToResult() {
    final correctAnswers = _userAnswers.where((answer) => answer.correct).length;
    final percentage = (correctAnswers / 20 * 100).round();
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ExamResultScreen(
          correctAnswers: correctAnswers,
          totalQuestions: 20,
          percentage: percentage,
          timeSpent: 25 * 60 - _timeRemaining,
          questions: _examQuestions,
          userAnswers: _userAnswers,
        ),
      ),
    );
  }

  void _answerQuestion(Answer selectedAnswer) {
    if (_isExamFinished) return;
    
    // Создаем новый ответ с правильным флагом
    final userAnswer = Answer(
      id: selectedAnswer.id,
      text: selectedAnswer.text,
      correct: selectedAnswer.correct,
    );
    
    setState(() {
      _userAnswers[_currentQuestionIndex] = userAnswer;
    });
    
    // Переходим к следующему вопросу или завершаем экзамен
    if (_currentQuestionIndex < 19) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _finishExam();
    }
  }

  void _goToQuestion(int index) {
    if (index >= 0 && index < 20) {
      setState(() {
        _currentQuestionIndex = index;
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentQuestion = _examQuestions[_currentQuestionIndex];
    final userAnswer = _userAnswers[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Экзамен',
          style: TextStyle(
            color: Color(0xFF0D1C0D),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0D1C0D),
        elevation: 0,
        actions: [
          // Таймер
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _timeRemaining <= 300 ? Colors.red : const Color(0xFF019863),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatTime(_timeRemaining),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Прогресс бар
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Вопрос ${_currentQuestionIndex + 1} из 20',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0D1C0D),
                      ),
                    ),
                    Text(
                      '${_userAnswers.where((a) => a.text.isNotEmpty).length}/20',
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
                  value: (_currentQuestionIndex + 1) / 20,
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
                      currentQuestion.text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0D1C0D),
                        height: 1.4,
                      ),
                    ),
                  ),
                  
                  // Изображение на всю ширину экрана
                  if (currentQuestion.hasImage) ...[
                    const SizedBox(height: 0),
                    Container(
                      width: double.infinity,
                      height: 150,
                      child: Image.network(
                        currentQuestion.cloudflareImageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 150,
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
                  ...currentQuestion.answers.map((answer) {
                    final isSelected = userAnswer.text == answer.text;
                    final isAnswered = userAnswer.text.isNotEmpty;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: isAnswered ? null : () => _answerQuestion(answer),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? const Color(0xFF019863)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected 
                                  ? const Color(0xFF019863)
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected 
                                      ? Colors.white
                                      : Colors.grey.shade200,
                                  border: Border.all(
                                    color: isSelected 
                                        ? const Color(0xFF019863)
                                        : Colors.grey.shade400,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Color(0xFF019863),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  answer.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected 
                                        ? Colors.white
                                        : const Color(0xFF0D1C0D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          
          // Навигация по вопросам
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
            child: Column(
              children: [
                // Кнопки навигации
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(20, (index) {
                      final isAnswered = _userAnswers[index].text.isNotEmpty;
                      final isCurrent = index == _currentQuestionIndex;
                      
                      return GestureDetector(
                        onTap: () => _goToQuestion(index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? const Color(0xFF019863)
                                : isAnswered
                                    ? const Color(0xFF019863).withOpacity(0.3)
                                    : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            border: isCurrent
                                ? Border.all(color: const Color(0xFF019863), width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isCurrent || isAnswered
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Кнопка завершения
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _finishExam,
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
                      'Завершить экзамен',
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
