import 'package:sqflite/sqflite.dart';
import '../models.dart';
import '../database/account_table.dart';

class ChatboxDBHelper {
  static final ChatboxDBHelper _instance = ChatboxDBHelper._internal();
  factory ChatboxDBHelper() => _instance;
  ChatboxDBHelper._internal();

  Future<Database> get database async {
    return await DBHelper().database;
  }

  Future<int> insertBoxChat(BoxChat boxChat, {DatabaseExecutor? txn}) async {
    final db = txn ?? await database;
    return await db.insert('box_chats', {
      'requestId': boxChat.requestId,
      'senderUserId': boxChat.senderUserId,
      'receiverUserId': boxChat.receiverUserId,
      'isClosedByStudent': boxChat.isClosedByStudent ? 1 : 0,
      'createdAt': boxChat.createdAt.toIso8601String(),
      'isClosedByReceiver': boxChat.isClosedByReceiver ? 1 : 0,
      'isDeleted': boxChat.isDeleted ? 1 : 0,
    });
  }

  Future<BoxChat> getBoxChatByRequestId(int requestId) async {
    final db = await database;
    final maps = await db.query(
      'box_chats',
      where: 'requestId = ? AND isDeleted = 0',
      whereArgs: [requestId],
    );

    if (maps.isNotEmpty) {
      final data = maps.first;
      return BoxChat(
        boxChatId: data['boxChatId'] as int,
        requestId: data['requestId'] as int,
        senderUserId: data['senderUserId'] as int,
        receiverUserId: data['receiverUserId'] as int,
        createdAt: DateTime.parse(data['createdAt'] as String),
        isClosedByStudent: (data['isClosedByStudent'] as int) == 1,
        isClosedByReceiver: (data['isClosedByReceiver'] as int) == 1,
        isDeleted: (data['isDeleted'] as int) == 1,
      );
    }
    throw Exception('No box chat found for requestId: $requestId');
  }

  Future<List<BoxChat>> getBoxChatsByUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'box_chats',
      where: '(senderUserId = ? OR receiverUserId = ?) AND isDeleted = 0',
      whereArgs: [userId, userId],
      orderBy: 'boxChatId DESC',
    );

    return List.generate(maps.length, (i) {
      return BoxChat(
        boxChatId: maps[i]['boxChatId'],
        requestId: maps[i]['requestId'],
        senderUserId: maps[i]['senderUserId'],
        receiverUserId: maps[i]['receiverUserId'],
        createdAt: DateTime.parse(maps[i]['createdAt'] as String),
        isClosedByStudent: maps[i]['isClosedByStudent'] == 1,
        isClosedByReceiver: maps[i]['isClosedByReceiver'] == 1,
        isDeleted: maps[i]['isDeleted'] == 1,
      );
    });
  }

  Future<void> insertReport(Report report) async {
    final db = await database;
    await db.insert('reports', {
      'reporterUserId': report.reporterUserId,
      'reportedUserId': report.reportedUserId,
      'reason': report.reason,
      'reportedAt': report.reportedAt.toIso8601String(),
      'isHandled': report.isHandled ? 1 : 0,
    });
  }

  Future<List<Report>> getReports() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reports');
    return List.generate(maps.length, (i) {
      return Report(
        reportId: maps[i]['reportId'],
        reporterUserId: maps[i]['reporterUserId'],
        reportedUserId: maps[i]['reportedUserId'],
        reason: maps[i]['reason'],
        reportedAt: DateTime.parse(maps[i]['reportedAt']),
        isHandled: maps[i]['isHandled'] == 1,
      );
    });
  }

  Future<void> deleteBoxChat(int boxChatId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'box_chats',
        {'isDeleted': 1},
        where: 'boxChatId = ?',
        whereArgs: [boxChatId],
      );
      await txn.update(
        'messages',
        {'isDeleted': 1},
        where: 'boxChatId = ?',
        whereArgs: [boxChatId],
      );
    });
  }
}
