import 'package:flutter/material.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/constants.dart';
import '../../widgets/meeting/meeting_card.dart';

class MeetingListPage extends StatelessWidget {
  const MeetingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dummy = [
      {
        "title": "헬스 번개",
        "location": "서울 관악구",
        "date": DateTime.now().add(const Duration(hours: 3)),
        "current": 2,
        "max": 6
      },
      {
        "title": "카페에서 책 읽기",
        "location": "서울 송파구",
        "date": DateTime.now().add(const Duration(hours: 7)),
        "current": 4,
        "max": 10
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("전체 모임"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.pageHorizontalPadding,
              vertical: 24,
            ),
            children: [
              Text("전체 모임", style: AppTextStyles.titleLarge),
              const SizedBox(height: 24),

              ...dummy.map(
                (m) => MeetingCard(
                  title: m["title"],
                  location: m["location"],
                  date: m["date"],
                  currentCount: m["current"],
                  maxCount: m["max"],
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
