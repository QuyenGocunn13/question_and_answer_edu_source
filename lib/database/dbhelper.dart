import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();

  factory DBHelper() => _instance;

  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    ); // Tăng version
  }

  Future _createDB(Database db, int version) async {
    // Tạo bảng accounts
    await db.execute('''
      CREATE TABLE accounts (
        userId INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tạo bảng students
    await db.execute('''
      CREATE TABLE students (
        studentCode TEXT PRIMARY KEY,
        userId INTEGER NOT NULL UNIQUE,
        fullName TEXT NOT NULL,
        gender TEXT NOT NULL,
        dateOfBirth TEXT NOT NULL,
        placeOfBirth TEXT NOT NULL,
        className TEXT NOT NULL,
        intakeYear INTEGER NOT NULL,
        major TEXT NOT NULL,
        profileImage TEXT NOT NULL DEFAULT '',
        isDeleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES accounts(userId) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    // Tạo bảng teachers
    await db.execute('''
      CREATE TABLE teachers (
        teacherCode TEXT PRIMARY KEY,
        userId INTEGER NOT NULL UNIQUE,
        fullName TEXT NOT NULL,
        gender TEXT NOT NULL,
        dateOfBirth TEXT NOT NULL,
        department TEXT NOT NULL DEFAULT 'DEFAULT',
        profileImage TEXT NOT NULL DEFAULT '',
        isDeleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES accounts(userId) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Tạo bảng students nếu chưa có
      await db.execute('''
        CREATE TABLE IF NOT EXISTS students (
          studentCode TEXT PRIMARY KEY,
          userId INTEGER NOT NULL UNIQUE,
          fullName TEXT NOT NULL,
          gender TEXT NOT NULL,
          dateOfBirth TEXT NOT NULL,
          placeOfBirth TEXT NOT NULL,
          className TEXT NOT NULL,
          intakeYear INTEGER NOT NULL,
          major TEXT NOT NULL,
          profileImage TEXT NOT NULL DEFAULT '',
          isDeleted INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (userId) REFERENCES accounts(userId) ON DELETE CASCADE ON UPDATE CASCADE
        )
      ''');

      // Tạo bảng teachers nếu chưa có
      await db.execute('''
        CREATE TABLE IF NOT EXISTS teachers (
          teacherCode TEXT PRIMARY KEY,
          userId INTEGER NOT NULL UNIQUE,
          fullName TEXT NOT NULL,
          gender TEXT NOT NULL,
          dateOfBirth TEXT NOT NULL,
          department TEXT NOT NULL DEFAULT 'DEFAULT',
          profileImage TEXT NOT NULL DEFAULT '',
          isDeleted INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (userId) REFERENCES accounts(userId) ON DELETE CASCADE ON UPDATE CASCADE
        )
      ''');
    }
  }

  // CREATE: Thêm account mới
  Future<int> insertAccount(Account account) async {
    final db = await database;
    try {
      return await db.insert('accounts', {
        'username': account.username,
        'password': account.password,
        'role': account.role.toString().split('.').last,
        'isDeleted': account.isDeleted ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('Lỗi khi chèn tài khoản: $e');
      return 0;
    }
  }

  // READ: Lấy account theo userId
  Future<Account?> getAccountById(int userId) async {
    final db = await database;
    final maps = await db.query(
      'accounts',
      where: 'userId = ? AND isDeleted = 0',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      final data = maps.first;
      return Account(
        userId: data['userId'] as int,
        username: data['username'] as String,
        password: data['password'] as String,
        role: UserRole.values.firstWhere(
          (e) => e.toString().split('.').last == data['role'],
        ),
        isDeleted: (data['isDeleted'] as int) == 1,
      );
    }
    return null;
  }

  // UPDATE: Cập nhật thông tin account
  Future<int> updateAccount(Account account) async {
    final db = await database;
    try {
      return await db.update(
        'accounts',
        {
          'username': account.username,
          'password': account.password,
          'role': account.role.toString().split('.').last,
          'isDeleted': account.isDeleted ? 1 : 0,
        },
        where: 'userId = ?',
        whereArgs: [account.userId],
      );
    } catch (e) {
      print('Lỗi khi cập nhật tài khoản: $e');
      return 0;
    }
  }

  // DELETE: Xóa mềm account
  Future<int> softDeleteAccount(int userId) async {
    final db = await database;
    try {
      return await db.update(
        'accounts',
        {'isDeleted': 1},
        where: 'userId = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      print('Lỗi khi xóa mềm tài khoản: $e');
      return 0;
    }
  }

  // Lấy tất cả account chưa bị xóa
  Future<List<Account>> getAllAccounts() async {
    final db = await database;
    try {
      final maps = await db.query('accounts', where: 'isDeleted = 0');
      return List.generate(maps.length, (i) {
        final data = maps[i];
        return Account(
          userId: data['userId'] as int,
          username: data['username'] as String,
          password: data['password'] as String,
          role: UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == data['role'],
          ),
          isDeleted: (data['isDeleted'] as int) == 1,
        );
      });
    } catch (e) {
      print('Lỗi khi lấy danh sách tài khoản: $e');
      return [];
    }
  }

  // Hàm debug để kiểm tra database
  Future<void> debugDatabase() async {
    final db = await database;
    final accounts = await db.query('accounts');
    final students = await db.query('students');
    final teachers = await db.query('teachers');
    print('Accounts: $accounts');
    print('Students: $students');
    print('Teachers: $teachers');
  }
}
