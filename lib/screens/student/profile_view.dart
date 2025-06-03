import 'package:flutter/material.dart';
import 'package:question_and_answer_edu/database/student_table.dart';
import 'package:question_and_answer_edu/models.dart';

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

    if (_student == null) {
      return const Center(child: Text('Không tìm thấy sinh viên.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar và tên
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
            style: const TextStyle(fontSize: 16, color: Colors.grey),
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
