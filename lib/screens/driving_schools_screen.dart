import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../models/driving_school.dart';
import '../providers/driving_school_provider.dart';
import 'driving_school_detail_screen.dart';

class DrivingSchoolsScreen extends StatefulWidget {
  const DrivingSchoolsScreen({super.key});

  @override
  State<DrivingSchoolsScreen> createState() => _DrivingSchoolsScreenState();
}

class _DrivingSchoolsScreenState extends State<DrivingSchoolsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DrivingSchoolProvider>(context, listen: false).loadDrivingSchools();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Отменяем предыдущий таймер
    _debounceTimer?.cancel();
    
    // Устанавливаем новый таймер на 300ms для дебаунса
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value;
      });
    });
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Поиск автошкол...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF019863)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF019863)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Color(0xFF019863), width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: _clearAllFilters,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFF019863), width: 1),
                ),
              ),
              child: const Text(
                'Очистить',
                style: TextStyle(
                  color: Color(0xFF019863),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Consumer<DrivingSchoolProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF019863)),
              ),
            );
          }

          final filteredSchools = _getFilteredSchools(provider.schools);

          return RefreshIndicator(
            onRefresh: () async {
              // Обновляем данные при свайпе вниз
              await Provider.of<DrivingSchoolProvider>(context, listen: false).loadDrivingSchools();
            },
            color: const Color(0xFF019863),
            backgroundColor: Colors.white,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: filteredSchools.length + (provider.hasMoreData && _searchQuery.isEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                // Если это последний элемент и есть еще данные, показываем кнопку "Загрузить еще"
                if (index == filteredSchools.length && provider.hasMoreData && _searchQuery.isEmpty) {
                  return _buildLoadMoreButton(context, provider);
                }
                
                final school = filteredSchools[index];
                return _buildSchoolCard(school);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreButton(BuildContext context, DrivingSchoolProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Center(
        child: provider.isLoading 
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF019863)),
            )
          : ElevatedButton(
              onPressed: () async {
                // Запоминаем текущую позицию прокрутки
                final currentPosition = _scrollController.position.pixels;
                
                // Загружаем дополнительные автошколы
                await Provider.of<DrivingSchoolProvider>(context, listen: false).loadMoreDrivingSchools();
                
                // После загрузки прокручиваем к новым данным
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    // Прокручиваем к позиции, где были загружены новые данные
                    final newPosition = currentPosition + 100; // Небольшой отступ
                    _scrollController.animateTo(
                      newPosition,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                backgroundColor: const Color(0xFF019863),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: const Color(0xFF019863).withOpacity(0.3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.expand_more, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Загрузить еще',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  List<DrivingSchool> _getFilteredSchools(List<DrivingSchool> schools) {
    // Фильтруем автошколы только по поиску
    if (_searchQuery.isEmpty) {
      return schools;
    }
    
    final query = _searchQuery.toLowerCase().trim();
    final filtered = schools.where((school) {
      return school.name.toLowerCase().contains(query) ||
             school.city.toLowerCase().contains(query) ||
             school.address.toLowerCase().contains(query);
    }).toList();
    
    // Дополнительная проверка на дубликаты
    final uniqueFiltered = <String, DrivingSchool>{};
    for (final school in filtered) {
      if (!uniqueFiltered.containsKey(school.id)) {
        uniqueFiltered[school.id] = school;
      } else {
        print('ДУБЛИКАТ В ПОИСКЕ: ID: ${school.id}, название: ${school.name}');
      }
    }
    
    final result = uniqueFiltered.values.toList();
    
    // Сортируем: оплаченные в топе
    result.sort((a, b) {
      if (a.payed && !b.payed) return -1;
      if (!a.payed && b.payed) return 1;
      return 0;
    });
    
    print('Поиск: "$query" - найдено ${result.length} автошкол');
    print('Результаты поиска: ${result.map((s) => '${s.name} (ID: ${s.id})').toList()}');
    
    return result;
  }

  Widget _buildSchoolCard(DrivingSchool school) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DrivingSchoolDetailScreen(school: school),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: school.isPromoted ? const Color(0xFFE8F5E8) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: school.isPromoted 
              ? Border.all(color: const Color(0xFF019863), width: 1)
              : Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок карточки с названием и короной
              Row(
                children: [
                  Expanded(
                    child: Text(
                      school.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (school.isPromoted) ...[
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/images/icons/crown.png',
                      width: 20,
                      height: 20,
                    ),
                  ],
                  const SizedBox(width: 16),
                  // Логотип автошколы
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5E6D3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: Color(0xFF019863),
                      size: 24,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Информация об автошколе
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey.shade600, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${school.city}, ${school.address}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.grey.shade600, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      school.phone,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.category, color: Colors.grey.shade600, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      school.categories.join(', '),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Цена и рейтинг
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF019863).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'от ${school.priceFrom} сом',
                      style: const TextStyle(
                        color: Color(0xFF019863),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  if (school.rating != null) ...[
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      school.rating!.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${school.reviewsCount})',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

