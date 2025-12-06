import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/home_page.dart';
import 'login_page.dart';
import '../../state/auth/auth_provider.dart';
import '../../state/meeting/meeting_provider.dart'; // Import MeetingProvider

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isLoading) {
          // Checking token state
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (auth.isLoggedIn) {
          // User is logged in, provide MeetingProvider and show home page
          return ChangeNotifierProvider(
            create: (context) => MeetingProvider(),
            child: const HomePage(),
          );
        } else {
          // User is not logged in, show login page
          return const LoginPage();
        }
      },
    );
  }
}
