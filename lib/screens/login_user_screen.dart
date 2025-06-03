import 'package:flutter/material.dart';
import 'teacher/teacher_screen.dart';
import 'student/student_screen.dart';

class LoginUserScreen extends StatefulWidget {
  const LoginUserScreen({super.key});

  @override
  State<LoginUserScreen> createState() => _LoginUserScreenState();
}

class _LoginUserScreenState extends State<LoginUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';
  String? _errorMessage;

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_email == 'student@example.com' && _password == '123456') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StudentScreen()),
      );
    } else if (_email == 'teacher@example.com' && _password == '123456') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TeacherScreen()),
      );
    } else {
      setState(() {
        _errorMessage = 'Tài khoản không đúng';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              const Icon(Icons.school, size: 100, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'Đăng nhập Người dùng',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email),
                        labelText: 'Email',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) =>
                          (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
                      onSaved: (v) => _email = v!.trim(),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        labelText: 'Mật khẩu',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Mật khẩu tối thiểu 6 ký tự'
                          : null,
                      onSaved: (v) => _password = v!.trim(),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Đăng nhập', style: TextStyle(fontSize: 16)),
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
}
