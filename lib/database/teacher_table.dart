import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:math';
import '../models.dart';
import 'account_table.dart';

class TeacherDBHelper {
  static final TeacherDBHelper _instance = TeacherDBHelper._internal();

  factory TeacherDBHelper() => _instance;

  TeacherDBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE teachers (
        teacherCode TEXT PRIMARY KEY,
        userId INTEGER NOT NULL,
        fullName TEXT NOT NULL,
        gender TEXT NOT NULL,
        dateOfBirth TEXT NOT NULL,
        profileImage TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES accounts(userId) ON DELETE CASCADE ON UPDATE NO ACTION
      )
    ''');
  }

  // Tạo teacherCode dạng "3001" + 4 số random
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
      String teacherCode;

      // Lặp tạo teacherCode cho đến khi không bị trùng
      do {
        teacherCode = generateTeacherCode();
      } while (await isTeacherCodeExists(teacherCode));

      // Tạo tài khoản sử dụng teacherCode làm username
      final account = Account(
        userId: 0,
        username: teacherCode,
        password: 'huit$teacherCode',
        role: UserRole.teacher,
        isDeleted: false,
      );

      // Lưu account vào DB và lấy userId
      int newUserId = await dbHelper.insertAccount(account);

      // Tạo đối tượng Teacher mới
      final newTeacher = Teacher(
        userId: newUserId,
        teacherCode: teacherCode,
        fullName: teacher.fullName,
        gender: teacher.gender,
        dateOfBirth: teacher.dateOfBirth,
        profileImage: teacher.profileImage,
        isDeleted: false,
      );

      // Lưu Teacher vào DB
      await db.insert('teachers', {
        'teacherCode': newTeacher.teacherCode,
        'userId': newTeacher.userId,
        'fullName': newTeacher.fullName,
        'gender': newTeacher.gender.toString().split('.').last,
        'dateOfBirth': newTeacher.dateOfBirth.toIso8601String(),
        'profileImage': newTeacher.profileImage,
        'isDeleted': 0,
      });

      print("===> Teacher created:");
      print("TeacherCode: ${newTeacher.teacherCode}");
      print("Username: ${account.username}");
      print("Password: ${account.password}");
      print("UserId: ${newTeacher.userId}");
      print("FullName: ${newTeacher.fullName}");

      return newTeacher;
    } catch (e) {
      print('Lỗi khi tạo teacher/account: $e');
      return null;
    }
  }

  Future<Teacher?> getTeacherByCode(String teacherCode) async {
    final db = await database;
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
        ),
        dateOfBirth: DateTime.parse(data['dateOfBirth'] as String),
        profileImage: data['profileImage'] as String,
        isDeleted: (data['isDeleted'] as int) == 1,
      );
    }
    return null;
  }

  Future<int> updateTeacher(Teacher teacher) async {
    final db = await database;
    return await db.update(
      'teachers',
      {
        'userId': teacher.userId,
        'fullName': teacher.fullName,
        'gender': teacher.gender.toString().split('.').last,
        'dateOfBirth': teacher.dateOfBirth.toIso8601String(),
        'profileImage': teacher.profileImage,
        'isDeleted': teacher.isDeleted ? 1 : 0,
      },
      where: 'teacherCode = ?',
      whereArgs: [teacher.teacherCode],
    );
  }

  Future<int> softDeleteTeacher(String teacherCode) async {
    final db = await database;
    return await db.update(
      'teachers',
      {'isDeleted': 1},
      where: 'teacherCode = ?',
      whereArgs: [teacherCode],
    );
  }

  Future<List<Teacher>> getAllTeachers() async {
    final db = await database;
    final maps = await db.query('teachers', where: 'isDeleted = 0');

    return List.generate(maps.length, (i) {
      final data = maps[i];
      return Teacher(
        userId: data['userId'] as int,
        teacherCode: data['teacherCode'] as String,
        fullName: data['fullName'] as String,
        gender: Gender.values.firstWhere(
          (e) => e.toString().split('.').last == data['gender'],
        ),
        dateOfBirth: DateTime.parse(data['dateOfBirth'] as String),
        profileImage: data['profileImage'] as String,
        isDeleted: (data['isDeleted'] as int) == 1,
      );
    });
  }
}
