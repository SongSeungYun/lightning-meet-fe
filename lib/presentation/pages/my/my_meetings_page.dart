import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/constants.dart';
import '../../widgets/common/main_layout.dart';
import '../../widgets/meeting/meeting_card.dart';
import '../../state/my/my_participating_meetings_provider.dart';
import '../../state/my/my_created_meetings_provider.dart';
import '../../../config/app_routes.dart';

class MyMeetingsPage extends StatefulWidget {
  const MyMeetingsPage({super.key});

  @override
  State<MyMeetingsPage> createState() => _MyMeetingsPageState();
}

class _MyMeetingsPageState extends State<MyMeetingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch data for both providers
      Provider.of<MyParticipatingMeetingsProvider>(context, listen: false).fetchMyParticipatingMeetings();
      Provider.of<MyCreatedMeetingsProvider>(context, listen: false).fetchMyCreatedMeetings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: '참여한 모임'),
                Tab(text: '만든 모임'),
              ],
              labelStyle: AppTextStyles.titleMedium,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildParticipatingMeetingsList(),
                  _buildCreatedMeetingsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipatingMeetingsList() {
    return Consumer<MyParticipatingMeetingsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.errorMessage != null) {
          return Center(child: Text('Error: ${provider.errorMessage}'));
        }
        if (provider.meetings.isEmpty) {
          return const Center(child: Text('참여 중인 모임이 없습니다.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.pageHorizontalPadding),
          itemCount: provider.meetings.length,
          itemBuilder: (context, index) {
            final meeting = provider.meetings[index];
            return MeetingCard(
              title: meeting.title,
              location: meeting.location,
              date: meeting.time,
              currentCount: meeting.currentParticipants,
              maxCount: meeting.maxParticipants,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.meetingDetail, arguments: meeting.id);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCreatedMeetingsList() {
    return Consumer<MyCreatedMeetingsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.errorMessage != null) {
          return Center(child: Text('Error: ${provider.errorMessage}'));
        }
        if (provider.meetings.isEmpty) {
          return const Center(child: Text('내가 만든 모임이 없습니다.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.pageHorizontalPadding),
          itemCount: provider.meetings.length,
          itemBuilder: (context, index) {
            final meeting = provider.meetings[index];
            return MeetingCard(
              title: meeting.title,
              location: meeting.location,
              date: meeting.time,
              currentCount: meeting.currentParticipants,
              maxCount: meeting.maxParticipants,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.meetingDetail, arguments: meeting.id);
              },
            );
          },
        );
      },
    );
  }
}
