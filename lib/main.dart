import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/state/auth/auth_provider.dart';
import 'presentation/state/meeting/meeting_provider.dart';
import 'presentation/state/profile/profile_provider.dart';
import 'presentation/state/meeting/meeting_detail_provider.dart';
import 'presentation/state/my/my_created_meetings_provider.dart';
import 'presentation/state/my/my_participating_meetings_provider.dart';
import 'presentation/state/notification/notification_provider.dart';
import 'app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => MeetingProvider()),
        ChangeNotifierProvider(create: (_) => MeetingDetailProvider()),
        ChangeNotifierProvider(create: (_) => MyParticipatingMeetingsProvider()),
        ChangeNotifierProvider(create: (_) => MyCreatedMeetingsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const LightningMeetApp(),
    ),
  );
}