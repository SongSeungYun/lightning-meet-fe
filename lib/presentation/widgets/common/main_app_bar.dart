import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_routes.dart';
import '../../../config/app_text_styles.dart';
import 'package:lightning_meet_fe/presentation/state/meeting/meeting_provider.dart';
import 'package:lightning_meet_fe/presentation/state/notification/notification_provider.dart';
import '../../state/auth/auth_provider.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: InkWell(
        onTap: () {
          // Pressing the logo also clears search and goes home.
          Provider.of<MeetingProvider>(context, listen: false).clearSearch();
          if (ModalRoute.of(context)?.settings.name != AppRoutes.home) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
          }
        },
        child: Text(
          'Lightning Meet',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
        ),
      ),
      actions: [
        _buildNavButton(context, '홈', AppRoutes.home),
        _buildNavButton(context, '내 모임', AppRoutes.myMeetings),
        _buildNavButton(context, '모임 만들기', AppRoutes.meetingCreate),
        _buildNotificationButton(context), // Add notification button
        _buildNavButton(context, '프로필', AppRoutes.profile),
        _buildLogoutButton(context),
      ],
      backgroundColor: Colors.white,
      elevation: 1,
    );
  }

  Widget _buildNavButton(BuildContext context, String label, String route) {
    // Special handling for Home button to clear search state
    if (route == AppRoutes.home) {
      return TextButton(
        onPressed: () {
          Provider.of<MeetingProvider>(context, listen: false).clearSearch();
          if (ModalRoute.of(context)?.settings.name != AppRoutes.home) {
             Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
          }
        },
        child: Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
      );
    }
    
    return TextButton(
      onPressed: () {
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.notifications);
              },
            ),
            if (provider.unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${provider.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
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
