import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:math';
import '../models.dart';
import 'account_table.dart';

class StudentDBHelper {
  static final StudentDBHelper _instance = StudentDBHelper._internal();

  factory StudentDBHelper() => _instance;

  StudentDBHelper._internal();

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
        CREATE TABLE students (
          studentCode TEXT PRIMARY KEY,
          userId INTEGER NOT NULL,
          fullName TEXT NOT NULL,
          gender TEXT NOT NULL,
          dateOfBirth TEXT NOT NULL,
          placeOfBirth TEXT NOT NULL,
          className TEXT NOT NULL,
          intakeYear INTEGER NOT NULL,
          major TEXT NOT NULL,
          profileImage TEXT NOT NULL,
          isDeleted INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (userId) REFERENCES accounts(userId) ON DELETE CASCADE ON UPDATE NO ACTION
        )
      ''');
  }

  // Hàm tạo studentCode dạng "2001" + 4 số random
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
      String studentCode;

      // Lặp tạo studentCode cho đến khi không bị trùng
      do {
        studentCode = generateStudentCode();
      } while (await isStudentCodeExists(studentCode));

      // Tạo account sử dụng studentCode làm username
      final account = Account(
        userId: 0,
        username: studentCode,
        password: 'huit$studentCode',
        role: UserRole.student,
        isDeleted: false,
      );

      // Lưu account vào DB và lấy userId
      int newUserId = await dbHelper.insertAccount(account);

      // Tạo student mới
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
        profileImage: student.profileImage,
        isDeleted: false,
      );

      // Lưu student vào DB
      await db.insert('students', {
        'studentCode': newStudent.studentCode,
        'userId': newStudent.userId,
        'fullName': newStudent.fullName,
        'gender': newStudent.gender.toString().split('.').last,
        'dateOfBirth': newStudent.dateOfBirth.toIso8601String(),
        'placeOfBirth': newStudent.placeOfBirth,
        'className': newStudent.className,
        'intakeYear': newStudent.intakeYear,
        'major': newStudent.major,
        'profileImage': newStudent.profileImage,
        'isDeleted': 0,
      });

      print("===> Student created:");
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
  }

  Future<int> softDeleteStudent(String studentCode) async {
    final db = await database;
    return await db.update(
      'students',
      {'isDeleted': 1},
      where: 'studentCode = ?',
      whereArgs: [studentCode],
    );
  }

  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final maps = await db.query('students', where: 'isDeleted = 0');

    return List.generate(maps.length, (i) {
      final data = maps[i];
      return Student(
        userId: data['userId'] as int,
        studentCode: data['studentCode'] as String,
        fullName: data['fullName'] as String,
        gender: Gender.values.firstWhere(
          (e) => e.toString().split('.').last == data['gender'],
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
  }
}
