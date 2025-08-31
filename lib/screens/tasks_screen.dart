import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/task_provider.dart';
import '../providers/rewards_provider.dart';
import '../models/task.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Обновляем состояние при изменении таба
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Задания',
          style: TextStyle(
            color: Color(0xFF0D1C0D),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0D1C0D)),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Статистика
              _buildStatistics(taskProvider),
              
              // Табы
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFFFAC638),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFFFAC638),
                  tabs: const [
                    Tab(text: 'Ежедневные'),
                    Tab(text: 'Еженедельные'),
                    Tab(text: 'Достижения'),
                    Tab(text: 'Специальные'),
                  ],
                ),
              ),
              
              // Список заданий
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTaskList(taskProvider.getTasksByType(TaskType.daily)),
                    _buildTaskList(taskProvider.getTasksByType(TaskType.weekly)),
                    _buildTaskList(taskProvider.getTasksByType(TaskType.achievement)),
                    _buildTaskList(taskProvider.getTasksByType(TaskType.special)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatistics(TaskProvider taskProvider) {
    final completedTasks = taskProvider.completedTasks.length;
    final totalTasks = taskProvider.tasks.length;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Выполнено заданий',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedTasks из $totalTasks',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1C0D),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAC638),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$completionRate%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D1C0D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          'Нет заданий',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Иконка
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: task.isCompleted 
                        ? Colors.green 
                        : const Color(0xFFFAC638),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: task.iconPath != null
                      ? (task.iconPath!.endsWith('.svg')
                          ? SvgPicture.asset(
                              task.iconPath!,
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            )
                          : Image.asset(
                              task.iconPath!,
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ))
                      : const Icon(
                          Icons.task_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                ),
                const SizedBox(width: 12),
                
                // Заголовок и описание
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: task.isCompleted 
                              ? Colors.grey[600] 
                              : const Color(0xFF0D1C0D),
                          decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Статус
                if (task.isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Прогресс
            if (!task.isCompleted) ...[
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: task.progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFAC638)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${task.currentValue}/${task.targetValue}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0D1C0D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            
            // Награды
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAC638).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Color(0xFFFAC638),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${task.xpReward} XP',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFAC638),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${task.pointsReward} очков',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                
                // Время истечения
                if (task.expiresAt != null && !task.isCompleted)
                  Text(
                    _getTimeRemaining(task.expiresAt!),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            
            // Статус выполнения
            if (!task.isCompleted) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'В процессе выполнения',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTimeRemaining(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);
    
    if (difference.inDays > 0) {
      return 'Осталось ${difference.inDays} дн.';
    } else if (difference.inHours > 0) {
      return 'Осталось ${difference.inHours} ч.';
    } else if (difference.inMinutes > 0) {
      return 'Осталось ${difference.inMinutes} мин.';
    } else {
      return 'Скоро истечет';
    }
  }
}
