import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/constants.dart';
import '../../../config/app_routes.dart';
import '../../state/profile/profile_provider.dart';
import '../../widgets/common/main_layout.dart'; // Import MainLayout

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).fetchUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout( // Use MainLayout
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (profileProvider.errorMessage != null) {
            return Center(child: Text('Error: ${profileProvider.errorMessage}'));
          } else if (profileProvider.user == null) {
            return const Center(child: Text('프로필 정보를 불러올 수 없습니다.'));
          }

          final user = profileProvider.user!;

          return Center(
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
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.nickname, style: AppTextStyles.titleLarge),
                          Text(user.email, style: AppTextStyles.body),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text("로그인 ID", style: AppTextStyles.titleMedium),
                  Text(user.loginId, style: AppTextStyles.body),
                  const SizedBox(height: 16),

                  Text("지역", style: AppTextStyles.titleMedium),
                  Text(user.region ?? '미설정', style: AppTextStyles.body),
                  const SizedBox(height: 16),

                  Text("관심사", style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: (user.interests?.split(',') ?? [])
                        .map<Widget>((i) => Chip(
                              label: Text(i.trim()),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.border),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.editProfile);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("프로필 수정하기"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
