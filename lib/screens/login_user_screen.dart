import 'package:flutter/material.dart';
import 'package:question_and_answer_edu/database/student_table.dart';
import 'teacher/teacher_screen.dart';
import 'student/student_screen.dart';
import '../database/account_table.dart';
import '../../models.dart';

class LoginUserScreen extends StatefulWidget {
  const LoginUserScreen({super.key});

  @override
  State<LoginUserScreen> createState() => _LoginUserScreenState();
}

class _LoginUserScreenState extends State<LoginUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '', _password = '';
  String? _errorMessage;
  final DBHelper _dbHelper = DBHelper();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final accounts = await _dbHelper.getAllAccounts();
    final account = accounts.firstWhere(
      (acc) =>
          acc.username == _username &&
          acc.password == _password &&
          !acc.isDeleted,
      orElse:
          () => Account(
            userId: 0,
            username: '',
            password: '',
            role: UserRole.student,
            isDeleted: true,
          ),
    );

    if (account.username.isNotEmpty) {
      if (account.role == UserRole.student) {
        final studentDb = StudentDBHelper();
        final student = await studentDb.getStudentByCode(account.username);
        if (student != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StudentScreen(studentCode: student.studentCode),
            ),
          );
        } else {
          setState(() {
            _errorMessage =
                'Không tìm thấy sinh viên với mã: ${account.username}';
          });
        }
      } else if (account.role == UserRole.teacher) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TeacherScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Sai tên đăng nhập hoặc mật khẩu';
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
                        prefixIcon: const Icon(Icons.person),
                        labelText: 'Tên đăng nhập',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator:
                          (v) =>
                              (v == null || v.isEmpty)
                                  ? 'Vui lòng nhập tên đăng nhập'
                                  : null,
                      onSaved: (v) => _username = v!.trim(),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        labelText: 'Mật khẩu',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator:
                          (v) =>
                              (v == null || v.length < 6)
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(fontSize: 16),
                        ),
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
