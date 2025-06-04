import 'package:sqflite/sqflite.dart';
import '../models.dart';
import 'box_chat_table.dart';
import '../database/account_table.dart';

class MessageDBHelper {
  static final MessageDBHelper _instance = MessageDBHelper._internal();
  factory MessageDBHelper() => _instance;
  MessageDBHelper._internal();

  Future<Database> get database async {
    return await DBHelper().database; // Sử dụng database từ DBHelper
  }

  Future<int> insertMessage(Message message) async {
    final db = await database;
    return await db.transaction((txn) async {
      try {
        return await txn.insert('messages', {
          'boxChatId': message.boxChatId,
          'senderUserId': message.senderUserId,
          'content': message.content,
          'sentAt': message.sentAt.toIso8601String(),
          'isFile': message.isFile ? 1 : 0,
          'isDeleted': message.isDeleted ? 1 : 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (e) {
        throw Exception('Lỗi khi chèn tin nhắn: $e');
      }
    });
  }

  Future<List<Message>> getMessagesByBoxChat(int boxChatId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'boxChatId = ? AND isDeleted = 0',
      whereArgs: [boxChatId],
      orderBy: 'sentAt ASC',
    );

    return List.generate(maps.length, (i) {
      return Message(
        messageId: maps[i]['messageId'],
        boxChatId: maps[i]['boxChatId'],
        senderUserId: maps[i]['senderUserId'],
        content: maps[i]['content'],
        sentAt: DateTime.parse(maps[i]['sentAt']),
        isFile: maps[i]['isFile'] == 1,
        isDeleted: maps[i]['isDeleted'] == 1,
      );
    });
  }
}
