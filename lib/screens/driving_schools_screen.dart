import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/driving_school_provider.dart';
import '../models/driving_school.dart';
import 'driving_school_detail_screen.dart';

class DrivingSchoolsScreen extends StatefulWidget {
  const DrivingSchoolsScreen({super.key});

  @override
  State<DrivingSchoolsScreen> createState() => _DrivingSchoolsScreenState();
}

class _DrivingSchoolsScreenState extends State<DrivingSchoolsScreen> {
  final TextEditingController _searchController = TextEditingController();
  RangeValues _priceRange = const RangeValues(0, 50000);
  double _minRating = 0.0;
  String _selectedRegion = 'Все регионы';
  List<String> _selectedCategories = [];

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
    super.dispose();
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedRegion = 'Все регионы';
      _selectedCategories.clear();
      _priceRange = const RangeValues(0, 50000);
      _minRating = 0.0;
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
                            setState(() {});
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
                onChanged: (value) {
                  setState(() {});
                },
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
              child: CircularProgressIndicator(),
            );
          }

          List<DrivingSchool> filteredSchools = _getFilteredSchools(provider.schools);

          return Column(
            children: [
              // Фильтры под поиском
              _buildFilterButtons(),
              
              // Список автошкол
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredSchools.length,
                  itemBuilder: (context, index) {
                    final school = filteredSchools[index];
                    return _buildSchoolCard(school);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
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
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        'assets/images/icons/school_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Адрес
              Text(
                '${school.city}, ${school.address}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Цена
              Text(
                'От ${school.priceFrom.toStringAsFixed(0)} сом',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Рейтинг со звездами
              if (school.rating != null) ...[
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        final rating = school.rating ?? 0;
                        return Icon(
                          Icons.star,
                          size: 16,
                          color: index < rating.floor() ? const Color(0xFFFAC638) : Colors.grey.shade300,
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      school.rating!.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Кнопка "Позвонить" только для платных автошкол
              if (school.isPromoted) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _callSchool(school),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF019863),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone, size: 18),
                        const SizedBox(width: 12),
                        const Text(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Фильтр "Регион"
            _buildFilterButton(
              text: _selectedRegion,
              onTap: () => _showRegionDialog(),
            ),
            const SizedBox(width: 12),
            
            // Фильтр "Категории"
            _buildFilterButton(
              text: _selectedCategories.isEmpty 
                  ? 'Все категории' 
                  : _selectedCategories.length == 1 
                      ? _selectedCategories.first 
                      : '${_selectedCategories.length} категории',
              onTap: () => _showCategoryDialog(),
            ),
            const SizedBox(width: 12),
            
            // Фильтр "Цена"
            _buildFilterButton(
              text: 'Цена: ${_priceRange.start.round()}-${_priceRange.end.round()} сом',
              onTap: () => _showPriceDialog(),
            ),
            const SizedBox(width: 12),
            
            // Фильтр "Рейтинг"
            _buildFilterButton(
              text: _minRating == 0.0 
                  ? 'Любой рейтинг'
                  : _minRating == 4.9 
                      ? 'Лучшее'
                      : _minRating == 4.5 
                          ? 'Превосходно'
                          : _minRating == 4.0 
                              ? 'Хорошо'
                              : _minRating == 3.5 
                                  ? 'Достаточно хорошо'
                                  : 'Неплохо',
              onTap: () => _showRatingDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton({required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0D1C0D),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Color(0xFF019863),
            ),
          ],
        ),
      ),
    );
  }

  List<DrivingSchool> _getFilteredSchools(List<DrivingSchool> schools) {
    // Сначала фильтруем автошколы
    List<DrivingSchool> filteredSchools = schools.where((school) {
      // Фильтр по названию
      if (_searchController.text.isNotEmpty) {
        if (!school.name.toLowerCase().contains(_searchController.text.toLowerCase())) {
          return false;
        }
      }
      
      // Фильтр по цене
      if (school.priceFrom < _priceRange.start || school.priceFrom > _priceRange.end) {
        return false;
      }
      
      // Фильтр по рейтингу
      if ((school.rating ?? 0) < _minRating) {
        return false;
      }
      
      return true;
    }).toList();
    
    // Затем сортируем: автошколы с короной в начало, остальные по рейтингу
    filteredSchools.sort((a, b) {
      // Сначала сравниваем по наличию короны (продвигаемые автошколы)
      if (a.isPromoted && !b.isPromoted) return -1;
      if (!a.isPromoted && b.isPromoted) return 1;
      
      // Если обе с короной или обе без короны, сортируем по рейтингу (по убыванию)
      double ratingA = a.rating ?? 0.0;
      double ratingB = b.rating ?? 0.0;
      return ratingB.compareTo(ratingA);
    });
    
    return filteredSchools;
  }

  void _callSchool(DrivingSchool school) {
    // Здесь можно добавить функционал звонка
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Звонок в ${school.name}'),
        backgroundColor: const Color(0xFF019863),
      ),
    );
  }

  void _showRegionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF019863).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.location_on, color: Color(0xFF019863)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Выберите регион',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D1C0D),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  'Все регионы',
                  'Бишкек',
                  'Ош',
                  'Чуйская область',
                  'Иссык-Кульская область',
                  'Нарынская область',
                  'Таласская область',
                  'Джалал-Абадская область',
                  'Баткенская область',
                ].map((region) => InkWell(
                  onTap: () {
                    setState(() {
                      _selectedRegion = region;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: _selectedRegion == region 
                          ? const Color(0xFF019863).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            region,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: _selectedRegion == region 
                                  ? FontWeight.w600 
                                  : FontWeight.w400,
                              color: _selectedRegion == region 
                                  ? const Color(0xFF019863)
                                  : const Color(0xFF0D1C0D),
                            ),
                          ),
                        ),
                        if (_selectedRegion == region)
                          const Icon(
                            Icons.check,
                            color: Color(0xFF019863),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

  }

  void _showCategoryDialog() {
    List<String> tempSelectedCategories = List.from(_selectedCategories);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF019863).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.category, color: Color(0xFF019863)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Выберите категории',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D1C0D),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Можно выбрать несколько категорий',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        'Категория A',
                        'Категория B',
                        'Категория C',
                        'Категория D',
                        'Категория E',
                        'Категория B+E',
                        'Категория C+E',
                        'Категория D+E',
                      ].map((category) => InkWell(
                        onTap: () {
                          setModalState(() {
                            if (tempSelectedCategories.contains(category)) {
                              tempSelectedCategories.remove(category);
                            } else {
                              tempSelectedCategories.add(category);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: tempSelectedCategories.contains(category)
                                ? const Color(0xFF019863).withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: tempSelectedCategories.contains(category),
                                onChanged: (value) {
                                  setModalState(() {
                                    if (value == true) {
                                      tempSelectedCategories.add(category);
                                    } else {
                                      tempSelectedCategories.remove(category);
                                    }
                                  });
                                },
                                activeColor: const Color(0xFF019863),
                              ),
                              Expanded(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: tempSelectedCategories.contains(category)
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: tempSelectedCategories.contains(category)
                                        ? const Color(0xFF019863)
                                        : const Color(0xFF0D1C0D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Отмена',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategories = List.from(tempSelectedCategories);
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF019863),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Готово'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );

  }

  void _showPriceDialog() {
    TextEditingController fromController = TextEditingController(
      text: _priceRange.start.round().toString(),
    );
    TextEditingController toController = TextEditingController(
      text: _priceRange.end.round().toString(),
    );
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF019863).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.attach_money, color: Color(0xFF019863)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Диапазон цен',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D1C0D),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Укажите диапазон цен в сомах',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'От',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0D1C0D),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: fromController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '0',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF019863)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'До',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0D1C0D),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: toController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '50000',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF019863)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Отмена',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final from = int.tryParse(fromController.text) ?? 0;
                        final to = int.tryParse(toController.text) ?? 50000;
                        setState(() {
                          _priceRange = RangeValues(from.toDouble(), to.toDouble());
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF019863),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Готово'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _showRatingDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF019863).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.star, color: Color(0xFF019863)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Минимальный рейтинг',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D1C0D),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Выберите минимальный рейтинг',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        {'name': 'Лучшее - 4.9 и выше', 'rating': 4.9},
                        {'name': 'Превосходно - 4.5 и выше', 'rating': 4.5},
                        {'name': 'Хорошо - 4.0 и выше', 'rating': 4.0},
                        {'name': 'Достаточно хорошо - 3.5 и выше', 'rating': 3.5},
                        {'name': 'Неплохо - 3.0 и выше', 'rating': 3.0},
                      ].map((option) => InkWell(
                        onTap: () {
                          setState(() {
                            _minRating = option['rating'] as double;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: _minRating == option['rating']
                                ? const Color(0xFF019863).withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option['name'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: _minRating == option['rating']
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: _minRating == option['rating']
                                        ? const Color(0xFF019863)
                                        : const Color(0xFF0D1C0D),
                                  ),
                                ),
                              ),
                              if (_minRating == option['rating'])
                                const Icon(
                                  Icons.check,
                                  color: Color(0xFF019863),
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
