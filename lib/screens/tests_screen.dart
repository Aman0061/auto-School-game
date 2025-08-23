import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'quiz_screen.dart';

class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});

  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuizProvider>(context, listen: false).loadModules();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF7),
      appBar: AppBar(
        title: const Text(
          'Тесты',
          style: TextStyle(
            color: Color(0xFF0D1C0D),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFF7FCF7),
        elevation: 0,

      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final modules = quizProvider.modules;
          final completedModules = _getCompletedModulesCount(modules);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Прогресс
                Text(
                  'Завершено $completedModules из ${modules.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0D1C0D),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Прогресс бар
                LinearProgressIndicator(
                  value: completedModules / modules.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF019863)),
                  minHeight: 8,
                ),
                
                const SizedBox(height: 24),
                
                // Заголовок
                const Text(
                  'Выберите билет',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1C0D),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Сетка билетов
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    final progress = _getModuleProgress(module.id);
                    
                    return _buildTicketCard(module, progress);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTicketCard(module, int progress) {
    final isCompleted = progress >= 80; // Считаем завершенным если 80% и больше
    final isExam = module.isExam;
    
    // Определяем цвет карточки
    Color cardColor;
    if (isCompleted) {
      cardColor = const Color(0xFF019863); // Зеленый для завершенных
    } else if (isExam) {
      cardColor = const Color(0xFFFAC638); // Желтый для экзамена
    } else {
      cardColor = const Color(0xFFFAC638); // Желтый для обычных билетов
    }
    
    return GestureDetector(
      onTap: () => _startModule(module),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cardColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Номер билета в квадрате
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  isExam ? 'Э' : module.title.split(' ').last,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Название билета
            Text(
              isExam ? 'Экзамен' : 'Билет ${module.title.split(' ').last}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0D1C0D),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _startModule(module) async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    await quizProvider.loadQuestionsForModule(module.id);
    
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuizScreen(module: module),
        ),
      );
    }
  }

  int _getCompletedModulesCount(List modules) {
    int completed = 0;
    for (final module in modules) {
      if (_getModuleProgress(module.id) >= 80) {
        completed++;
      }
    }
    return completed;
  }

  int _getModuleProgress(String moduleId) {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    return quizProvider.getModuleProgress(moduleId);
  }
}
