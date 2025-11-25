import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/constants.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> user = {
      "name": "홍길동",
      "email": "gildong@example.com",
      "location": "서울 강남구",
      "interest": ["운동", "스터디", "카페"]
    };

    return Scaffold(
      appBar: AppBar(title: const Text("내 프로필")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.pageHorizontalPadding,
              vertical: 24,
            ),
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              const SizedBox(height: 20),

              Text("이름", style: AppTextStyles.titleMedium),
              Text(user["name"], style: AppTextStyles.body),
              const SizedBox(height: 16),

              Text("이메일", style: AppTextStyles.titleMedium),
              Text(user["email"], style: AppTextStyles.body),
              const SizedBox(height: 16),

              Text("지역", style: AppTextStyles.titleMedium),
              Text(user["location"], style: AppTextStyles.body),
              const SizedBox(height: 16),

              Text("관심사", style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: user["interest"]
                    .map<Widget>((i) => Chip(
                          label: Text(i),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.border),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("프로필 수정하기"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
