import 'package:flutter/material.dart';
import 'new_question_form.dart';

class StudentDashboardView extends StatelessWidget {
  final String studentCode;
  const StudentDashboardView({Key? key, required this.studentCode})
    : super(key: key);

  final List<_FeatureCardData> _features = const [
    _FeatureCardData('Tổng quan', Icons.dashboard),
    _FeatureCardData('Câu hỏi thường gặp', Icons.help_outline),
    _FeatureCardData('Đặt câu hỏi mới', Icons.edit_note),
    _FeatureCardData('Tải biểu mẫu', Icons.file_download),
    _FeatureCardData('Thông tin cá nhân', Icons.person),
    _FeatureCardData('Hộp thoại', Icons.chat),
    _FeatureCardData('Thông báo', Icons.notifications),
    _FeatureCardData('Cài đặt', Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào, mã sinh viên: $studentCode',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children:
                  _features.map((feature) {
                    return _FeatureCard(
                      title: feature.title,
                      icon: feature.icon,
                      onTap: () {
                        if (feature.title == 'Đặt câu hỏi mới') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NewQuestionForm(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Chức năng "${feature.title}" đang phát triển.',
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCardData {
  final String title;
  final IconData icon;

  const _FeatureCardData(this.title, this.icon);
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: const Color(0xFF2C3E50)),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
