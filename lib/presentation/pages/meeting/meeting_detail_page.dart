import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/constants.dart';

class MeetingDetailPage extends StatelessWidget {
  const MeetingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 데이터
    final Map<String, dynamic> meeting = {

      "title": "저녁 조깅 번개",
      "location": "서울 성동구 뚝섬유원지역",
      "description": "퇴근 후 함께 뛰고 스트레스 날려요!\n초보자도 환영!",
      "date": DateTime.now().add(const Duration(hours: 3)),
      "current": 5,
      "max": 10,
      "participants": [
        "철수", "영희", "민수", "아라", "수진",
      ],
      "comments": [
        {"author": "민수", "content": "혹시 속도는 어느 정도인가요?"},
        {"author": "아라", "content": "새 인원도 참가 가능할까요?"},
      ]
    };

    return Scaffold(
      appBar: AppBar(title: Text(meeting["title"])),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.pageHorizontalPadding,
              vertical: 24,
            ),
            children: [
              // 제목
              Text(meeting["title"], style: AppTextStyles.titleLarge),

              const SizedBox(height: 16),

              // 일정
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    "${meeting['date'].month}월 ${meeting['date'].day}일 · ${meeting['date'].hour}:${meeting['date'].minute}",
                    style: AppTextStyles.body,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 위치
              Row(
                children: [
                  const Icon(Icons.place, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(meeting["location"], style: AppTextStyles.body),
                ],
              ),

              const SizedBox(height: 20),

              // 설명
              Text("모임 설명", style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(meeting["description"], style: AppTextStyles.body),
              ),

              const SizedBox(height: 24),

              // 참가 현황
              Text("참여 현황", style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Text(
                "${meeting['current']} / ${meeting['max']} 명 참여중",
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 12,
                children: meeting["participants"]
                    .map<Widget>(
                      (p) => Chip(
                        label: Text(p),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.border),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 24),

              // 참가 버튼
              ElevatedButton(
                onPressed: () {
                  // TODO: 참여 API 연동 예정
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("참여하기"),
              ),

              const SizedBox(height: 32),

              // 댓글 섹션
              Text("문의 / 댓글", style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),

              ...meeting["comments"].map<Widget>((c) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c["author"], style: AppTextStyles.titleMedium),
                      const SizedBox(height: 4),
                      Text(c["content"], style: AppTextStyles.body),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 16),

              TextField(
                decoration: InputDecoration(
                  hintText: "문의 내용을 입력하세요",
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      // TODO: 문의 등록 API 연결 예정
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
