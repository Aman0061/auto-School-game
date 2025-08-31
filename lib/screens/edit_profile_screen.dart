import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  String _selectedUserType = 'seeker';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _selectedUserType = user?.userType ?? 'seeker';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      
      if (currentUser == null) {
        throw Exception('Пользователь не найден');
      }

      print('EditProfileScreen: Текущий пользователь ID: ${currentUser.id}');
      print('EditProfileScreen: Текущий пользователь name: ${currentUser.name}');

      // Создаем обновленного пользователя
      final updatedUser = currentUser.copyWith(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        userType: _selectedUserType,
      );

      print('EditProfileScreen: Обновленный пользователь ID: ${updatedUser.id}');
      print('EditProfileScreen: Обновленный пользователь name: ${updatedUser.name}');

      // Обновляем пользователя в базе данных
      final success = await authProvider.updateProfile(updatedUser);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Профиль успешно обновлен'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        throw Exception('Не удалось обновить профиль в базе данных');
      }
    } catch (e) {
      print('EditProfileScreen: Ошибка при сохранении профиля: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0D1C0D),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Поле имени
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Имя',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста, введите имя';
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Поле username
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Логин',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста, введите логин';
                      }
                      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                        return 'Логин может содержать только английские буквы, цифры и знак подчеркивания';
                      }
                      if (value.length < 3) {
                        return 'Логин должен содержать минимум 3 символа';
                      }
                      if (value.length > 20) {
                        return 'Логин должен содержать максимум 20 символов';
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Выбор типа пользователя
                const Text(
                  'Тип пользователя:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0D1C0D),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedUserType = 'student';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _selectedUserType == 'student' 
                                ? Colors.blue 
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedUserType == 'student' 
                                  ? Colors.blue 
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            'Студент',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedUserType == 'student' 
                                  ? Colors.white 
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedUserType = 'seeker';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _selectedUserType == 'seeker' 
                                ? Colors.blue 
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedUserType == 'seeker' 
                                  ? Colors.blue 
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            'Ищущий',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedUserType == 'seeker' 
                                  ? Colors.white 
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Кнопка сохранения
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF019863).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF019863),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Сохранить',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
