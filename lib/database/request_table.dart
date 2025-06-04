import 'package:sqflite/sqflite.dart';
import '../models.dart';
import 'box_chat_table.dart' as boxChat; // Sử dụng alias để tránh xung đột
import 'account_table.dart';
class RequestDBHelper {
  static final RequestDBHelper _instance = RequestDBHelper._internal();
  factory RequestDBHelper() => _instance;
  RequestDBHelper._internal();

  Future<Database> get database async {
    return await DBHelper().database;
  }

  Future<int> insertRequest(Request request) async {
    final db = await database;
    return await db.transaction((txn) async {
      try {
        return await txn.insert('requests', {
          'studentUserId': request.studentUserId,
          'questionType': request.questionType,
          'title': request.title,
          'content': request.content,
          'attachedFilePath': request.attachedFilePath,
          'status': request.status.toString().split('.').last,
          'createdAt': request.createdAt.toIso8601String(),
          'receiverUserId': request.receiverUserId,
          'boxChatId': request.boxChatId,
          'isDeleted': request.isDeleted ? 1 : 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (e) {
        throw Exception('Lỗi khi chèn yêu cầu: $e');
      }
    });
  }

  Future<void> approveRequest(int requestId, int teacherUserId) async {
    final db = await database;
    await db.transaction((txn) async {
      try {
        await txn.update(
          'requests',
          {
            'status': RequestStatus.approved.toString().split('.').last,
            'receiverUserId': teacherUserId,
          },
          where: 'requestId = ?',
          whereArgs: [requestId],
        );

        final existingBoxChat = await txn.query(
          'box_chats',
          where: 'requestId = ?',
          whereArgs: [requestId],
        );

        if (existingBoxChat.isEmpty) {
          final request = await txn.query(
            'requests',
            where: 'requestId = ?',
            whereArgs: [requestId],
          );

          if (request.isNotEmpty) {
            final studentUserId = request.first['studentUserId'] as int;
            final boxChatId = await boxChat.ChatboxDBHelper().insertBoxChat(
              BoxChat(
                // Sử dụng BoxChat từ models.dart
                boxChatId: 0,
                requestId: requestId,
                senderUserId: studentUserId,
                receiverUserId: teacherUserId,
                isClosedByStudent: false,
                isClosedByReceiver: false,
                isDeleted: false,
                createdAt: DateTime.now(), // Thêm createdAt
              ),
            );

            await txn.update(
              'requests',
              {'boxChatId': boxChatId},
              where: 'requestId = ?',
              whereArgs: [requestId],
            );
          }
        }
      } catch (e) {
        throw Exception('Lỗi khi phê duyệt yêu cầu: $e');
      }
    });
  }

  Future<int> updateRequestStatus(int requestId, RequestStatus status) async {
    final db = await database;
    return await db.transaction((txn) async {
      try {
        return await txn.update(
          'requests',
          {'status': status.toString().split('.').last},
          where: 'requestId = ?',
          whereArgs: [requestId],
        );
      } catch (e) {
        throw Exception('Lỗi khi cập nhật trạng thái yêu cầu: $e');
      }
    });
  }

  Future<List<Request>> getRequestsByStudent(int studentUserId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'requests',
      where: 'studentUserId = ? AND isDeleted = 0',
      whereArgs: [studentUserId],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Request(
        requestId: maps[i]['requestId'] as int,
        studentUserId: maps[i]['studentUserId'] as int,
        questionType: maps[i]['questionType'] as String,
        title: maps[i]['title'] as String,
        content: maps[i]['content'] as String,
        attachedFilePath: maps[i]['attachedFilePath'] as String?,
        status: RequestStatus.values.firstWhere(
          (e) => e.toString().split('.').last == maps[i]['status'],
        ),
        createdAt: DateTime.parse(maps[i]['createdAt'] as String),
        receiverUserId: maps[i]['receiverUserId'] as int?,
        boxChatId: maps[i]['boxChatId'] as int?,
        isDeleted: (maps[i]['isDeleted'] as int) == 1,
      );
    });
  }

  Future<void> insertBannedWord(BannedWord bannedWord) async {
    final db = await database;
    await db.insert('banned_words', {'word': bannedWord.word});
  }

  Future<List<BannedWord>> getBannedWords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('banned_words');
    return List.generate(maps.length, (i) {
      return BannedWord(id: maps[i]['id'], word: maps[i]['word']);
    });
  }

  Future<List<Request>> getRequestsByStatus(String status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'requests',
      where: 'status = ? AND isDeleted = 0',
      whereArgs: [status],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Request(
        requestId: maps[i]['requestId'] as int,
        studentUserId: maps[i]['studentUserId'] as int,
        questionType: maps[i]['questionType'] as String,
        title: maps[i]['title'] as String,
        content: maps[i]['content'] as String,
        attachedFilePath: maps[i]['attachedFilePath'] as String?,
        status: RequestStatus.values.firstWhere(
          (e) => e.toString().split('.').last == maps[i]['status'],
        ),
        createdAt: DateTime.parse(maps[i]['createdAt'] as String),
        receiverUserId: maps[i]['receiverUserId'] as int?,
        boxChatId: maps[i]['boxChatId'] as int?,
        isDeleted: (maps[i]['isDeleted'] as int) == 1,
      );
    });
  }

  Future<List<Request>> getRequestsByTeacher(int teacherId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'requests',
      where: 'receiverUserId = ? AND status = ? AND isDeleted = 0',
      whereArgs: [teacherId, 'approved'],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Request(
        requestId: maps[i]['requestId'] as int,
        studentUserId: maps[i]['studentUserId'] as int,
        questionType: maps[i]['questionType'] as String,
        title: maps[i]['title'] as String,
        content: maps[i]['content'] as String,
        attachedFilePath: maps[i]['attachedFilePath'] as String?,
        status: RequestStatus.values.firstWhere(
          (e) => e.toString().split('.').last == maps[i]['status'],
        ),
        createdAt: DateTime.parse(maps[i]['createdAt'] as String),
        receiverUserId: maps[i]['receiverUserId'] as int?,
        boxChatId: maps[i]['boxChatId'] as int?,
        isDeleted: (maps[i]['isDeleted'] as int) == 1,
      );
    });
  }
}
