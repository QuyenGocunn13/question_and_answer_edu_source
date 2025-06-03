// Enums
enum UserRole { student, teacher, admin }
enum RequestStatus { pending, processing, resolved }
enum Gender { male, female, other }

// Account
class Account {
  final int userId;
  final String username;
  final String password;
  final UserRole role;
  final bool isDeleted;

  Account({
    required this.userId,
    required this.username,
    required this.password,
    required this.role,
    this.isDeleted = false,
  });
}

// Student
class Student {
  final int userId;
  final String studentCode;
  final String fullName;
  final Gender gender;
  final DateTime dateOfBirth;
  final String placeOfBirth;
  final String className;
  final int intakeYear;
  final String major;
  final String profileImage;
  final bool isDeleted;

  Student({
    required this.userId,
    required this.studentCode,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.className,
    required this.intakeYear,
    required this.major,
    required this.profileImage,
    this.isDeleted = false,
  });
}

// Teacher
class Teacher {
  final int userId;
  final String teacherCode;
  final String fullName;
  final Gender gender;
  final DateTime dateOfBirth;
  final String profileImage;
  final bool isDeleted;

  Teacher({
    required this.userId,
    required this.teacherCode,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.profileImage,
    this.isDeleted = false,
  });
}

// Request
class Request {
  final int requestId;
  final int studentUserId;
  final String questionType;
  final String title;
  final String content;
  final RequestStatus status;
  final DateTime createdAt;
  final int? receiverUserId; // Giáo viên hoặc admin
  final bool isDeleted;

  Request({
    required this.requestId,
    required this.studentUserId,
    required this.questionType,
    required this.title,
    required this.content,
    required this.status,
    required this.createdAt,
    this.receiverUserId,
    this.isDeleted = false,
  });
}

// BoxChat
class BoxChat {
  final int boxChatId;
  final int requestId;
  final int senderUserId;    // sinh viên
  final int receiverUserId;  // giáo viên hoặc admin
  final bool isClosedByStudent;
  final bool isClosedByReceiver;
  final bool isDeleted;

  BoxChat({
    required this.boxChatId,
    required this.requestId,
    required this.senderUserId,
    required this.receiverUserId,
    this.isClosedByStudent = false,
    this.isClosedByReceiver = false,
    this.isDeleted = false,
  });
}

// Message
class Message {
  final int messageId;
  final int boxChatId;
  final int senderUserId;
  final String content;
  final DateTime sentAt;
  final bool isFile;
  final bool isDeleted;

  Message({
    required this.messageId,
    required this.boxChatId,
    required this.senderUserId,
    required this.content,
    required this.sentAt, 
    this.isFile = false,
    this.isDeleted = false,
  });
}

// Report
class Report {
  final int reportId;
  final int reporterUserId;
  final int reportedUserId;
  final String reason;
  final DateTime reportedAt;
  final bool isHandled;

  Report({
    required this.reportId,
    required this.reporterUserId,
    required this.reportedUserId,
    required this.reason,
    required this.reportedAt,
    this.isHandled = false,
  });
}

// BannedWord
class BannedWord {
  final int id;
  final String word;

  BannedWord({
    required this.id,
    required this.word,
  });
}
