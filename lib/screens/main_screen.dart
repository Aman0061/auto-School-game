import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';
import 'tests_screen.dart';
import 'driving_schools_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TestsScreen(),
    const DrivingSchoolsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Показываем диалог подтверждения выхода
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Выйти из приложения?'),
            content: const Text('Вы уверены, что хотите выйти?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Выйти'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF019863),
          unselectedItemColor: const Color(0xFF0D1C0D),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          elevation: 8,
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/icons/home_icon.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  _currentIndex == 0 ? const Color(0xFF019863) : const Color(0xFF0D1C0D),
                  BlendMode.srcIn,
                ),
              ),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/icons/checklist_icon.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  _currentIndex == 1 ? const Color(0xFF019863) : const Color(0xFF0D1C0D),
                  BlendMode.srcIn,
                ),
              ),
              label: 'Тесты',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/icons/car_icon.png',
                width: 24,
                height: 24,
              ),
              label: 'Автошколы',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/icons/user_icon.png',
                width: 24,
                height: 24,
              ),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}
