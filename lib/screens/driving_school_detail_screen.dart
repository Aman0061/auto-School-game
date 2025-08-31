import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/driving_school.dart';
import '../models/user.dart';
import '../providers/driving_school_provider.dart';
import '../providers/auth_provider.dart';

class DrivingSchoolDetailScreen extends StatelessWidget {
  final DrivingSchool school;

  const DrivingSchoolDetailScreen({
    super.key,
    required this.school,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          school.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF019863)),
            onPressed: () => _shareSchool(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Логотип и основная информация
            _buildHeader(),
            
            // Основная информация
            _buildMainInfo(),
            
            // Контактная информация
            _buildContactInfo(),
            
            // Категории прав
            _buildCategories(context),
            
            // Описание
            if (school.description != null && school.description!.isNotEmpty)
              _buildDescription(),
            
            // Кнопки действий
            _buildActionButtons(context),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Логотип
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5E6D3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'assets/images/icons/school_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Название и корона
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  school.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (school.isPromoted) ...[
                const SizedBox(width: 8),
                Image.asset(
                  'assets/images/icons/crown.png',
                  width: 24,
                  height: 24,
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Город
          Text(
            school.city,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Рейтинг
          if (school.rating != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    final rating = school.rating ?? 0;
                    return Icon(
                      Icons.star,
                      size: 20,
                      color: index < rating.floor() ? const Color(0xFFFAC638) : Colors.grey.shade300,
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  '${school.rating!.toStringAsFixed(1)} (${school.reviewsCount} отзывов)',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
            'Основная информация',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Адрес
          _buildInfoRow(
            icon: Icons.location_on,
            title: 'Адрес',
            value: school.address,
            color: const Color(0xFF019863),
          ),
          
          const SizedBox(height: 12),
          
          // Цена
          _buildInfoRow(
            icon: Icons.attach_money,
            title: 'Цена от',
            value: '${school.priceFrom.toStringAsFixed(0)} сом',
            color: const Color(0xFFFAC638),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
            'Контактная информация',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Телефон
          _buildContactRow(
            icon: Icons.phone,
            title: 'Телефон',
            value: school.phone,
            color: const Color(0xFF019863),
            onTap: () => _makePhoneCall(school.phone),
          ),
          
          if (school.site != null && school.site!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildContactRow(
              icon: Icons.language,
              title: 'Сайт',
              value: school.site!,
              color: const Color(0xFF2196F3),
              onTap: () => _launchUrl(school.site!),
            ),
          ],
          
          if (school.whatsapp != null && school.whatsapp!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildContactRow(
              icon: Icons.chat,
              title: 'WhatsApp',
              value: school.whatsapp!,
              color: const Color(0xFF25D366),
              onTap: () => _launchWhatsApp(school.whatsapp!),
            ),
          ],
          
          if (school.telegram != null && school.telegram!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildContactRow(
              icon: Icons.telegram,
              title: 'Telegram',
              value: school.telegram!,
              color: const Color(0xFF0088CC),
              onTap: () => _launchTelegram(school.telegram!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: const Text(
              'Категории прав и цены',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          
          FutureBuilder<List<String>>(
            future: Provider.of<DrivingSchoolProvider>(context, listen: false).getSchoolCategories(school.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF019863)),
                    ),
                  ),
                );
              }
              
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Категории не указаны',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                );
              }
              
              final categories = snapshot.data!;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  children: categories.map((category) => FutureBuilder<int?>(
                    future: Provider.of<DrivingSchoolProvider>(context, listen: false).getPriceForCategory(school.id, category),
                    builder: (context, priceSnapshot) {
                      final price = priceSnapshot.data;
                      
                      return Container(
                        margin: const EdgeInsets.only(left: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Цветной значок категории
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(category),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Название категории и цена
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getCategoryName(category),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (price != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      '${price.toStringAsFixed(0)} сом',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
            'Описание',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            school.description!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Кнопка "Записаться"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _enrollInSchool(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF019863),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Оставить заявку',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Кнопка "Позвонить"
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _makePhoneCall(school.phone),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF019863),
                side: const BorderSide(color: Color(0xFF019863)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Позвонить',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _makePhoneCall(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchWhatsApp(String phone) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchTelegram(String username) async {
    final String cleanUsername = username.startsWith('@') ? username.substring(1) : username;
    final Uri telegramUri = Uri.parse('https://t.me/$cleanUsername');
    if (await canLaunchUrl(telegramUri)) {
      await launchUrl(telegramUri, mode: LaunchMode.externalApplication);
    }
  }

  void _enrollInSchool(BuildContext context) {
    // Получаем данные пользователя
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user == null) {
      // Если пользователь не авторизован, показываем диалог для входа
      _showLoginDialog(context);
      return;
    }
    
    // Проверяем, есть ли Telegram у автошколы
    if (school.telegram == null || school.telegram!.isEmpty) {
      // Если нет Telegram, показываем обычный диалог
      _showEnrollDialog(context);
      return;
    }
    
    // Если есть Telegram, отправляем заявку
    _sendTelegramApplication(context, user);
  }
  
  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Требуется авторизация'),
          content: const Text('Для записи в автошколу необходимо войти в аккаунт.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Здесь можно добавить навигацию к экрану входа
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF019863),
                foregroundColor: Colors.white,
              ),
              child: const Text('Войти'),
            ),
          ],
        );
      },
    );
  }
  
  void _showEnrollDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Запись в автошколу'),
          content: Text('Вы хотите записаться в автошколу "${school.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _makePhoneCall(school.phone);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF019863),
                foregroundColor: Colors.white,
              ),
              child: const Text('Позвонить'),
            ),
          ],
        );
      },
    );
  }
  
  void _sendTelegramApplication(BuildContext context, User user) async {
    // Получаем выбранную категорию (пока используем первую доступную)
    final selectedCategory = school.categories.isNotEmpty ? school.categories.first : 'BC';
    
    // Формируем сообщение
    final message = '''
    ${school.name} - новая заявка
    ${user.name}
    Категория $selectedCategory
    ${user.username}
    '''.trim();
    
    // Создаем URL для Telegram
    final telegramUrl = 'https://t.me/${school.telegram!.replaceAll('@', '')}?text=${Uri.encodeComponent(message)}';
    
    // Открываем Telegram
    final Uri uri = Uri.parse(telegramUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // Показываем уведомление об успешной отправке
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заявка отправлена в Telegram!'),
            backgroundColor: Color(0xFF019863),
          ),
        );
      }
    } else {
      // Показываем ошибку
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось открыть Telegram'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareSchool(BuildContext context) {
    final String shareText = '''
🚗 ${school.name}

📍 ${school.city}, ${school.address}
📞 ${school.phone}
💰 Цена от: ${school.priceFrom} сом
⭐ Рейтинг: ${school.rating}/5 (${school.reviewsCount} отзывов)

${school.description ?? 'Описание отсутствует'}

#автошкола #${school.city} #водительскиеправа
    '''.trim();

    Share.share(
      shareText,
      subject: 'Автошкола ${school.name}',
    );
  }

  // Получение цвета для категории
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'A':
        return const Color(0xFF4CAF50); // Зеленый
      case 'B':
        return const Color(0xFFFFC107); // Желтый
      case 'C':
        return const Color(0xFFFF5722); // Красно-оранжевый
      case 'D':
        return const Color(0xFFFF9800); // Оранжевый
      case 'E':
        return const Color(0xFF9C27B0); // Фиолетовый
      case 'BE':
        return const Color(0xFFFF7043); // Оранжево-персиковый
      case 'CE':
        return const Color(0xFF795548); // Коричневый
      case 'DE':
        return const Color(0xFF607D8B); // Сине-серый
      default:
        return const Color(0xFF019863); // Основной зеленый
    }
  }

  // Получение названия категории
  String _getCategoryName(String category) {
    switch (category) {
      case 'A':
        return 'Категория A';
      case 'B':
        return 'Категория B';
      case 'C':
        return 'Категория C';
      case 'D':
        return 'Категория D';
      case 'E':
        return 'Категория E';
      case 'BE':
        return 'Категория B+E';
      case 'CE':
        return 'Категория C+E';
      case 'DE':
        return 'Категория D+E';
      default:
        return 'Категория $category';
    }
  }
}
