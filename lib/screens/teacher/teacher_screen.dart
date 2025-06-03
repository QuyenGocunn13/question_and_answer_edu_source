import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Thêm SharedPreferences
import '../teacher/profile_view.dart'; // Import TeacherProfileView

class TeacherScreen extends StatefulWidget {
  final int userId;

  const TeacherScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  int _currentIndex = 0;

  final List<_FeatureCardData> _features = [
    _FeatureCardData('Danh sách yêu cầu', Icons.assignment),
    _FeatureCardData('Hộp thoại giáo viên', Icons.chat),
    _FeatureCardData('Thông tin cá nhân', Icons.person),
    _FeatureCardData('Thông báo', Icons.notifications),
    _FeatureCardData('Tổng quan', Icons.dashboard),
  ];

  Future<void> _logout() async {
    // Xóa trạng thái đăng nhập
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // Xóa userId đã lưu
    // Điều hướng về màn hình đăng nhập
    if (Navigator.canPop(context)) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false, // Xóa toàn bộ stack điều hướng
      );
    }
  }

  void _navigateToScreen(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 2) { // Mục "Thông tin cá nhân"
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeacherProfileView(
            userId: widget.userId,
            onLogout: _logout, // Truyền callback đăng xuất
          ),
        ),
      );
    }
    // Thêm logic cho các mục khác nếu cần
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: _features
              .asMap()
              .entries
              .map((entry) => _FeatureCard(
                    title: entry.value.title,
                    icon: entry.value.icon,
                    onTap: () => _navigateToScreen(entry.key),
                  ))
              .toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: _navigateToScreen,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment), label: 'Yêu cầu'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
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
              Icon(icon, size: 48, color: Colors.indigo),
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