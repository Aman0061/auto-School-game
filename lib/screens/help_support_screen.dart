import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Помощь и поддержка'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0D1C0D),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            const Text(
              'Как мы можем помочь?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D1C0D),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Часто задаваемые вопросы
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Часто задаваемые вопросы',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1C0D),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildFAQItem(
                    'Как пройти тест?',
                    'Откройте раздел "Тесты", выберите нужный билет и начните прохождение. Отвечайте на вопросы и получайте объяснения к каждому ответу.',
                  ),
                  
                  _buildFAQItem(
                    'Как отслеживать прогресс?',
                    'В разделе "Профиль" вы можете увидеть свой прогресс по всем модулям, количество завершенных тестов и средний балл.',
                  ),
                  
                  _buildFAQItem(
                    'Как найти автошколу?',
                    'В разделе "Автошколы" вы можете просмотреть список всех автошкол, их рейтинги, цены и контактную информацию.',
                  ),
                  
                  _buildFAQItem(
                    'Как работает система достижений?',
                    'За каждый правильный ответ, завершенный тест и ежедневное использование приложения вы получаете опыт и очки, которые повышают ваш уровень.',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Добавление автошколы
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF019863).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF019863).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF019863),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.business,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Добавить автошколу',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D1C0D),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Хотите добавить свою автошколу в наш каталог?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0D1C0D),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Мы поможем вам разместить информацию о вашей автошколе, включая контактные данные, цены, категории прав и отзывы клиентов.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0D1C0D),
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  InkWell(
                    onTap: () => _makePhoneCall('0700466412'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF019863),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '0700466412',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Контакты поддержки
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Связаться с поддержкой',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1C0D),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildContactItem(
                    Icons.phone,
                    'Телефон',
                    '0700466412',
                    () => _makePhoneCall('0700466412'),
                  ),
                  
                  _buildContactItem(
                    Icons.email,
                    'Email',
                    'support@autoschool-quiz.com',
                    () => _sendEmail('support@autoschool-quiz.com'),
                  ),
                  
                  _buildContactItem(
                    Icons.telegram,
                    'Telegram',
                    '@autoschool_support',
                    () => _openTelegram('@autoschool_support'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Время работы
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Время работы поддержки',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1C0D),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildTimeItem('Понедельник - Пятница', '09:00 - 18:00'),
                  _buildTimeItem('Суббота', '10:00 - 16:00'),
                  _buildTimeItem('Воскресенье', 'Выходной'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Дополнительная информация
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Важная информация',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  const Text(
                    'Приложение предназначено для подготовки к экзаменам по вождению. Мы не гарантируем 100% успешную сдачу экзамена, но предоставляем качественные материалы для изучения.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0D1C0D),
                      height: 1.5,
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

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D1C0D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF019863),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0D1C0D),
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF019863),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeItem(String day, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0D1C0D),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Поддержка Автошкола Quiz',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _openTelegram(String username) async {
    final Uri telegramUri = Uri.parse('https://t.me/$username');
    if (await canLaunchUrl(telegramUri)) {
      await launchUrl(telegramUri);
    }
  }
}
