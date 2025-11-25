import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/app_routes.dart';

class CommonLayout extends StatelessWidget {
  final Widget child;

  const CommonLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text("⚡ Lightning Meet",
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 32),

                _menu(context, "홈", AppRoutes.home),
                _menu(context, "전체 모임", AppRoutes.meetingList),
                _menu(context, "내 모임", AppRoutes.myMeetings),
                _menu(context, "프로필", AppRoutes.profile),
                _menu(context, "관리자", AppRoutes.adminDashboard),
              ],
            ),
          ),

          // Body
          Expanded(
            child: Container(
              color: AppColors.background,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menu(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}
