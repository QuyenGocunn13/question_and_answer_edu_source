// models.dart
enum UserRole { student, teacher, admin }

enum Gender { male, female, other }

enum RequestStatus { pending, approved, rejected, resolved }

// Account
class Account {
  final int userId; // Sửa từ int? thành int
  final String username;
  final String password;
  final UserRole role;
  final bool isDeleted;

  Account({
    this.userId = 0, // Giá trị mặc định là 0
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
  final int requestId; // Sửa từ int? thành int
  final int studentUserId;
  final String questionType;
  final String title;
  final String content;
  final String? attachedFilePath;
  final RequestStatus status;
  final DateTime createdAt;
  final int? receiverUserId;
  final int? boxChatId;
  final bool isDeleted;

  Request({
    this.requestId = 0, // Giá trị mặc định là 0
    required this.studentUserId,
    required this.questionType,
    required this.title,
    required this.content,
    this.attachedFilePath,
    required this.status,
    required this.createdAt,
    this.receiverUserId,
    this.boxChatId,
    this.isDeleted = false,
  });
}

// BoxChat
class BoxChat {
  final int boxChatId;
  final int requestId;
  final int senderUserId;
  final int receiverUserId;
  final bool isClosedByStudent;
  final bool isClosedByReceiver;
  final bool isDeleted;
  final DateTime createdAt; // Đã thêm

  BoxChat({
    this.boxChatId = 0,
    required this.requestId,
    required this.senderUserId,
    required this.receiverUserId,
    this.isClosedByStudent = false,
    this.isClosedByReceiver = false,
    this.isDeleted = false,
    required this.createdAt, // Đã thêm
  });
}

// Message
class Message {
  final int messageId; // Sửa từ int? thành int
  final int boxChatId;
  final int senderUserId;
  final String content;
  final DateTime sentAt;
  final bool isFile;
  final bool isDeleted;

  Message({
    this.messageId = 0, // Giá trị mặc định là 0
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
  final int reportId; // Sửa từ int? thành int
  final int reporterUserId;
  final int reportedUserId;
  final String reason;
  final DateTime reportedAt;
  final bool isHandled;

  Report({
    this.reportId = 0, // Giá trị mặc định là 0
    required this.reporterUserId,
    required this.reportedUserId,
    required this.reason,
    required this.reportedAt,
    this.isHandled = false,
  });
}

// BannedWord
class BannedWord {
  final int id; // Sửa từ int? thành int
  final String word;

  BannedWord({
    this.id = 0, // Giá trị mặc định là 0
    required this.word,
  });
}
