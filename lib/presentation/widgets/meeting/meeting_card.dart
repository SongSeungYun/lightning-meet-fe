import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';

class MeetingCard extends StatelessWidget {
  final String title;
  final String location;
  final DateTime date;
  final int currentCount;
  final int maxCount;
  final VoidCallback? onTap;

  const MeetingCard({
    super.key,
    required this.title,
    required this.location,
    required this.date,
    required this.currentCount,
    required this.maxCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 7,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            // Left: Thumbnail (임시 박스)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.people, size: 40, color: AppColors.primary),
            ),
            const SizedBox(width: 16),

            // Right: Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 6),
                  Text(location, style: AppTextStyles.body),
                  const SizedBox(height: 6),
                  Text(
                    "${date.month}월 ${date.day}일 · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}",
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$currentCount / $maxCount 명 참여",
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
