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

  final _fullNameFocus = FocusNode();
  final _placeOfBirthFocus = FocusNode();
  final _classNameFocus = FocusNode();
  final _intakeYearFocus = FocusNode();
  final _majorFocus = FocusNode();

  Gender _selectedGender = Gender.male;
  DateTime? _selectedDateOfBirth;
  File? _pickedImageFile;

  bool _isAddingNew = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _placeOfBirthController.dispose();
    _classNameController.dispose();
    _intakeYearController.dispose();
    _majorController.dispose();
    _fullNameFocus.dispose();
    _placeOfBirthFocus.dispose();
    _classNameFocus.dispose();
    _intakeYearFocus.dispose();
    _majorFocus.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final list = await _dbHelper.getAllStudents();
      print('Loaded students raw: $list'); // Log chi tiết danh sách
      setState(() {
        _students = list ?? [];
        print('Students after setState: $_students'); // Log sau khi gán
        if (_students.isNotEmpty && _selectedStudent == null) {
          _selectStudent(_students[0]);
        }
      });
    } catch (e) {
      print('Error loading students: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không thể tải danh sách sinh viên')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectStudent(Student student) {
    _selectedStudent = student;
    _isAddingNew = false;
    _fullNameController.text = student.fullName ?? '';
    _placeOfBirthController.text = student.placeOfBirth ?? '';
    _classNameController.text = student.className ?? '';
    _intakeYearController.text = (student.intakeYear ?? 0).toString();
    _majorController.text = student.major ?? '';
    _selectedGender = student.gender ?? Gender.male;
    _selectedDateOfBirth = student.dateOfBirth;
    _pickedImageFile =
        student.profileImage.isNotEmpty &&
                !Uri.parse(student.profileImage).isAbsolute
            ? File(student.profileImage)
            : null;
    if (_pickedImageFile != null && !_pickedImageFile!.existsSync()) {
      print('Image file does not exist: ${student.profileImage}');
      _pickedImageFile = null;
    }
    setState(() {});
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      if (await file.exists()) {
        setState(() => _pickedImageFile = file);
      } else {
        print('Picked image file does not exist: ${pickedFile.path}');
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_fullNameController.text.trim().isEmpty ||
        _placeOfBirthController.text.trim().isEmpty ||
        _classNameController.text.trim().isEmpty ||
        _majorController.text.trim().isEmpty ||
        _selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ các trường bắt buộc'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_selectedStudent == null) {
        final newStudentData = Student(
          studentCode: '',
          userId: 0,
          fullName: _fullNameController.text.trim(),
          gender: _selectedGender,
          dateOfBirth: _selectedDateOfBirth!,
          placeOfBirth: _placeOfBirthController.text.trim(),
          className: _classNameController.text.trim(),
          intakeYear: int.tryParse(_intakeYearController.text.trim()) ?? 0,
          major: _majorController.text.trim(),
          profileImage: _pickedImageFile?.path ?? '',
          isDeleted: false,
        );

        print('New student data: $newStudentData'); // Log dữ liệu sinh viên mới
        final inserted = await _dbHelper.insertStudent(newStudentData);
        print('Inserted student: $inserted'); // Log kết quả từ insertStudent
        if (inserted == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lỗi: Không thể thêm sinh viên')),
          );
          return;
        }
        await _loadStudents();
        if (inserted != null) {
          _selectStudent(inserted);
        }
      } else {
        final updatedStudent = Student(
          studentCode: _selectedStudent!.studentCode,
          userId: _selectedStudent!.userId,
          fullName: _fullNameController.text.trim(),
          gender: _selectedGender,
          dateOfBirth: _selectedDateOfBirth!,
          placeOfBirth: _placeOfBirthController.text.trim(),
          className: _classNameController.text.trim(),
          intakeYear: int.tryParse(_intakeYearController.text.trim()) ?? 0,
          major: _majorController.text.trim(),
          profileImage:
              _pickedImageFile?.path ?? _selectedStudent!.profileImage,
          isDeleted: false,
        );

        final updated = await _dbHelper.updateStudent(updatedStudent);
        if (updated == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lỗi: Không thể cập nhật sinh viên')),
          );
          return;
        }
        await _loadStudents();
        _selectStudent(updatedStudent);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu thông tin sinh viên')),
      );
      setState(() => _isAddingNew = false);
    } catch (e) {
      print('Error saving changes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không thể lưu thông tin')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = _selectedDateOfBirth ?? DateTime(now.year - 18);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: now,
      builder:
          (context, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.teal,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null) setState(() => _selectedDateOfBirth = picked);
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    FocusNode? focusNode,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.teal),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(focusNode);
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<Gender>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Giới tính',
        labelStyle: const TextStyle(color: Colors.teal),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items:
          Gender.values.map((gender) {
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
            labelStyle: const TextStyle(color: Colors.teal),
            filled: true,
            fillColor: Colors.grey[100],
            suffixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.teal,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.teal, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          controller: TextEditingController(
            text:
                _selectedDateOfBirth == null
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
        gradient: const LinearGradient(
          colors: [Colors.teal, Colors.tealAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Danh sách sinh viên',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.person_add, size: 20),
                label: const Text(
                  'Thêm sinh viên',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
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
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      FocusScope.of(context).requestFocus(_fullNameFocus);
                    });
                  });
                },
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text(
                  'Làm mới',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                onPressed: _loadStudents,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                    : _students.isEmpty
                    ? const Center(
                      child: Text(
                        'Không có sinh viên nào',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    )
                    : ListView.separated(
                      itemCount: _students.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        final isSelected =
                            _selectedStudent?.studentCode ==
                            student.studentCode;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 200),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    student.profileImage.isNotEmpty &&
                                            File(
                                              student.profileImage,
                                            ).existsSync()
                                        ? FileImage(File(student.profileImage))
                                        : null,
                                child:
                                    student.profileImage.isEmpty
                                        ? const Icon(
                                          Icons.person_outline,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                        : null,
                              ),
                              title: Text(
                                student.fullName ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                'Mã SV: ${student.studentCode ?? ''}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              onTap: () => _selectStudent(student),
                            ),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        _pickedImageFile != null &&
                                _pickedImageFile!.existsSync()
                            ? FileImage(_pickedImageFile!)
                            : (_selectedStudent != null &&
                                    _selectedStudent!.profileImage.isNotEmpty &&
                                    File(
                                      _selectedStudent!.profileImage,
                                    ).existsSync()
                                ? FileImage(
                                  File(_selectedStudent!.profileImage),
                                )
                                : null),
                    child:
                        _pickedImageFile == null &&
                                (_selectedStudent == null ||
                                    _selectedStudent!.profileImage.isEmpty)
                            ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.teal,
                            )
                            : null,
                    backgroundColor: Colors.grey[200],
                  ),
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.teal,
                      child: Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              _fullNameController,
              'Họ và tên',
              focusNode: _fullNameFocus,
            ),
            const SizedBox(height: 16),
            _buildGenderDropdown(),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 16),
            _buildTextField(
              _placeOfBirthController,
              'Nơi sinh',
              focusNode: _placeOfBirthFocus,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _classNameController,
              'Lớp',
              focusNode: _classNameFocus,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _intakeYearController,
              'Niên khóa',
              isNumber: true,
              focusNode: _intakeYearFocus,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _majorController,
              'Chuyên ngành',
              focusNode: _majorFocus,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text(
                      'Lưu',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed:
                        _isLoading
                            ? null
                            : () async {
                              await _saveChanges();
                            },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text(
                      'Hủy',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      side: const BorderSide(color: Colors.teal),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building with students: ${_students.length}');
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading:
            widget.onBack != null
                ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: widget.onBack,
                )
                : null,
        title: const Text(
          'Quản lý sinh viên',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 300, child: _buildStudentList()),
                    const SizedBox(height: 24),
                    (_selectedStudent != null || _isAddingNew)
                        ? _buildDetailForm()
                        : const Center(
                          child: Text(
                            'Chọn sinh viên hoặc nhấn "Thêm sinh viên"',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                  ],
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildStudentList()),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child:
                        (_selectedStudent != null || _isAddingNew)
                            ? _buildDetailForm()
                            : const Center(
                              child: Text(
                                'Chọn sinh viên hoặc nhấn "Thêm sinh viên"',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
