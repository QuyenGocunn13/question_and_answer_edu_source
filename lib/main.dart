// import 'package:flutter/material.dart';
// import 'screens/login_admin_screen.dart';
// import 'screens/login_user_screen.dart';
// import 'screens/admin/student_management.dart';
// import 'screens/admin/teacher_management.dart';
// import 'screens/admin/user_management_view.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Education Support App',
//       theme: ThemeData(primarySwatch: Colors.indigo, fontFamily: 'Roboto'),
//       debugShowCheckedModeBanner: false,
//       initialRoute: '/',
//       routes: {
//         '/': (context) => const RoleSelectionScreen(),
//         '/userManagement': (context) => const UserManagementView(),
//         '/studentManagement': (context) => const StudentManagementView(),
//         '/teacherManagement': (context) => const TeacherManagementView(),
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'screens/login_admin_screen.dart';
import 'screens/login_user_screen.dart';
import 'screens/admin/student_management.dart';
import 'screens/admin/teacher_management.dart';
import 'screens/admin/user_management_view.dart';
import './database/test.dart';  // import file chứa seedSampleData

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await seedSampleData(); // Tạo dữ liệu mẫu trước khi chạy app

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Education Support App',
      theme: ThemeData(primarySwatch: Colors.indigo, fontFamily: 'Roboto'),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const RoleSelectionScreen(),
        '/userManagement': (context) => const UserManagementView(),
        '/studentManagement': (context) => const StudentManagementView(),
        '/teacherManagement': (context) => const TeacherManagementView(),
      },
    );
  }
}


class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'EduReply',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Chào mừng bạn đến hệ thống hỗ trợ học tập',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bạn là ai? Vui lòng chọn vai trò để tiếp tục',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Quản trị viên',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: const Color(
                      0xFF7E9ED9,
                    ), // light blue pastel
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginAdminScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.school, color: Colors.white),
                  label: const Text(
                    'Người dùng (Giảng viên / Sinh viên)',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: const Color(
                      0xFF6BC3B7,
                    ), // light teal pastel
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginUserScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
