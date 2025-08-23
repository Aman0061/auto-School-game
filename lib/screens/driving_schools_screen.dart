import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/driving_school_provider.dart';
import '../models/driving_school.dart';

class DrivingSchoolsScreen extends StatefulWidget {
  const DrivingSchoolsScreen({super.key});

  @override
  State<DrivingSchoolsScreen> createState() => _DrivingSchoolsScreenState();
}

class _DrivingSchoolsScreenState extends State<DrivingSchoolsScreen> {
  String _sortBy = 'rating'; // rating, price, name
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DrivingSchoolProvider>(context, listen: false).loadDrivingSchools();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Автошколы'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'rating',
                child: Row(
                  children: [
                    Icon(Icons.star),
                    SizedBox(width: 8),
                    Text('По рейтингу'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'price',
                child: Row(
                  children: [
                    Icon(Icons.attach_money),
                    SizedBox(width: 8),
                    Text('По цене'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha),
                    SizedBox(width: 8),
                    Text('По названию'),
                  ],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.sort),
            ),
          ),
        ],
      ),
      body: Consumer<DrivingSchoolProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DrivingSchool> schools = _getSortedSchools(provider.schools);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: schools.length,
            itemBuilder: (context, index) {
              final school = schools[index];
              return _buildSchoolCard(school);
            },
          );
        },
      ),
    );
  }

  List<DrivingSchool> _getSortedSchools(List<DrivingSchool> schools) {
    final sorted = List<DrivingSchool>.from(schools);
    
    switch (_sortBy) {
      case 'rating':
        sorted.sort((a, b) => _sortAscending 
            ? a.rating.compareTo(b.rating) 
            : b.rating.compareTo(a.rating));
        break;
      case 'price':
        sorted.sort((a, b) => _sortAscending 
            ? a.price.compareTo(b.price) 
            : b.price.compareTo(a.price));
        break;
      case 'name':
        sorted.sort((a, b) => _sortAscending 
            ? a.name.compareTo(b.name) 
            : b.name.compareTo(a.name));
        break;
    }
    
    return sorted;
  }

  Widget _buildSchoolCard(DrivingSchool school) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Изображение автошколы
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              color: Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: school.imagePath != null
                  ? Image.asset(
                      school.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage(school.name);
                      },
                    )
                  : _buildPlaceholderImage(school.name),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название и рейтинг
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        school.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            school.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Количество отзывов
                Text(
                  '${school.reviewCount} отзывов',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Описание
                Text(
                  school.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // Особенности
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: school.features.take(3).map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        feature,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Цена и кнопка
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'от ${school.price.toStringAsFixed(0)} ₽',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                          Text(
                            'Категория: ${school.category}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showEnrollmentDialog(school),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Записаться',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(String schoolName) {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            schoolName,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showEnrollmentDialog(DrivingSchool school) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Запись в ${school.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Стоимость: ${school.price.toStringAsFixed(0)} ₽'),
            const SizedBox(height: 8),
            Text('Адрес: ${school.address}'),
            const SizedBox(height: 8),
            Text('Телефон: ${school.phone}'),
            const SizedBox(height: 16),
            const Text(
              'Для записи свяжитесь с автошколой по указанному телефону или оставьте заявку.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showContactDialog(school);
            },
            child: const Text('Связаться'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(DrivingSchool school) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Связаться с автошколой'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Позвонить'),
              subtitle: Text(school.phone),
              onTap: () {
                Navigator.of(context).pop();
                // Здесь можно добавить функционал звонка
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Звонок на ${school.phone}')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Адрес'),
              subtitle: Text(school.address),
              onTap: () {
                Navigator.of(context).pop();
                // Здесь можно добавить открытие карты
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Адрес: ${school.address}')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
