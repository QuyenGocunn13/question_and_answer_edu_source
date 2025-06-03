import 'dart:async';
import '../models.dart';
import 'account_table.dart';
import 'student_table.dart';
import 'teacher_table.dart';

Future<void> seedSampleData() async {
  final accountHelper = DBHelper();
  final studentHelper = StudentDBHelper();
  final teacherHelper = TeacherDBHelper();

  // Xóa hết dữ liệu cũ (nếu cần)
  // Đây là cách đơn giản nhất, bạn có thể thêm hàm xoá hoặc reset DB trong DBHelper nếu cần

  print('=== Start seeding sample data ===');

  // Tạo sample students
  var student1 = Student(
    userId: 0,
    studentCode: '',
    fullName: 'Nguyễn Văn A',
    gender: Gender.male,
    dateOfBirth: DateTime(2002, 3, 15),
    placeOfBirth: 'Hà Nội',
    className: 'CTK43',
    intakeYear: 2020,
    major: 'Công nghệ thông tin',
    profileImage: 'https://i.imgur.com/LQbRwkt.jpeg',
  );

  var student2 = Student(
    userId: 0,
    studentCode: '',
    fullName: 'Trần Thị B',
    gender: Gender.female,
    dateOfBirth: DateTime(2001, 7, 22),
    placeOfBirth: 'Hồ Chí Minh',
    className: 'CTK43',
    intakeYear: 2020,
    major: 'Khoa học máy tính',
    profileImage: 'https://i.imgur.com/LQbRwkt.jpeg',
  );

  // Tạo sample teachers
  var teacher1 = Teacher(
    userId: 0,
    teacherCode: '',
    fullName: 'Lê Văn C',
    gender: Gender.male,
    dateOfBirth: DateTime(1980, 1, 5),
    profileImage: 'https://i.imgur.com/LQbRwkt.jpeg',
  );

  var teacher2 = Teacher(
    userId: 0,
    teacherCode: '',
    fullName: 'Phạm Thị D',
    gender: Gender.female,
    dateOfBirth: DateTime(1978, 11, 11),
    profileImage: 'https://i.imgur.com/LQbRwkt.jpeg',
  );

  // Insert students
  Student? s1 = await studentHelper.insertStudent(student1);
  Student? s2 = await studentHelper.insertStudent(student2);

  // Insert teachers
  Teacher? t1 = await teacherHelper.insertTeacher(teacher1);
  Teacher? t2 = await teacherHelper.insertTeacher(teacher2);

  print('=== Sample data created ===');
  print('Students:');
  if (s1 != null) print('${s1.studentCode} - ${s1.fullName}');
  if (s2 != null) print('${s2.studentCode} - ${s2.fullName}');

  print('Teachers:');
  if (t1 != null) print('${t1.teacherCode} - ${t1.fullName}');
  if (t2 != null) print('${t2.teacherCode} - ${t2.fullName}');
}

void main() async {
  await seedSampleData();
}
