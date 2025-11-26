import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/constants.dart';
import '../../widgets/meeting/meeting_card.dart';
import '../../../config/app_routes.dart';
import '../../state/meeting/meeting_provider.dart';
import '../../state/auth/auth_provider.dart'; // For logout

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Fetch meetings when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MeetingProvider>(context, listen: false).fetchMeetings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lightning Meet"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: Consumer<MeetingProvider>(
        builder: (context, meetingProvider, child) {
          if (meetingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (meetingProvider.errorMessage != null) {
            return Center(child: Text('Error: ${meetingProvider.errorMessage}'));
          } else if (meetingProvider.meetings.isEmpty) {
            return const Center(child: Text('모임이 없습니다.'));
          }

          final meetings = meetingProvider.meetings;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pageHorizontalPadding,
                  vertical: 24,
                ),
                children: [
                  // 검색창 ---------------------
                  TextField(
                    decoration: InputDecoration(
                      hintText: "어떤 번개모임을 찾으시나요?",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onSubmitted: (_) {
                      Navigator.pushNamed(context, AppRoutes.meetingList);
                    },
                  ),
                  const SizedBox(height: 32),

                  // 전체 모임 ---------------
                  Text("🌐 전체 모임", style: AppTextStyles.titleMedium),
                  const SizedBox(height: 16),

                  ...meetings.map(
                    (m) => MeetingCard(
                      title: m.title,
                      location: m.region,
                      date: m.eventAt,
                      currentCount: m.currentParticipants,
                      maxCount: m.maxParticipants,
                      onTap: () {
                        // Pass meeting ID to detail page
                        Navigator.pushNamed(context, AppRoutes.meetingDetail, arguments: m.id);
                      },
                    ),
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
