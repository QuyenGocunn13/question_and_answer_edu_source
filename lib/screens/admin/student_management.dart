import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models.dart';
import '../../database/student_table.dart';

class StudentManagementView extends StatefulWidget {
  final VoidCallback? onBack;

  const StudentManagementView({Key? key, this.onBack}) : super(key: key);

  @override
  State<StudentManagementView> createState() => _StudentManagementViewState();
}

class _StudentManagementViewState extends State<StudentManagementView> {
  final StudentDBHelper _dbHelper = StudentDBHelper();
  List<Student> _students = [];
  Student? _selectedStudent;

  final _fullNameController = TextEditingController();
  final _placeOfBirthController = TextEditingController();
  final _classNameController = TextEditingController();
  final _intakeYearController = TextEditingController();
  final _majorController = TextEditingController();

  Gender _selectedGender = Gender.male;
  DateTime? _selectedDateOfBirth;
  File? _pickedImageFile;

  bool _isAddingNew = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final list = await _dbHelper.getAllStudents();
    setState(() {
      _students = list;
      if (list.isNotEmpty) _selectStudent(list[0]);
    });
  }

  void _selectStudent(Student student) {
    _selectedStudent = student;
    _isAddingNew = false;
    _fullNameController.text = student.fullName;
    _placeOfBirthController.text = student.placeOfBirth;
    _classNameController.text = student.className;
    _intakeYearController.text = student.intakeYear.toString();
    _majorController.text = student.major;
    _selectedGender = student.gender;
    _selectedDateOfBirth = student.dateOfBirth;
    _pickedImageFile =
        student.profileImage.isNotEmpty && !Uri.parse(student.profileImage).isAbsolute
            ? File(student.profileImage)
            : null;
    setState(() {});
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_fullNameController.text.trim().isEmpty) return;

    if (_selectedStudent == null) {
      final newStudentData = Student(
        studentCode: '',
        userId: 0,
        fullName: _fullNameController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _selectedDateOfBirth ?? DateTime.now(),
        placeOfBirth: _placeOfBirthController.text.trim(),
        className: _classNameController.text.trim(),
        intakeYear: int.tryParse(_intakeYearController.text.trim()) ?? 0,
        major: _majorController.text.trim(),
        profileImage: _pickedImageFile?.path ?? '',
        isDeleted: false,
      );

      final inserted = await _dbHelper.insertStudent(newStudentData);

      if (inserted != null) {
        await _loadStudents();
        _selectStudent(inserted);
      }
    } else {
      final updatedStudent = Student(
        studentCode: _selectedStudent!.studentCode,
        userId: _selectedStudent!.userId,
        fullName: _fullNameController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _selectedDateOfBirth ?? DateTime.now(),
        placeOfBirth: _placeOfBirthController.text.trim(),
        className: _classNameController.text.trim(),
        intakeYear: int.tryParse(_intakeYearController.text.trim()) ?? 0,
        major: _majorController.text.trim(),
        profileImage: _pickedImageFile?.path ?? _selectedStudent!.profileImage,
        isDeleted: false,
      );

      await _dbHelper.updateStudent(updatedStudent);
      await _loadStudents();
      _selectStudent(updatedStudent);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu thông tin sinh viên')),
    );
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = _selectedDateOfBirth ?? DateTime(now.year - 18);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) setState(() => _selectedDateOfBirth = picked);
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<Gender>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Giới tính',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: Gender.values.map((gender) {
        final text = gender.toString().split('.').last;
        return DropdownMenuItem<Gender>(
          value: gender,
          child: Text(text[0].toUpperCase() + text.substring(1)),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedGender = val);
      },
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDateOfBirth,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Ngày sinh',
            suffixIcon: const Icon(Icons.calendar_today_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          controller: TextEditingController(
            text: _selectedDateOfBirth == null
                ? ''
                : '${_selectedDateOfBirth!.day.toString().padLeft(2, '0')}/${_selectedDateOfBirth!.month.toString().padLeft(2, '0')}/${_selectedDateOfBirth!.year}',
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Danh sách sinh viên",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.person_add),
            label: const Text('Thêm sinh viên'),
            onPressed: () {
              setState(() {
                _isAddingNew = true;
                _selectedStudent = null;
                _fullNameController.clear();
                _placeOfBirthController.clear();
                _classNameController.clear();
                _intakeYearController.clear();
                _majorController.clear();
                _pickedImageFile = null;
                _selectedGender = Gender.male;
                _selectedDateOfBirth = null;
              });
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final student = _students[index];
                final isSelected = _selectedStudent?.studentCode == student.studentCode;
                return Material(
                  color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: student.profileImage.isNotEmpty
                          ? FileImage(File(student.profileImage))
                          : null,
                      child: student.profileImage.isEmpty ? const Icon(Icons.person_outline) : null,
                    ),
                    title: Text(student.fullName,
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Mã SV: ${student.studentCode}'),
                    onTap: () => _selectStudent(student),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _pickedImageFile != null
                    ? FileImage(_pickedImageFile!)
                    : (_selectedStudent != null && _selectedStudent!.profileImage.isNotEmpty
                        ? FileImage(File(_selectedStudent!.profileImage))
                        : null),
                child: _pickedImageFile == null &&
                        (_selectedStudent == null || _selectedStudent!.profileImage.isEmpty)
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(_fullNameController, 'Họ và tên'),
            const SizedBox(height: 16),
            _buildGenderDropdown(),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 16),
            _buildTextField(_placeOfBirthController, 'Nơi sinh'),
            const SizedBox(height: 16),
            _buildTextField(_classNameController, 'Lớp'),
            const SizedBox(height: 16),
            _buildTextField(_intakeYearController, 'Niên khóa', isNumber: true),
            const SizedBox(height: 16),
            _buildTextField(_majorController, 'Chuyên ngành'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Lưu'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      await _saveChanges();
                      setState(() {
                        _isAddingNew = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('Hủy'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      setState(() {
                        _isAddingNew = false;
                        _selectedStudent = null;
                        _fullNameController.clear();
                        _placeOfBirthController.clear();
                        _classNameController.clear();
                        _intakeYearController.clear();
                        _majorController.clear();
                        _pickedImageFile = null;
                        _selectedGender = Gender.male;
                        _selectedDateOfBirth = null;
                      });
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: const Text('Quản lý sinh viên'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(flex: 2, child: _buildStudentList()),
            const SizedBox(width: 24),
            Expanded(
              flex: 3,
              child: (_selectedStudent != null || _isAddingNew)
                  ? _buildDetailForm()
                  : Center(
                      child: Text(
                        'Chọn sinh viên hoặc nhấn "Thêm sinh viên"',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
