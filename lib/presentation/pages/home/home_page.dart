import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/constants.dart';
import '../../widgets/meeting/meeting_card.dart';
import '../../../config/app_routes.dart';
import '../../state/meeting/meeting_provider.dart';
import '../../widgets/common/main_layout.dart'; // Import MainLayout
import '../../widgets/common/custom_text_field.dart'; // For search input
import '../../widgets/common/custom_button.dart'; // For search button

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController(); // New controller
  final TextEditingController _regionController = TextEditingController(); // New controller

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MeetingProvider>(context, listen: false).fetchMeetings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoryController.dispose(); // Dispose new controller
    _regionController.dispose(); // Dispose new controller
    super.dispose();
  }

  void _performSearch() {
    // TODO: 검색 로직 구현 (키워드, 카테고리, 지역 조합)
    print('Search: ${_searchController.text}, Category: ${_categoryController.text}, Region: ${_regionController.text}');
    // For now, just refetch all meetings
    Provider.of<MeetingProvider>(context, listen: false).fetchMeetings();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout( // Use MainLayout instead of Scaffold
      body: Consumer<MeetingProvider>(
        builder: (context, meetingProvider, child) {
          if (meetingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (meetingProvider.errorMessage != null) {
            return Center(child: Text('Error: ${meetingProvider.errorMessage}'));
          }

          final allMeetings = meetingProvider.meetings;
          // TODO: 실제 데이터에 따라 '곧 마감인 모임', '추천 모임' 필터링 로직 구현 필요
          final soonToCloseMeetings = allMeetings.take(2).toList(); // Example filter
          final recommendedMeetings = allMeetings.skip(2).take(2).toList(); // Example filter

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
                  CustomTextField(
                    label: '검색',
                    controller: _searchController,
                    hintText: "어떤 번개모임을 찾으시나요?",
                    prefixIcon: const Icon(Icons.search),
                    onSubmitted: (_) => _performSearch(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: '카테고리',
                          controller: _categoryController,
                          hintText: '카테고리 입력',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          label: '지역',
                          controller: _regionController,
                          hintText: '지역 입력',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: '검색',
                    onPressed: _performSearch,
                    isPrimary: true,
                  ),
                  const SizedBox(height: 32),

                  // 곧 마감인 모임 ---------------
                  if (soonToCloseMeetings.isNotEmpty) ...[
                    Text("⏳ 곧 마감인 모임", style: AppTextStyles.titleMedium),
                    const SizedBox(height: 16),
                    ...soonToCloseMeetings.map(
                      (m) => MeetingCard(
                        title: m.title,
                        location: m.region,
                        date: m.eventAt,
                        currentCount: m.currentParticipants,
                        maxCount: m.maxParticipants,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.meetingDetail, arguments: m.id);
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // 추천 모임 ---------------
                  if (recommendedMeetings.isNotEmpty) ...[
                    Text("🔥 추천 모임", style: AppTextStyles.titleMedium),
                    const SizedBox(height: 16),
                    ...recommendedMeetings.map(
                      (m) => MeetingCard(
                        title: m.title,
                        location: m.region,
                        date: m.eventAt,
                        currentCount: m.currentParticipants,
                        maxCount: m.maxParticipants,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.meetingDetail, arguments: m.id);
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // 전체 모임 ---------------
                  Text("🌐 전체 모임", style: AppTextStyles.titleMedium),
                  const SizedBox(height: 16),

                  ...allMeetings.map(
                    (m) => MeetingCard(
                      title: m.title,
                      location: m.region,
                      date: m.eventAt,
                      currentCount: m.currentParticipants,
                      maxCount: m.maxParticipants,
                      onTap: () {
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
