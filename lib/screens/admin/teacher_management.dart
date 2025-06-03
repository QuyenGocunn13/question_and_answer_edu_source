import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models.dart';
import '../../database/teacher_table.dart';

class TeacherManagementView extends StatefulWidget {
  final VoidCallback? onBack;

  const TeacherManagementView({Key? key, this.onBack}) : super(key: key);

  @override
  State<TeacherManagementView> createState() => _TeacherManagementViewState();
}

class _TeacherManagementViewState extends State<TeacherManagementView> {
  final TeacherDBHelper _dbHelper = TeacherDBHelper();

  List<Teacher> _teachers = [];
  Teacher? _selectedTeacher;

  final _nameController = TextEditingController();
  Gender _gender = Gender.male;
  DateTime? _dob;
  File? _imageFile;
  bool _isNew = false;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    final list = await _dbHelper.getAllTeachers();
    setState(() {
      _teachers = list;
      if (!_isNew && list.isNotEmpty) _selectTeacher(list[0]);
    });
  }

  void _selectTeacher(Teacher t) {
    _selectedTeacher = t;
    _nameController.text = t.fullName;
    _gender = t.gender;
    _dob = t.dateOfBirth;
    _imageFile =
        (t.profileImage.isNotEmpty && !Uri.parse(t.profileImage).isAbsolute)
            ? File(t.profileImage)
            : null;
    _isNew = false;
    setState(() {});
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 30),
      firstDate: DateTime(1950),
      lastDate: now,
      builder:
          (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF0D47A1), // xanh đậm
                onPrimary: Colors.white,
                onSurface: Colors.black87,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0D47A1),
                ),
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _newTeacher() {
    _selectedTeacher = null;
    _nameController.clear();
    _gender = Gender.male;
    _dob = null;
    _imageFile = null;
    _isNew = true;
    setState(() {});
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập họ và tên')));
      return;
    }

    if (_isNew) {
      final newTeacher = Teacher(
        teacherCode: '',
        userId: 0,
        fullName: name,
        gender: _gender,
        dateOfBirth: _dob ?? DateTime.now(),
        profileImage: _imageFile?.path ?? '',
        isDeleted: false,
      );
      final created = await _dbHelper.insertTeacher(newTeacher);
      if (created != null) {
        await _loadTeachers();
        _selectTeacher(created);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm giáo viên thành công')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lỗi khi tạo giáo viên')));
      }
    } else {
      if (_selectedTeacher == null) return;
      final updated = Teacher(
        teacherCode: _selectedTeacher!.teacherCode,
        userId: _selectedTeacher!.userId,
        fullName: name,
        gender: _gender,
        dateOfBirth: _dob ?? DateTime.now(),
        profileImage: _imageFile?.path ?? _selectedTeacher!.profileImage,
        isDeleted: false,
      );
      await _dbHelper.updateTeacher(updated);
      await _loadTeachers();
      _selectTeacher(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thông tin giáo viên thành công'),
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.w600,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF90A4AE)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
  );

  Widget _buildCreateButton() {
    return SizedBox(
      height: 48,
      child: TextButton.icon(
        onPressed: _newTeacher,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFF0D47A1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          elevation: 2,
        ),
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text(
          'Tạo mới giáo viên',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherList() {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        itemCount: _teachers.length,
        separatorBuilder:
            (_, __) => const Divider(height: 1, color: Color(0xFFE0E0E0)),
        itemBuilder: (context, i) {
          final t = _teachers[i];
          final selected = t.teacherCode == _selectedTeacher?.teacherCode;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: CircleAvatar(
              radius: 24,
              backgroundImage:
                  t.profileImage.isNotEmpty
                      ? (Uri.tryParse(t.profileImage)?.isAbsolute ?? false)
                          ? NetworkImage(t.profileImage)
                          : FileImage(File(t.profileImage)) as ImageProvider
                      : null,
              child:
                  t.profileImage.isEmpty
                      ? const Icon(Icons.person, color: Color(0xFF0D47A1))
                      : null,
              backgroundColor: Colors.grey.shade100,
            ),
            title: Text(
              t.fullName,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              t.teacherCode,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            onTap: () => _selectTeacher(t),
            selected: selected,
            selectedTileColor: Colors.blue.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImage() {
    final imageProvider =
        _imageFile != null
            ? FileImage(_imageFile!)
            : (_selectedTeacher != null &&
                        _selectedTeacher!.profileImage.isNotEmpty
                    ? (Uri.tryParse(
                              _selectedTeacher!.profileImage,
                            )?.isAbsolute ??
                            false)
                        ? NetworkImage(_selectedTeacher!.profileImage)
                        : FileImage(File(_selectedTeacher!.profileImage))
                    : null)
                as ImageProvider<Object>?;

    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade100,
              backgroundImage: imageProvider,
              child:
                  imageProvider == null
                      ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF0D47A1),
                      )
                      : null,
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D47A1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF90A4AE)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<Gender>(
        value: _gender,
        isExpanded: true,
        underline: const SizedBox(),
        iconEnabledColor: const Color(0xFF0D47A1),
        items:
            Gender.values
                .map(
                  (g) => DropdownMenuItem(
                    value: g,
                    child: Text(
                      g.toString().split('.').last.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
        onChanged: (v) {
          if (v != null) setState(() => _gender = v);
        },
      ),
    );
  }

  Widget _buildDobPicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF90A4AE)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _dob == null
                    ? 'Ngày sinh'
                    : '${_dob!.day.toString().padLeft(2, '0')}/'
                        '${_dob!.month.toString().padLeft(2, '0')}/'
                        '${_dob!.year}',
                style: TextStyle(
                  fontSize: 16,
                  color: _dob == null ? Colors.black54 : Colors.black87,
                  fontWeight:
                      _dob == null ? FontWeight.normal : FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.calendar_today, color: Color(0xFF0D47A1)),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D47A1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          'Lưu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _selectedTeacher == null && !_isNew;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Quản trị Giáo viên',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0D47A1)),
        leading:
            widget.onBack == null
                ? null
                : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
                ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCreateButton(),
            const SizedBox(height: 24),
            if (_teachers.isNotEmpty) _buildTeacherList(),
            if (_teachers.isNotEmpty) const SizedBox(height: 24),
            if (isEmpty)
              const Center(
                child: Text(
                  'Chọn giáo viên để xem chi tiết',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              )
            else ...[
              _buildProfileImage(),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration('Họ và tên'),
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              _buildGenderDropdown(),
              const SizedBox(height: 24),
              _buildDobPicker(),
              const SizedBox(height: 44),
              _buildSaveButton(),
            ],
          ],
        ),
      ),
    );
  }
}
