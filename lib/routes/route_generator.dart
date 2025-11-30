import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_routes.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/signup_page.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/meeting/meeting_list_page.dart';
import '../presentation/pages/meeting/meeting_detail_page.dart';
import '../presentation/pages/meeting/meeting_create_page.dart';
import '../presentation/pages/meeting/meeting_edit_page.dart';
import '../presentation/pages/my/my_meetings_page.dart';
import '../presentation/pages/my/my_created_meetings_page.dart';
import '../presentation/pages/my/profile_page.dart';
import '../presentation/pages/my/edit_profile_page.dart';
import '../presentation/pages/admin/admin_dashboard.dart';
import '../presentation/pages/admin/admin_users_page.dart';
import '../presentation/pages/admin/admin_reports_page.dart';
import '../presentation/state/meeting/meeting_provider.dart';
import '../presentation/state/profile/profile_provider.dart';
import '../presentation/state/meeting/meeting_detail_provider.dart';
import '../presentation/state/my/my_created_meetings_provider.dart';
import '../presentation/state/my/my_participating_meetings_provider.dart'; // Add this import

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return _page(const LoginPage());
      case AppRoutes.signup:
        return _page(const SignupPage());
      case AppRoutes.home:
        return _page(
          ChangeNotifierProvider(
            create: (context) => MeetingProvider(),
            child: const HomePage(),
          ),
        );

      case AppRoutes.meetingList:
        return _page(const MeetingListPage());
      case AppRoutes.meetingDetail:
        final args = settings.arguments;
        if (args is int) {
          return _page(
            ChangeNotifierProvider(
              create: (context) => MeetingDetailProvider(),
              child: MeetingDetailPage(meetingId: args),
            ),
          );
        }
        return _page(const Text('Error: Invalid meeting ID'));
      case AppRoutes.meetingCreate:
        return _page(const MeetingCreatePage());
      case AppRoutes.meetingEdit:
        final args = settings.arguments;
        if (args is int) {
          return _page(MeetingEditPage(meetingId: args));
        }
        return _page(const Text('Error: Invalid meeting ID'));
      case AppRoutes.myMeetings:
        return _page(
          ChangeNotifierProvider(
            create: (context) => MyParticipatingMeetingsProvider(),
            child: const MyMeetingsPage(),
          ),
        );
      case AppRoutes.myCreatedMeetings:
        return _page(
          ChangeNotifierProvider(
            create: (context) => MyCreatedMeetingsProvider(),
            child: const MyCreatedMeetingsPage(),
          ),
        );
      case AppRoutes.profile:
        return _page(
          ChangeNotifierProvider(
            create: (context) => ProfileProvider(),
            child: const ProfilePage(),
          ),
        );
      case AppRoutes.editProfile:
        return _page(const EditProfilePage());

      case AppRoutes.adminDashboard:
        return _page(const AdminDashboardPage());
      case AppRoutes.adminUsers:
        return _page(const AdminUsersPage());
      case AppRoutes.adminReports:
        return _page(const AdminReportsPage());

      default:
        return _page(
          const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }

  static MaterialPageRoute _page(Widget child) {
    return MaterialPageRoute(builder: (_) => child);
  }
}
