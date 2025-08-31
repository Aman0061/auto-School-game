import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/question.dart';
import '../models/answer.dart';
import 'exam_answers_review_screen.dart';

class ExamResultScreen extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final int percentage;
  final int timeSpent;
  final List<Question> questions;
  final List<Answer> userAnswers;

  const ExamResultScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.percentage,
    required this.timeSpent,
    required this.questions,
    required this.userAnswers,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showAnswersReview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExamAnswersReviewScreen(
          questions: questions,
          userAnswers: userAnswers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wrongAnswers = totalQuestions - correctAnswers;
    final isPassed = percentage >= 80; // Экзамен сдан если 80% или больше

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'Результаты экзамена',
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Тесты выбраны
        selectedItemColor: const Color(0xFF019863),
        unselectedItemColor: const Color(0xFF0D1C0D),
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (index) {
          if (index != 1) { // Если нажали не на "Тесты"
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/icons/home_icon.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Color(0xFF0D1C0D),
                BlendMode.srcIn,
              ),
            ),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/icons/test.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Color(0xFF019863),
                BlendMode.srcIn,
              ),
            ),
            label: 'Тесты',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/icons/car-outline.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Color(0xFF0D1C0D),
                BlendMode.srcIn,
              ),
            ),
            label: 'Автошколы',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/icons/user.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Color(0xFF0D1C0D),
                BlendMode.srcIn,
              ),
            ),
            label: 'Профиль',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Основной результат
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isPassed ? const Color(0xFFE8F5E8) : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPassed ? const Color(0xFF019863) : Colors.red,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isPassed ? Icons.check_circle : Icons.cancel,
                    size: 64,
                    color: isPassed ? const Color(0xFF019863) : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPassed ? 'Экзамен сдан!' : 'Экзамен не сдан',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isPassed ? const Color(0xFF019863) : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: isPassed ? const Color(0xFF019863) : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Детальная статистика
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Детальная статистика',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1C0D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Правильные ответы
                  _buildStatRow(
                    icon: Icons.check_circle,
                    iconColor: const Color(0xFF019863),
                    title: 'Правильные ответы',
                    value: '$correctAnswers из $totalQuestions',
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Неправильные ответы
                  _buildStatRow(
                    icon: Icons.cancel,
                    iconColor: Colors.red,
                    title: 'Неправильные ответы',
                    value: '$wrongAnswers из $totalQuestions',
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Время
                  _buildStatRow(
                    icon: Icons.timer,
                    iconColor: const Color(0xFF019863),
                    title: 'Время выполнения',
                    value: _formatTime(timeSpent),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Процент
                  _buildStatRow(
                    icon: Icons.percent,
                    iconColor: const Color(0xFF019863),
                    title: 'Процент правильных',
                    value: '$percentage%',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Кнопки действий
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
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
                    child: const Text(
                      'Вернуться на главную',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showAnswersReview(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D88E2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Посмотреть ответы',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF019863),
                      side: const BorderSide(color: Color(0xFF019863)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Пройти экзамен снова',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF0D1C0D),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF019863),
          ),
        ),
      ],
    );
  }
}
