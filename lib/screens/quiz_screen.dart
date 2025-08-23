import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!quizProvider.isQuizActive || quizProvider.currentQuestion == null) {
            return const Center(
              child: Text('Ошибка загрузки вопросов'),
            );
          }

          final currentQuestion = quizProvider.currentQuestion!;
          final currentIndex = quizProvider.currentQuestionIndex;
          final totalQuestions = quizProvider.questions.length;
          final userAnswer = quizProvider.userAnswers[currentIndex];

          return Column(
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
                                'Изображение недоступно',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
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
                child: Text(
                  currentQuestion.text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1C0D),
                  ),
                ),
              ),

              // Варианты ответов
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    ...currentQuestion.options.asMap().entries.map((entry) {
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
                            quizProvider.answerQuestion(index);
                            
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
                                color: isSelected ? const Color(0xFF019863) : Colors.grey.shade300,
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
                                      color: isSelected ? const Color(0xFF019863) : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                    color: isSelected ? const Color(0xFF019863) : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
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

                                         // Обратная связь при неправильном ответе
                     if (userAnswer != -1 && userAnswer != currentQuestion.correctAnswerIndex) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentQuestion.options[userAnswer],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D1C0D),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'При остановке по требованию сотрудника ДПС необходимо предъявить водительское удостоверение. Неправильно',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Кнопка "Далее"
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: userAnswer == -1 ? null : () {
                      if (currentIndex < totalQuestions - 1) {
                        quizProvider.nextQuestion();
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
          );
        },
      ),
    );
  }

  void _finishQuiz() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final rewardsProvider = Provider.of<RewardsProvider>(context, listen: false);
    
    final result = quizProvider.getQuizResult();
    final progress = (result.correctAnswers / result.totalQuestions * 100).round();
    
    // Сохраняем прогресс модуля
    quizProvider.updateModuleProgress(widget.module.id, progress);
    
    // Начисляем награды за завершение теста
    await rewardsProvider.rewardTestCompletion(
      correctAnswers: result.correctAnswers,
      totalQuestions: result.totalQuestions,
      moduleId: widget.module.id,
    );
    
    // Завершаем квиз
    quizProvider.finishQuiz();
    
    // Переходим к результатам
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          module: widget.module,
          result: result,
        ),
      ),
    );
  }
}
