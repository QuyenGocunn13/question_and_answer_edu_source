import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
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
    print('Initializing database at: $path');
    var db = await openDatabase(
      path,
      version: 5, // Tăng version do thay đổi schema
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
    await db.execute('PRAGMA foreign_keys = ON'); // Bật FOREIGN KEY
    return db;
  }

  Future _createDB(Database db, int version) async {
    print('Creating database tables...');
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
        profileImage TEXT NOT NULL DEFAULT '',
        isDeleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES accounts(userId) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    // Tạo bảng requests
    await db.execute('''
      CREATE TABLE requests (
        requestId INTEGER PRIMARY KEY AUTOINCREMENT,
        studentUserId INTEGER NOT NULL,
        questionType TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        attachedFilePath TEXT, -- Thêm trường này
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        receiverUserId INTEGER,
        boxChatId INTEGER,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (studentUserId) REFERENCES accounts(userId),
        FOREIGN KEY (receiverUserId) REFERENCES accounts(userId),
        FOREIGN KEY (boxChatId) REFERENCES box_chats(boxChatId)
      )
    ''');

    // Tạo bảng box_chats
    await db.execute('''
      CREATE TABLE box_chats (
        boxChatId INTEGER PRIMARY KEY AUTOINCREMENT,
        requestId INTEGER NOT NULL,
        senderUserId INTEGER NOT NULL,
        receiverUserId INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        isClosedByStudent INTEGER NOT NULL DEFAULT 0, -- Thêm trường này
        isClosedByReceiver INTEGER NOT NULL DEFAULT 0, -- Thêm trường này
        isDeleted INTEGER NOT NULL DEFAULT 0, -- Thêm trường này
        FOREIGN KEY (requestId) REFERENCES requests(requestId),
        FOREIGN KEY (senderUserId) REFERENCES accounts(userId),
        FOREIGN KEY (receiverUserId) REFERENCES accounts(userId)
      )
    ''');

    // Tạo bảng messages
    await db.execute('''
      CREATE TABLE messages (
        messageId INTEGER PRIMARY KEY AUTOINCREMENT,
        boxChatId INTEGER NOT NULL,
        senderUserId INTEGER NOT NULL,
        content TEXT NOT NULL,
        sentAt TEXT NOT NULL,
        isFile INTEGER NOT NULL DEFAULT 0, -- Thêm trường này
        isDeleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (boxChatId) REFERENCES box_chats(boxChatId),
        FOREIGN KEY (senderUserId) REFERENCES accounts(userId)
      )
    ''');

    // Tạo bảng reports
    await db.execute('''
      CREATE TABLE reports (
        reportId INTEGER PRIMARY KEY AUTOINCREMENT,
        reporterUserId INTEGER NOT NULL,
        reportedUserId INTEGER NOT NULL,
        reason TEXT NOT NULL,
        reportedAt TEXT NOT NULL, -- Sử dụng TEXT thay vì DATETIME
        isHandled INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (reporterUserId) REFERENCES accounts(userId),
        FOREIGN KEY (reportedUserId) REFERENCES accounts(userId)
      )
    ''');

    // Tạo bảng banned_words
    await db.execute('''
      CREATE TABLE banned_words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL UNIQUE
      )
    ''');

    print('Database tables created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');
    if (oldVersion < 5) {
      // Thêm trường attachedFilePath cho requests
      await db.execute('ALTER TABLE requests ADD COLUMN attachedFilePath TEXT');

      // Thêm các trường cho box_chats
      await db.execute(
        'ALTER TABLE box_chats ADD COLUMN isClosedByStudent INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE box_chats ADD COLUMN isClosedByReceiver INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE box_chats ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0',
      );

      // Thêm trường isFile cho messages
      await db.execute(
        'ALTER TABLE messages ADD COLUMN isFile INTEGER NOT NULL DEFAULT 0',
      );

      // Tạo bảng reports nếu chưa tồn tại
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reports (
          reportId INTEGER PRIMARY KEY AUTOINCREMENT,
          reporterUserId INTEGER NOT NULL,
          reportedUserId INTEGER NOT NULL,
          reason TEXT NOT NULL,
          reportedAt TEXT NOT NULL,
          isHandled INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (reporterUserId) REFERENCES accounts(userId),
          FOREIGN KEY (reportedUserId) REFERENCES accounts(userId)
        )
      ''');

      // Tạo bảng banned_words nếu chưa tồn tại
      await db.execute('''
        CREATE TABLE IF NOT EXISTS banned_words (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          word TEXT NOT NULL UNIQUE
        )
      ''');
    }
  }

  // Các hàm còn lại giữ nguyên, vì đã khớp với schema
  Future<int> insertAccount(Account account) async {
    final db = await database;
    try {
      print('Inserting account: ${account.username}');
      return await db.insert('accounts', {
        'username': account.username,
        'password': account.password,
        'role': account.role.toString().split('.').last,
        'isDeleted': account.isDeleted ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception('Lỗi khi chèn tài khoản: $e');
    }
  }

  Future<List<Teacher>> getTeachers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'teachers',
      where: 'isDeleted = 0',
    );

    return List.generate(maps.length, (i) {
      return Teacher(
        userId: maps[i]['userId'],
        teacherCode: maps[i]['teacherCode'],
        fullName: maps[i]['fullName'],
        gender: Gender.values.firstWhere(
          (e) => e.toString().split('.').last == maps[i]['gender'],
        ),
        dateOfBirth: DateTime.parse(maps[i]['dateOfBirth']),
        profileImage: maps[i]['profileImage'],
        isDeleted: maps[i]['isDeleted'] == 1,
      );
    });
  }

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
      throw Exception('Lỗi khi cập nhật tài khoản: $e');
    }
  }

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
      throw Exception('Lỗi khi xóa mềm tài khoản: $e');
    }
  }

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
      throw Exception('Lỗi khi lấy danh sách tài khoản: $e');
    }
  }

  Future<void> debugDatabase() async {
    final db = await database;
    try {
      final accounts = await db.query('accounts', where: 'isDeleted = 0');
      final students = await db.query('students', where: 'isDeleted = 0');
      final teachers = await db.query('teachers', where: 'isDeleted = 0');
      final requests = await db.query('requests', where: 'isDeleted = 0');
      final boxChats = await db.query('box_chats', where: 'isDeleted = 0');
      final messages = await db.query('messages', where: 'isDeleted = 0');
      final reports = await db.query('reports', where: 'isHandled = 0');
      final bannedWords = await db.query('banned_words');
      print('Accounts: $accounts');
      print('Students: $students');
      print('Teachers: $teachers');
      print('Requests: $requests');
      print('Box Chats: $boxChats');
      print('Messages: $messages');
      print('Reports: $reports');
      print('Banned Words: $bannedWords');
    } catch (e) {
      throw Exception('Lỗi khi debug database: $e');
    }
  }

  Future<void> exportDatabase() async {
    final db = await database;
    final directory = await getExternalStorageDirectory();
    final exportPath = join(directory!.path, 'app_database_backup.db');
    final dbFile = File(await db.path);
    await dbFile.copy(exportPath);
    print('Database exported to: $exportPath');
  }

  Future<void> importDatabase(String importPath) async {
    final db = await database;
    final dbFile = File(await db.path);
    await db.close();
    await dbFile.copy(importPath);
    _database = await _initDB('app_database.db');
    print('Database imported from: $importPath');
  }
}
