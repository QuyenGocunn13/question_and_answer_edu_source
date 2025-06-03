import 'package:flutter/material.dart';
import '../../database/account_table.dart';
import '../../models.dart';
import '../admin/student_management.dart';
import '../admin/teacher_management.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({Key? key}) : super(key: key);

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  final DBHelper _accountHelper = DBHelper();
  List<Account> _accounts = [];

  String _currentSubView =
      'accountList'; // 'accountList', 'studentManagement', 'teacherManagement'

  // Biến lọc loại tài khoản
  String _selectedRoleFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await _accountHelper.getAllAccounts();
    setState(() {
      _accounts = accounts;
    });
  }

  Future<void> _deleteAccount(Account account) async {
    await _accountHelper.softDeleteAccount(account.userId);
    await _loadAccounts();
  }

  void _showDeleteDialog(Account account) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa tài khoản'),
            content: Text(
              'Bạn có chắc muốn xóa tài khoản "${account.username}" không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () async {
                  await _deleteAccount(account);
                  Navigator.pop(context);
                },
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }

  void _showAccountDetail(Account account) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Thông tin tài khoản: ${account.username}'),
            content: Text('Vai trò: ${_roleToDisplayName(account.role)}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  void _showCreateAccountDialog() {
    final _usernameController = TextEditingController();
    final _passwordController = TextEditingController();
    UserRole _selectedRole = UserRole.student;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tạo tài khoản mới'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Mật khẩu'),
                  obscureText: true,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Vai trò'),
                  items:
                      UserRole.values.map((role) {
                        return DropdownMenuItem<UserRole>(
                          value: role,
                          child: Text(_roleToDisplayName(role)),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) _selectedRole = value;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () async {
                  final username = _usernameController.text.trim();
                  final password = _passwordController.text.trim();
                  if (username.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng nhập đầy đủ thông tin'),
                      ),
                    );
                    return;
                  }
                  final newAccount = Account(
                    userId: DateTime.now().millisecondsSinceEpoch,
                    username: username,
                    password: password,
                    role: _selectedRole,
                    isDeleted: false,
                  );
                  await _accountHelper.insertAccount(newAccount);
                  Navigator.pop(context);
                  await _loadAccounts();
                },
                child: const Text('Tạo'),
              ),
            ],
          ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 32, color: Colors.blueAccent),
      ),
    );
  }

  // Chuyển enum role sang tên hiển thị tiếng Việt
  String _roleToDisplayName(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Sinh viên';
      case UserRole.teacher:
        return 'Giáo viên';
      case UserRole.admin:
        return 'Tài khoản';
    }
  }

  // Lọc danh sách tài khoản dựa vào _selectedRoleFilter
  List<Account> get _filteredAccounts {
    if (_selectedRoleFilter == 'all') {
      return _accounts;
    } else if (_selectedRoleFilter == 'student') {
      return _accounts.where((acc) => acc.role == UserRole.student).toList();
    } else if (_selectedRoleFilter == 'teacher') {
      return _accounts.where((acc) => acc.role == UserRole.teacher).toList();
    }
    return _accounts;
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (_currentSubView) {
      case 'studentManagement':
        content = StudentManagementView(
          onBack: () {
            setState(() {
              _currentSubView = 'accountList';
            });
            _loadAccounts();
          },
        );
        break;

      case 'teacherManagement':
        content = TeacherManagementView(
          onBack: () {
            setState(() {
              _currentSubView = 'accountList';
            });
            _loadAccounts();
          },
        );
        break;

      case 'accountList':
      default:
        content = Column(
          children: [
            // 3 nút icon phía trên giữ nguyên
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconButton(
                    Icons.account_circle,
                    _showCreateAccountDialog,
                  ),
                  _buildIconButton(
                    Icons.school,
                    () => setState(() => _currentSubView = 'studentManagement'),
                  ),
                  _buildIconButton(
                    Icons.person,
                    () => setState(() => _currentSubView = 'teacherManagement'),
                  ),
                ],
              ),
            ),

            // Dropdown chọn loại tài khoản
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButton<String>(
                  value: _selectedRoleFilter,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tài khoản')),
                    DropdownMenuItem(
                      value: 'student',
                      child: Text('Sinh viên'),
                    ),
                    DropdownMenuItem(
                      value: 'teacher',
                      child: Text('Giáo viên'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRoleFilter = value;
                      });
                    }
                  },
                ),
              ),
            ),

            // Danh sách tài khoản lọc theo loại
            Expanded(
              child:
                  _filteredAccounts.isEmpty
                      ? const Center(
                        child: Text(
                          'Chưa có tài khoản nào',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                      : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: _filteredAccounts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final account = _filteredAccounts[index];

                          Color roleColor;
                          switch (account.role) {
                            case UserRole.admin:
                              roleColor = Colors.grey;
                              break;
                            case UserRole.teacher:
                              roleColor = Colors.blueAccent;
                              break;
                            case UserRole.student:
                              roleColor = Colors.green;
                              break;
                          }

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: roleColor.withOpacity(0.2),
                                child: Text(
                                  account.username.isNotEmpty
                                      ? account.username[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: roleColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              title: Text(
                                account.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                _roleToDisplayName(account.role),
                                style: TextStyle(
                                  color: roleColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.grey,
                                ),
                                splashRadius: 24,
                                onPressed: () => _showDeleteDialog(account),
                              ),
                              onTap: () => _showAccountDetail(account),
                            ),
                          );
                        },
                      ),
            ),
          ],
        );
        break;
    }

    return content;
  }
}
