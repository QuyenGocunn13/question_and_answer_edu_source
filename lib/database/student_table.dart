import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:math';
import '../models.dart';
import 'account_table.dart';

class StudentDBHelper {
  static final StudentDBHelper _instance = StudentDBHelper._internal();

  factory StudentDBHelper() => _instance;

  StudentDBHelper._internal();

  Future<Database> get database async {
    return await DBHelper().database;
  }

  String generateStudentCode() {
    final random = Random();
    int randomNumber = random.nextInt(10000);
    String fourDigits = randomNumber.toString().padLeft(4, '0');
    return '2001$fourDigits';
  }

  Future<bool> isStudentCodeExists(String code) async {
    final db = await database;
    final result = await db.query(
      'students',
      where: 'studentCode = ?',
      whereArgs: [code],
    );
    return result.isNotEmpty;
  }

  Future<Student?> insertStudent(Student student) async {
    final db = await database;
    final dbHelper = DBHelper();

    try {
      if (student.fullName.isEmpty ||
          student.placeOfBirth.isEmpty ||
          student.className.isEmpty ||
          student.major.isEmpty ||
          student.dateOfBirth == null) {
        print('Lỗi: Các trường bắt buộc không được để trống');
        return null;
      }

      String studentCode;
      do {
        studentCode = generateStudentCode();
      } while (await isStudentCodeExists(studentCode));

      final account = Account(
        userId: 0,
        username: studentCode,
        password: 'huit$studentCode',
        role: UserRole.student,
        isDeleted: false,
      );

      int newUserId = await dbHelper.insertAccount(account);
      if (newUserId <= 0) {
        print('Lỗi: Không thể tạo tài khoản, userId: $newUserId');
        return null;
      }

      final newStudent = Student(
        userId: newUserId,
        studentCode: studentCode,
        fullName: student.fullName,
        gender: student.gender,
        dateOfBirth: student.dateOfBirth,
        placeOfBirth: student.placeOfBirth,
        className: student.className,
        intakeYear: student.intakeYear,
        major: student.major,
        profileImage: student.profileImage.isEmpty ? '' : student.profileImage,
        isDeleted: false,
      );

      await db.insert('students', {
        'studentCode': newStudent.studentCode,
        'userId': newUserId,
        'fullName': newStudent.fullName,
        'gender': newStudent.gender.toString().split('.').last,
        'dateOfBirth': newStudent.dateOfBirth.toIso8601String(),
        'placeOfBirth': newStudent.placeOfBirth,
        'className': newStudent.className,
        'intakeYear': newStudent.intakeYear,
        'major': newStudent.major,
        'profileImage': newStudent.profileImage,
        'isDeleted': 0,
      }, conflictAlgorithm: ConflictAlgorithm.fail);

      print("Student created:");
      print("StudentCode: ${newStudent.studentCode}");
      print("Username: ${account.username}");
      print("Password: ${account.password}");
      print("UserId: ${newStudent.userId}");
      print("FullName: ${newStudent.fullName}");

      return newStudent;
    } catch (e) {
      print('Lỗi khi tạo student/account: $e');
      return null;
    }
  }

  Future<Student?> getStudentByCode(String studentCode) async {
    final db = await database;
    final maps = await db.query(
      'students',
      where: 'studentCode = ? AND isDeleted = 0',
      whereArgs: [studentCode],
    );

    if (maps.isNotEmpty) {
      final data = maps.first;
      return Student(
        userId: data['userId'] as int,
        studentCode: data['studentCode'] as String,
        fullName: data['fullName'] as String,
        gender: Gender.values.firstWhere(
          (e) => e.toString().split('.').last == data['gender'],
          orElse: () => Gender.male,
        ),
        dateOfBirth: DateTime.parse(data['dateOfBirth'] as String),
        placeOfBirth: data['placeOfBirth'] as String,
        className: data['className'] as String,
        intakeYear: data['intakeYear'] as int,
        major: data['major'] as String,
        profileImage: data['profileImage'] as String,
        isDeleted: (data['isDeleted'] as int) == 1,
      );
    }
    return null;
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    try {
      return await db.update(
        'students',
        {
          'userId': student.userId,
          'fullName': student.fullName,
          'gender': student.gender.toString().split('.').last,
          'dateOfBirth': student.dateOfBirth.toIso8601String(),
          'placeOfBirth': student.placeOfBirth,
          'className': student.className,
          'intakeYear': student.intakeYear,
          'major': student.major,
          'profileImage': student.profileImage,
          'isDeleted': student.isDeleted ? 1 : 0,
        },
        where: 'studentCode = ?',
        whereArgs: [student.studentCode],
      );
    } catch (e) {
      print('Lỗi khi cập nhật sinh viên: $e');
      return 0;
    }
  }

  Future<int> softDeleteStudent(String studentCode) async {
    final db = await database;
    try {
      return await db.update(
        'students',
        {'isDeleted': 1}, // Sửa từ false thành 1
        where: 'studentCode = ?',
        whereArgs: [studentCode],
      );
    } catch (e) {
      print('Lỗi khi xóa mềm sinh viên: $e');
      return 0;
    }
  }

  Future<List<Student>> getAllStudents() async {
    final db = await database;
    try {
      final maps = await db.query('students', where: 'isDeleted = 0');
      print('Students: $maps');
      return List.generate(maps.length, (i) {
        final data = maps[i];
        return Student(
          userId: data['userId'] as int,
          studentCode: data['studentCode'] as String,
          fullName: data['fullName'] as String,
          gender: Gender.values.firstWhere(
            (e) => e.toString().split('.').last == data['gender'],
            orElse: () => Gender.male,
          ),
          dateOfBirth: DateTime.parse(data['dateOfBirth'] as String),
          placeOfBirth: data['placeOfBirth'] as String,
          className: data['className'] as String,
          intakeYear: data['intakeYear'] as int,
          major: data['major'] as String,
          profileImage: data['profileImage'] as String,
          isDeleted: (data['isDeleted'] as int) == 1,
        );
      });
    } catch (e) {
      print('Lỗi khi lấy danh sách sinh viên: $e');
      return [];
    }
  }
}
