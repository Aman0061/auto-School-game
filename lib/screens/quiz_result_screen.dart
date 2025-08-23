import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/module.dart';
import '../providers/quiz_provider.dart';
import '../providers/rewards_provider.dart';

class QuizResultScreen extends StatelessWidget {
  final Module module;
  final QuizResult result;

  const QuizResultScreen({
    super.key,
    required this.module,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final isPassed = result.percentage >= 70;
    final isExam = module.isExam;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Результаты теста',
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Тесты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Автошколы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Карточки результатов
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Верхний ряд карточек
                  Row(
                    children: [
                      // Верные ответы
                      Expanded(
                        child: _buildResultCard(
                          title: 'Верные ответы',
                          value: '${result.correctAnswers}',
                          percentage: '+${result.percentage}%',
                          color: const Color(0xFF019863),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Неверные ответы
                      Expanded(
                        child: _buildResultCard(
                          title: 'Неверные ответы',
                          value: '${result.totalQuestions - result.correctAnswers}',
                          percentage: '-${100 - result.percentage}%',
                          color: const Color(0xFFE74C3C),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Время (пока статичное, можно добавить реальное время)
                  _buildResultCard(
                    title: 'Затраченное время',
                    value: '9 мин',
                    percentage: '-15%',
                    color: const Color(0xFFFAC638),
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Праздничная секция
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Иллюстрация
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Image.asset(
                      isPassed 
                          ? 'assets/images/icons/happy_icon.png'
                          : 'assets/images/icons/sad_icon.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: isPassed ? Colors.green.shade100 : Colors.red.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPassed ? Icons.sentiment_satisfied : Icons.sentiment_dissatisfied,
                            size: 60,
                            color: isPassed ? Colors.green : Colors.red,
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Сообщение
                  Text(
                    isPassed 
                        ? 'Вы прошли тест быстрее на 15%'
                        : 'Попробуйте еще раз',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1C0D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Награды
            Consumer<RewardsProvider>(
              builder: (context, rewardsProvider, child) {
                final stats = rewardsProvider.userStats;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                        'Награды',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildStatRow(
                        'Получено XP',
                        '${stats.currentXP}',
                        const Color(0xFFFAC638),
                        Icons.star,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildStatRow(
                        'Уровень',
                        '${stats.currentLevel}',
                        const Color(0xFF019863),
                        Icons.trending_up,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildStatRow(
                        'Всего очков',
                        '${stats.totalPoints}',
                        const Color(0xFF2D88E2),
                        Icons.emoji_events,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildStatRow(
                        'Максимальный комбо',
                        '${stats.maxCombo}',
                        Colors.purple,
                        Icons.local_fire_department,
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Детальная статистика
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildStatRow(
                    'Правильные ответы',
                    result.correctAnswers.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildStatRow(
                    'Неправильные ответы',
                    (result.totalQuestions - result.correctAnswers).toString(),
                    Colors.red,
                    Icons.cancel,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildStatRow(
                    'Всего вопросов',
                    result.totalQuestions.toString(),
                    Colors.blue,
                    Icons.quiz,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Прогресс бар
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Процент правильных ответов',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: result.percentage / 100,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isPassed ? Colors.green : Colors.red,
                        ),
                        minHeight: 8,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Рекомендации
            if (!isPassed) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Рекомендации',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Для успешного прохождения необходимо набрать минимум 70% правильных ответов. Рекомендуем повторить материал и попробовать снова.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Кнопки действий
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Кнопка "Посмотреть ошибки"
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Показать ошибки
                        Navigator.of(context).pop();
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
                        'Посмотреть ошибки',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Кнопка "Билеты"
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
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
                        'Билеты',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildResultCard({
    required String title,
    required String value,
    required String percentage,
    required Color color,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            percentage,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
