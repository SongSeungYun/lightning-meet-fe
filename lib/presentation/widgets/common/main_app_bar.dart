import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_routes.dart';
import '../../../config/app_text_styles.dart';
import '../../state/auth/auth_provider.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Removes the back button
      title: Text(
        'Lightning Meet', // Logo
        style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
      ),
      actions: [
        _buildNavButton(context, '홈', AppRoutes.home),
        _buildNavButton(context, '내 모임', AppRoutes.myMeetings),
        _buildNavButton(context, '모임 만들기', AppRoutes.meetingCreate),
        _buildNavButton(context, '프로필', AppRoutes.profile),
        _buildLogoutButton(context),
      ],
      backgroundColor: Colors.white,
      elevation: 1,
    );
  }

  Widget _buildNavButton(BuildContext context, String label, String route) {
    return TextButton(
      onPressed: () {
        // Avoid pushing the same route again
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.read<AuthProvider>().logout();
      },
      child: Text('로그아웃', style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
