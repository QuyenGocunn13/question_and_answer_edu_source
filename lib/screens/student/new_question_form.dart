import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class NewQuestionForm extends StatefulWidget {
  const NewQuestionForm({Key? key}) : super(key: key);

  @override
  State<NewQuestionForm> createState() => _NewQuestionFormState();
}

class _NewQuestionFormState extends State<NewQuestionForm> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final List<String> _categories = ['Học tập', 'Học phí', 'Thủ tục hành chính'];
  String? _selectedCategory;
  bool _selectTeacher = false;
  String? _selectedTeacher;
  File? _attachedFile;

  final List<String> _teachers = [
    'Thầy Nguyễn Văn A',
    'Cô Trần Thị B',
    'Thầy Lê Văn C',
  ];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result != null && result.files.single.size <= 5 * 1024 * 1024) {
      setState(() {
        _attachedFile = File(result.files.single.path!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File vượt quá dung lượng cho phép (5MB).')),
      );
    }
  }

  void _submitQuestion() {
    if (_selectedCategory == null ||
        _titleController.text.isEmpty ||
        _contentController.text.isEmpty ||
        (_selectTeacher && _selectedTeacher == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    // Xử lý gửi câu hỏi và tạo đoạn chat mới ở đây
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi câu hỏi thành công')),
    );

    // Clear form
    setState(() {
      _selectedCategory = null;
      _titleController.clear();
      _contentController.clear();
      _selectTeacher = false;
      _selectedTeacher = null;
      _attachedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Câu Hỏi Mới'),
        backgroundColor: const Color(0xFF2C3E50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Loại câu hỏi', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 16),

            const Text('Tiêu đề', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            const Text('Nội dung', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            CheckboxListTile(
              title: const Text('Chọn giáo viên để hỏi'),
              value: _selectTeacher,
              onChanged: (val) => setState(() => _selectTeacher = val!),
            ),
            if (_selectTeacher)
              DropdownButtonFormField<String>(
                value: _selectedTeacher,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _teachers.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _selectedTeacher = val),
              ),
            const SizedBox(height: 16),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Đính kèm tệp'),
                ),
                const SizedBox(width: 12),
                if (_attachedFile != null)
                  Expanded(child: Text('Tệp: ${_attachedFile!.path.split('/').last}')),
              ],
            ),
            const SizedBox(height: 24),

            Center(
              child: ElevatedButton(
                onPressed: _submitQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Gửi Câu Hỏi', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
