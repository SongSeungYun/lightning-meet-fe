import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/constants.dart';
import '../../widgets/meeting/meeting_card.dart';
import '../../../config/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 데이터
    final List<Map<String, dynamic>> mockMeetings = [
      {
        "title": "저녁에 다함께 러닝모임",
        "location": "서울 성동구",
        "date": DateTime.now().add(const Duration(hours: 5)),
        "current": 5,
        "max": 10
      },
      {
        "title": "카페에서 스터디 번개",
        "location": "서울 강남구",
        "date": DateTime.now().add(const Duration(hours: 2)),
        "current": 3,
        "max": 8
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lightning Meet"),
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
              // 검색창 ---------------------
              TextField(
                decoration: InputDecoration(
                  hintText: "어떤 번개모임을 찾으시나요?",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                onSubmitted: (_) {
                  Navigator.pushNamed(context, AppRoutes.meetingList);
                },
              ),
              const SizedBox(height: 32),

              // 곧 마감 모임 ---------------
              Text("⏳ 곧 마감인 모임", style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),

              ...mockMeetings.map(
                (m) => MeetingCard(
                  title: m["title"],
                  location: m["location"],
                  date: m["date"],
                  currentCount: m["current"],
                  maxCount: m["max"],
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.meetingDetail);
                  },
                ),
              ),

              const SizedBox(height: 32),

              // 추천 모임 ---------------
              Text("🔥 추천 모임", style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),

              ...mockMeetings.map(
                (m) => MeetingCard(
                  title: m["title"],
                  location: m["location"],
                  date: m["date"],
                  currentCount: m["current"],
                  maxCount: m["max"],
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.meetingDetail);
                  },
                ),
              ),

              const SizedBox(height: 32),

              // 전체 모임 ---------------
              Text("🌐 전체 모임", style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),

              ...mockMeetings.map(
                (m) => MeetingCard(
                  title: m["title"],
                  location: m["location"],
                  date: m["date"],
                  currentCount: m["current"],
                  maxCount: m["max"],
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.meetingDetail);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
