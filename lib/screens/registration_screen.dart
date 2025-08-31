import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'main_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  String _selectedUserType = 'seeker'; // 'student' или 'seeker'

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      bool success = await authProvider.register(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        userType: _selectedUserType,
      );

      if (success && mounted) {
        // Показываем уведомление об успешной авторизации
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Добро пожаловать!'),
            backgroundColor: Color(0xFF019863),
          ),
        );
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false, // Удаляем все предыдущие экраны из стека
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Заголовок
                const Text(
                  'Регистрация',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1C0D),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Создайте свой аккаунт',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
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
                
                const SizedBox(height: 20),
                
                // Поле пароля
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Пароль',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста, введите пароль';
                      }
                      if (value.length < 6) {
                        return 'Пароль должен содержать минимум 6 символов';
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Поле повторения пароля
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: TextFormField(
                    controller: _repeatPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Повторите пароль',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста, повторите пароль';
                      }
                      if (value != _passwordController.text) {
                        return 'Пароли не совпадают';
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
                
                // Кнопка регистрации
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Container(
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
                        onPressed: authProvider.isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF019863),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Зарегистрироваться',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Сообщение об ошибке
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.error != null) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                authProvider.error!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Ссылка на вход
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Уже есть аккаунт?',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Войти',
                        style: TextStyle(
                          color: Color(0xFF019863),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
