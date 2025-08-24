import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../providers/rewards_provider.dart';
import '../models/module.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final Module module;

  const QuizScreen({super.key, required this.module});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  DateTime? _questionStartTime;
  DateTime? _quizStartTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quizStartTime = DateTime.now();
      _startQuestionTimer();
    });
  }

  void _startQuestionTimer() {
    _questionStartTime = DateTime.now();
  }

  int _getAnswerTimeSeconds() {
    if (_questionStartTime == null) return 0;
    return DateTime.now().difference(_questionStartTime!).inSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Тест',
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
      body: Consumer<TicketProvider>(
        builder: (context, ticketProvider, child) {
          if (ticketProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!ticketProvider.isQuizActive || ticketProvider.currentQuestion == null) {
            return const Center(
              child: Text('Ошибка загрузки вопросов'),
            );
          }

          final currentQuestion = ticketProvider.currentQuestion!;
          final currentIndex = ticketProvider.currentQuestionIndex;
          final totalQuestions = ticketProvider.currentTicket?.questions.length ?? 0;
          final userAnswer = ticketProvider.userAnswers[currentIndex];

          return SingleChildScrollView(
            child: Column(
              children: [
                // Прогресс
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '${currentIndex + 1}/$totalQuestions',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0D1C0D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (currentIndex + 1) / totalQuestions,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF019863)),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ),

                // Изображение вопроса
                if (currentQuestion.imagePath != null)
                  Container(
                    width: double.infinity,
                    height: 250,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        currentQuestion.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Изображение не найдено',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Текст вопроса
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      currentQuestion.text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D1C0D),
                      ),
                    ),
                  ),
                ),

                // Варианты ответов
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: currentQuestion.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isSelected = userAnswer == index;
                      final isAnswered = userAnswer != -1;
                      final isCorrect = index == currentQuestion.correctAnswerIndex;

                                             return Container(
                         margin: const EdgeInsets.only(bottom: 12),
                         child: GestureDetector(
                           onTap: isAnswered ? null : () async {
                             final answerTime = _getAnswerTimeSeconds();
                             ticketProvider.answerQuestion(index);
                             
                             // Начисляем награды за ответ
                             final rewardsProvider = Provider.of<RewardsProvider>(context, listen: false);
                             final isCorrect = index == currentQuestion.correctAnswerIndex;
                             await rewardsProvider.rewardQuestionAnswer(
                               isCorrect: isCorrect,
                               answerTimeSeconds: answerTime,
                             );
                             
                             // Сбрасываем таймер для следующего вопроса
                             _startQuestionTimer();
                           },
                           child: Container(
                             width: double.infinity,
                             padding: const EdgeInsets.all(16),
                             decoration: BoxDecoration(
                               color: Colors.grey.shade50,
                               borderRadius: BorderRadius.circular(12),
                               border: Border.all(
                                 color: isAnswered && isSelected
                                     ? (isCorrect ? const Color(0xFF019863) : const Color(0xFFE74C3C))
                                     : (isSelected ? const Color(0xFF019863) : Colors.grey.shade300),
                                 width: isSelected ? 2 : 1,
                               ),
                             ),
                             child: Row(
                               children: [
                                 Container(
                                   width: 20,
                                   height: 20,
                                   decoration: BoxDecoration(
                                     shape: BoxShape.circle,
                                     border: Border.all(
                                       color: isAnswered && isSelected
                                           ? (isCorrect ? const Color(0xFF019863) : const Color(0xFFE74C3C))
                                           : (isSelected ? const Color(0xFF019863) : Colors.grey.shade400),
                                       width: 2,
                                     ),
                                     color: isAnswered && isSelected
                                         ? (isCorrect ? const Color(0xFF019863) : const Color(0xFFE74C3C))
                                         : (isSelected ? const Color(0xFF019863) : Colors.transparent),
                                   ),
                                   child: isSelected
                                       ? Icon(
                                           isAnswered && !isCorrect ? Icons.close : Icons.check,
                                           size: 12,
                                           color: Colors.white,
                                         )
                                       : null,
                                 ),
                                 const SizedBox(width: 12),
                                 Expanded(
                                   child: Text(
                                     option,
                                     style: TextStyle(
                                       fontSize: 16,
                                       color: isSelected ? const Color(0xFF0D1C0D) : Colors.grey.shade700,
                                       fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         ),
                       );
                    }).toList(),
                  ),
                ),

                // Обратная связь при неправильном ответе
                if (userAnswer != -1 && userAnswer != currentQuestion.correctAnswerIndex) ...[
                  const SizedBox(height: 16),
                  // Блок с правильным ответом
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Правильный ответ:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentQuestion.options[currentQuestion.correctAnswerIndex],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D1C0D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Кнопка "Далее"
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: userAnswer == -1 ? null : () {
                        if (currentIndex < totalQuestions - 1) {
                          ticketProvider.nextQuestion();
                        } else {
                          _finishQuiz();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF019863),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        currentIndex < totalQuestions - 1 ? 'Далее' : 'Завершить',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _finishQuiz() async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final rewardsProvider = Provider.of<RewardsProvider>(context, listen: false);
    
    final result = ticketProvider.getTicketResult();
    final progress = (result.correctAnswers / result.totalQuestions * 100).round();
    
    // Сохраняем данные билета ПЕРЕД его завершением
    final currentTicket = ticketProvider.currentTicket;
    final currentUserAnswers = List<int>.from(ticketProvider.userAnswers);
    
    // Сохраняем прогресс билета
    await ticketProvider.updateTicketProgress(widget.module.id, progress);
    
    // Сохраняем время прохождения
    if (_quizStartTime != null) {
      final totalTime = DateTime.now().difference(_quizStartTime!).inSeconds;
      await ticketProvider.updateTicketTime(widget.module.id, totalTime);
    }
    
    // Начисляем награды за завершение теста
    await rewardsProvider.rewardTestCompletion(
      correctAnswers: result.correctAnswers,
      totalQuestions: result.totalQuestions,
      moduleId: widget.module.id,
    );
    
    // Завершаем квиз
    ticketProvider.finishTicket();
    
    // Переходим к результатам
    if (currentTicket != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            module: widget.module,
            result: TicketResult(
              correctAnswers: result.correctAnswers,
              totalQuestions: result.totalQuestions,
              percentage: result.percentage,
            ),
            ticket: currentTicket,
            userAnswers: currentUserAnswers,
          ),
        ),
      );
    } else {
      // Fallback если билет не найден
      Navigator.of(context).pop();
    }
  }
}
