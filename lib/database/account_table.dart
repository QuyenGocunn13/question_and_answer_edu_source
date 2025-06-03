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

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Tạo bảng Account
    await db.execute('''
      CREATE TABLE accounts (
        userId INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // CREATE: Thêm account mới
  Future<int> insertAccount(Account account) async {
    final db = await database;
    return await db.insert('accounts', {
      'username': account.username,
      'password': account.password,
      'role': account.role.toString().split('.').last,
      'isDeleted': account.isDeleted ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
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
  }

  // DELETE: Xóa mềm account (set isDeleted = true)
  Future<int> softDeleteAccount(int userId) async {
    final db = await database;
    return await db.update(
      'accounts',
      {'isDeleted': 1},
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // Lấy tất cả account chưa bị xóa
  Future<List<Account>> getAllAccounts() async {
    final db = await database;
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
  }
}
