import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class TestTasksScreen extends StatelessWidget {
  const TestTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тест заданий'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0D1C0D),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Загрузка: ${taskProvider.isLoading}'),
                Text('Всего заданий: ${taskProvider.tasks.length}'),
                const SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: () {
                    taskProvider.initializeTasks();
                  },
                  child: const Text('Инициализировать задания'),
                ),
                
                const SizedBox(height: 20),
                
                Text('Ежедневные задания: ${taskProvider.getTasksByType(TaskType.daily).length}'),
                Text('Еженедельные задания: ${taskProvider.getTasksByType(TaskType.weekly).length}'),
                Text('Достижения: ${taskProvider.getTasksByType(TaskType.achievement).length}'),
                Text('Специальные: ${taskProvider.getTasksByType(TaskType.special).length}'),
                
                const SizedBox(height: 20),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: taskProvider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskProvider.tasks[index];
                      return Card(
                        child: ListTile(
                          title: Text(task.title),
                          subtitle: Text('${task.type} - ${task.isActive ? 'Активно' : 'Неактивно'}'),
                          trailing: Text('${task.currentValue}/${task.targetValue}'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
