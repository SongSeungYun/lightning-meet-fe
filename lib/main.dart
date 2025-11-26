import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/state/auth/auth_provider.dart';
import 'app.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const LightningMeetApp(),
    ),
  );
}
