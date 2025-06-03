import 'package:flutter/material.dart';
import 'package:question_and_answer_edu/database/student_table.dart';
import 'package:question_and_answer_edu/models.dart';
import '../login_user_screen.dart';

class StudentProfileView extends StatefulWidget {
  final String studentCode;

  const StudentProfileView({Key? key, required this.studentCode})
    : super(key: key);

  @override
  State<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView> {
  Student? _student;
  bool _isLoading = true;

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
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_student == null)
      return const Center(child: Text('Không tìm thấy sinh viên.'));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar và tên
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue[50],
                  child: const Icon(Icons.person, size: 50, color: Colors.blue),
                ),
                const SizedBox(height: 16),
                Text(
                  _student!.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Mã SV: ${_student!.studentCode}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Thông tin chi tiết
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

          const SizedBox(height: 30),

          // Nút đăng xuất
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginUserScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
