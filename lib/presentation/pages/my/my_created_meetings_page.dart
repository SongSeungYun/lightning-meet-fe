import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/constants.dart';
import '../../widgets/common/main_layout.dart';
import '../../widgets/meeting/meeting_card.dart';
import '../../state/my/my_created_meetings_provider.dart';
import '../../../config/app_routes.dart';

class MyCreatedMeetingsPage extends StatefulWidget {
  const MyCreatedMeetingsPage({super.key});

  @override
  State<MyCreatedMeetingsPage> createState() => _MyCreatedMeetingsPageState();
}

class _MyCreatedMeetingsPageState extends State<MyCreatedMeetingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MyCreatedMeetingsProvider>(context, listen: false).fetchMyCreatedMeetings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: Consumer<MyCreatedMeetingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.errorMessage != null) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          } else if (provider.meetings.isEmpty) {
            return const Center(child: Text('내가 만든 모임이 없습니다.'));
          }

          final meetings = provider.meetings;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pageHorizontalPadding,
                  vertical: 24,
                ),
                children: [
                  Text("내가 만든 모임", style: AppTextStyles.titleLarge),
                  const SizedBox(height: 24),
                  ...meetings.map(
                    (m) => MeetingCard(
                      title: m.title,
                      location: m.location,
                      date: m.time,
                      currentCount: m.currentParticipants,
                      maxCount: m.maxParticipants,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.meetingDetail, arguments: m.id);
                      },
                    ),
                  ).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
