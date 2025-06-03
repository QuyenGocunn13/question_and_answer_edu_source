import 'package:flutter/material.dart';
import 'package:question_and_answer_edu/screens/student/dashboard_view.dart';
import 'package:question_and_answer_edu/screens/student/profile_view.dart';
import 'new_question_form.dart';

class StudentScreen extends StatefulWidget {
  final String studentCode;
  const StudentScreen({Key? key, required this.studentCode}) : super(key: key);
  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  int _currentIndex = 0;

  final List<_FeatureCardData> _features = [
    _FeatureCardData('Tổng quan', Icons.dashboard),
    _FeatureCardData('Câu hỏi thường gặp', Icons.help_outline),
    _FeatureCardData('Đặt câu hỏi mới', Icons.edit_note),
    _FeatureCardData('Tải biểu mẫu', Icons.file_download),
    _FeatureCardData('Thông tin cá nhân', Icons.person),
    _FeatureCardData('Hộp thoại', Icons.chat),
    _FeatureCardData('Thông báo', Icons.notifications),
    _FeatureCardData('Cài đặt', Icons.settings),
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      StudentDashboardView(studentCode: widget.studentCode), // Truyền studentCode
      const Center(child: Text('FAQ Page')),
      StudentProfileView(studentCode: widget.studentCode),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: _pages[_currentIndex], // ✅ sử dụng tab hiện tại
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2C3E50),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'FAQ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}


class _FeatureCardData {
  final String title;
  final IconData icon;

  const _FeatureCardData(this.title, this.icon);
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Color(0xFF2C3E50)),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
