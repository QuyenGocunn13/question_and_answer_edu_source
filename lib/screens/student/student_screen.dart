import 'package:flutter/material.dart';
import 'package:question_and_answer_edu/database/student_table.dart';
import 'package:question_and_answer_edu/models.dart';
import 'new_question_form.dart';
import 'profile_view.dart'; // Đảm bảo bạn đã import

class StudentScreen extends StatefulWidget {
  final String studentCode;
  const StudentScreen({Key? key, required this.studentCode}) : super(key: key);

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  int _currentIndex = 0;
  Student? _student;
  bool _isLoading = true;

  final List<_FeatureCardData> _features = const [
    _FeatureCardData('Tổng quan', Icons.dashboard),
    _FeatureCardData('Câu hỏi thường gặp', Icons.help_outline),
    _FeatureCardData('Đặt câu hỏi mới', Icons.edit_note),
    _FeatureCardData('Tải biểu mẫu', Icons.file_download),
    _FeatureCardData('Thông tin cá nhân', Icons.person),
    _FeatureCardData('Hộp thoại', Icons.chat),
    _FeatureCardData('Thông báo', Icons.notifications),
    _FeatureCardData('Cài đặt', Icons.settings),
  ];

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    final db = StudentDBHelper();
    final student = await db.getStudentByCode(widget.studentCode);
    setState(() {
      _student = student;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [
      _buildDashboardView(),
      const Center(child: Text('FAQ đang phát triển')),
      StudentProfileView(
        studentCode: widget.studentCode,
      ), // ✅ gọi đúng file chứa nút "Đăng xuất"
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: pages[_currentIndex],
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
          BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: 'FAQ'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }

  Widget _buildDashboardView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào, ${_student?.fullName ?? "Sinh viên"}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children:
                  _features.map((feature) {
                    return _FeatureCard(
                      title: feature.title,
                      icon: feature.icon,
                      onTap: () {
                        if (feature.title == 'Đặt câu hỏi mới') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NewQuestionForm(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Chức năng "${feature.title}" đang phát triển.',
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    if (_student == null) {
      return const Center(child: Text('Không tìm thấy sinh viên.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue[100],
            child: Icon(Icons.person, size: 50, color: Colors.blue[800]),
          ),
          const SizedBox(height: 16),
          Text(
            _student!.fullName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            'Mã SV: ${_student!.studentCode}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(Icons.class_, 'Lớp', _student!.className),
          _buildInfoCard(Icons.school, 'Ngành', _student!.major),
          _buildInfoCard(
            Icons.location_city,
            'Nơi sinh',
            _student!.placeOfBirth,
          ),
          _buildInfoCard(
            Icons.calendar_today,
            'Ngày sinh',
            _student!.dateOfBirth.toLocal().toString().split(' ')[0],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[800]),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
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
              Icon(icon, size: 48, color: const Color(0xFF2C3E50)),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
