import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../models.dart';
import 'account_table.dart';
import 'student_table.dart';
import 'teacher_table.dart';
import 'request_table.dart';
import 'box_chat_table.dart';
import 'message_table.dart';

Future<void> seedSampleData() async {
  final dbHelper = DBHelper();
  final db = await dbHelper.database;

  print('=== Start seeding sample data ===');

  try {
    await db.transaction((txn) async {
      // Chèn tài khoản
      int accountId1 = await txn.insert('accounts', {
        'username': 'student1@example.com',
        'password': 'pass123',
        'role': 'student',
        'isDeleted': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      print('Inserted account 1: $accountId1');

      int accountId2 = await txn.insert('accounts', {
        'username': 'teacher1@example.com',
        'password': 'pass123',
        'role': 'teacher',
        'isDeleted': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      print('Inserted account 2: $accountId2');

      // Chèn sinh viên
      int studentId = await txn.insert('students', {
        'studentCode': 'SC001',
        'userId': accountId1,
        'fullName': 'Nguyễn Văn A',
        'gender': 'male',
        'dateOfBirth': '2000-01-05',
        'placeOfBirth': 'Hà Nội',
        'className': 'CNTT-K45',
        'intakeYear': 2020,
        'major': 'Công nghệ thông tin',
        'profileImage': '',
        'isDeleted': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      print('Inserted student: $studentId');

      // Chèn giáo viên
      int teacherId = await txn.insert('teachers', {
        'teacherCode': 'TC001',
        'userId': accountId2,
        'fullName': 'Trần Thị B',
        'gender': 'female',
        'dateOfBirth': '1980-01-01',
        'profileImage': '',
        'isDeleted': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      print('Inserted teacher: $teacherId');

      // Chèn câu hỏi
      int requestId = await txn.insert('requests', {
        'studentUserId': accountId1,
        'questionType': 'Học tập',
        'title': 'Hỏi về học phí',
        'content': 'Cho em hỏi về chính sách giảm học phí',
        'attachedFilePath': null,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        'receiverUserId': accountId2,
        'boxChatId': null,
        'isDeleted': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      print('Inserted request: $requestId');

      // Chèn hộp thoại
      int boxChatId = await txn.insert('box_chats', {
        'requestId': requestId,
        'senderUserId': accountId1,
        'receiverUserId': accountId2,
        'createdAt': DateTime.now().toIso8601String(),
        'isClosedByStudent': 0,
        'isClosedByReceiver': 0,
        'isDeleted': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      print('Inserted box chat: $boxChatId');

      // Cập nhật boxChatId trong requests
      await txn.update(
        'requests',
        {'boxChatId': boxChatId},
        where: 'requestId = ?',
        whereArgs: [requestId],
      );

      // Chèn tin nhắn
      int messageId = await txn.insert('messages', {
        'boxChatId': boxChatId,
        'senderUserId': accountId1,
        'content': 'Xin chào, em muốn hỏi về học phí.',
        'sentAt': DateTime.now().toIso8601String(),
        'isFile': 0,
        'isDeleted': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      print('Inserted message: $messageId');

      // Chèn báo cáo
      int reportId = await txn.insert('reports', {
        'reporterUserId': accountId1,
        'reportedUserId': accountId2,
        'reason': 'Nội dung không phù hợp',
        'reportedAt': DateTime.now().toIso8601String(),
        'isHandled': 0,
      });
      print('Inserted report: $reportId');

      // Chèn từ cấm
      int bannedWordId = await txn.insert('banned_words', {'word': 'badword'});
      print('Inserted banned word: $bannedWordId');
    });

    print('=== Sample data seeded successfully ===');
  } catch (e) {
    throw Exception('Error seeding sample data: $e');
  }

  await dbHelper.debugDatabase();
}
