import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/driving_school_provider.dart';
import '../providers/rewards_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuizProvider>(context, listen: false).loadModules();
      Provider.of<DrivingSchoolProvider>(context, listen: false).loadDrivingSchools();
      Provider.of<RewardsProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserProfileSection(),
              const SizedBox(height: 16),
              _buildMetricsRow(),
              const SizedBox(height: 12),
              _buildAchievementsCard(),
              const SizedBox(height: 12),
              _buildExperienceProgress(),
              const SizedBox(height: 16),
              _buildDailyTasksSection(),
              const SizedBox(height: 16),
              _buildDrivingSchoolOfMonth(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileSection() {
    return Row(
          children: [
            // Аватар
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF019863),
              child: const Text(
                'А',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            // Имя и автошкола
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Муканбет уулу Аман',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1C0D)),
                ),
                const Text(
                  'Автошкола BCD',
                  style: TextStyle(fontSize: 13, color: Color(0xFF019863)),
                ),
              ],
            ),
          ],
        );
  }

  Widget _buildMetricsRow() {
    return Consumer<RewardsProvider>(
      builder: (context, rewardsProvider, child) {
        final stats = rewardsProvider.userStats;
        return Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Опыт',
                value: '${stats.currentXP}',
                iconPath: 'assets/images/icons/rocket_icon.png',
                backgroundColor: const Color(0xFFFAC638),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Очки',
                value: '${stats.totalPoints}',
                iconPath: 'assets/images/icons/target_icon.png',
                backgroundColor: const Color(0xFFB8F5E6),
                titleColor: const Color(0xFF2D88E2),
                valueColor: const Color(0xFF2D88E2),
              ),
            ),
          ],
        );
      },
    );
  }

Widget _buildMetricCard({
  required String title,
  required String value,
  required String iconPath,
  required Color backgroundColor,
  Color? titleColor,
  Color? valueColor,
}) {
  return Container(
    height: 100,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        // Иконка слева
        Image.asset(
          iconPath,
          width: 50,
          height: 50,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 12),
        // Текст справа
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: titleColor ?? Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 0),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color:  valueColor ?? Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


Widget _buildAchievementsCard() {
  return Consumer<RewardsProvider>(
    builder: (context, rewardsProvider, child) {
      final stats = rewardsProvider.userStats;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF019863),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 🏆 Иконка
            Image.asset(
              'assets/images/icons/trophy_icon.png',
              width: 60,
              height: 60,
            ),
            const SizedBox(width: 12),

            // 🔢 Число и слово в столбик
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stats.currentLevel}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Уровень',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const Spacer(),

            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      );
    },
  );
}


  Widget _buildExperienceProgress() {
    return Consumer<RewardsProvider>(
      builder: (context, rewardsProvider, child) {
        final stats = rewardsProvider.userStats;
        final progress = rewardsProvider.getLevelProgress();
        final requiredXP = rewardsProvider.getRequiredXPForNextLevel();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Опыт', style: TextStyle(color: Color(0xFF0D1C0D))),
                Text('$requiredXP', style: const TextStyle(color: Color(0xFF0D1C0D))),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF019863)),
              minHeight: 6,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDailyTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ежедневные задания',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1C0D)),
        ),
        const SizedBox(height: 12),
        _buildDailyTask(
          icon: 'assets/images/icons/checklist_icon.svg',
          title: 'Пройдите тесты',
          subtitle: 'Завершите 3 теста',
        ),
        const SizedBox(height: 8),
        _buildDailyTask(
          icon: 'assets/images/icons/share_icon.png',
          title: 'Поделитесь',
          subtitle: 'Поделитесь с друзьями',
        ),
        const SizedBox(height: 8),
        _buildDailyTask(
          icon: Icons.help_outline,
          title: 'Ответьте на вопросы',
          subtitle: 'Получите ответы на вопросы',
        ),
      ],
    );
  }

  Widget _buildDailyTask({
    required dynamic icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFAC638),
              borderRadius: BorderRadius.circular(6),
            ),
            child: icon is String
                ? (icon.endsWith('.svg')
                    ? SvgPicture.asset(icon, width: 20, height: 20, color: Colors.white)
                    : Image.asset(icon, width: 20, height: 20, color: Colors.white))
                : Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFAC638),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text(
              'Выполнить',
              style: TextStyle(color: Color(0xFF0D1C0D), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrivingSchoolOfMonth() {
    return Consumer<DrivingSchoolProvider>(
      builder: (context, provider, _) {
        if (provider.schools.isEmpty) return const SizedBox();

        final school = provider.schools.first;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Автошкола месяца',
                  style: TextStyle(fontSize: 11, color: Colors.purple.shade700),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Автошкола "DCD"',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D1C0D))),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < 4 ? Icons.star : Icons.star_half,
                              size: 16,
                              color: const Color(0xFFFAC638),
                            );
                          }),
                        ),
                        const SizedBox(height: 4),
                        Text('Бишкек: Абдырахманова 156/2',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        Text('Категория “В” От 25000 сом',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.directions_car, color: Colors.white, size: 20),
                          Text('DRIVING\nSCHOOL',
                              style: TextStyle(fontSize: 7, color: Colors.white),
                              textAlign: TextAlign.center),
                          Text('STRUCTURED\nREAL WORK',
                              style: TextStyle(fontSize: 5, color: Colors.white),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Открыть детали автошколы')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF019863),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Подробнее'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
