import 'package:flutter/material.dart';
import 'main_app_bar.dart';

class MainLayout extends StatelessWidget {
  final Widget body;
  final String? title; // Optional title for specific pages

  const MainLayout({super.key, required this.body, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(), // Use the common app bar
      body: body,
      // You can add a common bottom navigation bar here if needed
      // bottomNavigationBar: ...
    );
  }
}
