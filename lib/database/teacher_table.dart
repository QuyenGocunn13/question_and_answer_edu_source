import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:math';
import '../models.dart';
import 'account_table.dart';

class TeacherDBHelper {
  static final TeacherDBHelper _instance = TeacherDBHelper._internal();

  factory TeacherDBHelper() => _instance;

  TeacherDBHelper._internal();

  Future<Database> get database async {
    return await DBHelper().database;
  }

  String generateTeacherCode() {
    final random = Random();
    int randomNumber = random.nextInt(10000);
    String fourDigits = randomNumber.toString().padLeft(4, '0');
    return '3001$fourDigits';
  }

  Future<bool> isTeacherCodeExists(String code) async {
    final db = await database;
    final result = await db.query(
      'teachers',
      where: 'teacherCode = ?',
      whereArgs: [code],
    );
    return result.isNotEmpty;
  }

  Future<Teacher?> insertTeacher(Teacher teacher) async {
    final db = await database;
    final dbHelper = DBHelper();

    try {
      if (teacher.fullName.isEmpty || teacher.dateOfBirth == null) {
        throw Exception('Các trường bắt buộc không được để trống');
      }

      String teacherCode;
      do {
        teacherCode = generateTeacherCode();
      } while (await isTeacherCodeExists(teacherCode));

      final account = Account(
        userId: 0,
        username: teacherCode,
        password: 'huit$teacherCode',
        role: UserRole.teacher,
        isDeleted: false,
      );

      int newUserId = await dbHelper.insertAccount(account);
      if (newUserId <= 0) {
        throw Exception('Không thể tạo tài khoản, userId: $newUserId');
      }

      final newTeacher = Teacher(
        userId: newUserId,
        teacherCode: teacherCode,
        fullName: teacher.fullName,
        gender: teacher.gender,
        dateOfBirth: teacher.dateOfBirth,
        profileImage: teacher.profileImage.isEmpty ? '' : teacher.profileImage,
        isDeleted: false,
      );

      await db.insert('teachers', {
        'teacherCode': newTeacher.teacherCode,
        'userId': newUserId,
        'fullName': newTeacher.fullName,
        'gender': newTeacher.gender.toString().split('.').last,
        'dateOfBirth': newTeacher.dateOfBirth.toIso8601String(),
        'profileImage': newTeacher.profileImage,
        'isDeleted': 0,
      }, conflictAlgorithm: ConflictAlgorithm.fail);

      print("Teacher created:");
      print("TeacherCode: ${newTeacher.teacherCode}");
      print("Username: ${account.username}");
      print("Password: ${account.password}");
      print("UserId: ${newTeacher.userId}");
      print("FullName: ${newTeacher.fullName}");

      return newTeacher;
    } catch (e) {
      throw Exception('Lỗi khi tạo teacher/account: $e');
    }
  }

  Future<Teacher?> getTeacherByCode(String teacherCode) async {
    final db = await database;
    try {
      final maps = await db.query(
        'teachers',
        where: 'teacherCode = ? AND isDeleted = 0',
        whereArgs: [teacherCode],
      );

      if (maps.isNotEmpty) {
        final data = maps.first;
        return Teacher(
          userId: data['userId'] as int,
          teacherCode: data['teacherCode'] as String,
          fullName: data['fullName'] as String,
          gender: Gender.values.firstWhere(
            (e) => e.toString().split('.').last == data['gender'],
            orElse: () => Gender.male,
          ),
          dateOfBirth: DateTime.parse(data['dateOfBirth'] as String),
          profileImage: data['profileImage'] as String? ?? '',
          isDeleted: (data['isDeleted'] as int) == 1,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin giáo viên theo teacherCode: $e');
    }
  }

  Future<Teacher?> getTeacherByUserId(int userId) async {
    final db = await database;
    final maps = await db.query(
      'teachers',
      where: 'userId = ? AND isDeleted = 0',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      final data = maps.first;
      return Teacher(
        userId: data['userId'] as int,
        teacherCode: data['teacherCode'] as String,
        fullName: data['fullName'] as String,
        gender: Gender.values.firstWhere(
          (e) => e.toString().split('.').last == data['gender'],
        ),
        dateOfBirth: DateTime.parse(data['dateOfBirth'] as String),
        profileImage: data['profileImage'] as String? ?? '',
        isDeleted: (data['isDeleted'] as int) == 1,
      );
    }
    return null;
  }

  Future<int> updateTeacher(Teacher teacher) async {
    final db = await database;
    try {
      return await db.update(
        'teachers',
        {
          'fullName': teacher.fullName,
          'gender': teacher.gender.toString().split('.').last,
          'dateOfBirth': teacher.dateOfBirth.toIso8601String(),
          'profileImage': teacher.profileImage,
          'isDeleted': teacher.isDeleted ? 1 : 0,
        },
        where: 'userId = ?',
        whereArgs: [teacher.userId],
      );
    } catch (e) {
      throw Exception('Lỗi khi cập nhật giáo viên: $e');
    }
  }

  Future<int> softDeleteTeacher(String teacherCode) async {
    final db = await database;
    try {
      return await db.update(
        'teachers',
        {'isDeleted': 1},
        where: 'teacherCode = ?',
        whereArgs: [teacherCode],
      );
    } catch (e) {
      throw Exception('Lỗi khi xóa mềm giáo viên: $e');
    }
  }

  Future<List<Teacher>> getAllTeachers() async {
    final db = await database;
    try {
      final maps = await db.query('teachers', where: 'isDeleted = 0');
      print('Teachers: $maps');
      return List.generate(maps.length, (i) {
        final data = maps[i];
        return Teacher(
          userId: data['userId'] as int,
          teacherCode: data['teacherCode'] as String,
          fullName: data['fullName'] as String,
          gender: Gender.values.firstWhere(
            (e) => e.toString().split('.').last == data['gender'],
            orElse: () => Gender.male,
          ),
          dateOfBirth: DateTime.parse(data['dateOfBirth'] as String),
          profileImage: data['profileImage'] as String? ?? '',
          isDeleted: (data['isDeleted'] as int) == 1,
        );
      });
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách giáo viên: $e');
    }
  }
}
