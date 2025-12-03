import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/constants.dart';
import '../../widgets/meeting/meeting_card.dart';
import '../../../config/app_routes.dart';
import '../../state/meeting/meeting_provider.dart';
import '../../state/profile/profile_provider.dart';
import '../../state/my/my_participating_meetings_provider.dart';
import '../../state/notification/notification_provider.dart';
import '../../widgets/common/main_layout.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../../data/models/meeting_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch all necessary data when the page initializes
      Provider.of<MeetingProvider>(context, listen: false).fetchMeetings();
      Provider.of<ProfileProvider>(context, listen: false).fetchUserProfile();
      Provider.of<MyParticipatingMeetingsProvider>(context, listen: false).fetchMyParticipatingMeetings();
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoryController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  void _performSearch() {
    Provider.of<MeetingProvider>(context, listen: false).searchMeetings(
      keyword: _searchController.text,
      category: _categoryController.text,
      region: _regionController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: Consumer4<MeetingProvider, ProfileProvider, MyParticipatingMeetingsProvider, NotificationProvider>(
        builder: (context, meetingProvider, profileProvider, participatingProvider, notificationProvider, child) {
          final searchAndFilterBar = _buildSearchAndFilterBar();

          // Show a single loading indicator until all initial data is loaded
          if (meetingProvider.isLoading || profileProvider.isLoading || participatingProvider.isLoading || notificationProvider.isLoading) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.pageHorizontalPadding),
                  child: searchAndFilterBar,
                ),
                const Expanded(child: Center(child: CircularProgressIndicator())),
              ],
            );
          }
          // Show error if any provider has an error
          if (meetingProvider.errorMessage != null) {
            return Center(child: Text('모임 로딩 오류: ${meetingProvider.errorMessage}'));
          }
           if (profileProvider.errorMessage != null) {
            return Center(child: Text('프로필 로딩 오류: ${profileProvider.errorMessage}'));
          }
           if (participatingProvider.errorMessage != null) {
            return Center(child: Text('참여 모임 로딩 오류: ${participatingProvider.errorMessage}'));
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pageHorizontalPadding,
                  vertical: 24,
                ),
                children: [
                  searchAndFilterBar,
                  const SizedBox(height: 32),
                  if (meetingProvider.isSearchActive)
                    _buildSearchResultsView(meetingProvider)
                  else
                    _buildInitialView(meetingProvider, profileProvider, participatingProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildInitialView(MeetingProvider meetingProvider, ProfileProvider profileProvider, MyParticipatingMeetingsProvider participatingProvider) {
    final fullList = meetingProvider.fullMeetingList;
    final user = profileProvider.user;
    final participatingMeetingIds = participatingProvider.meetings.map((m) => m.id).toSet();

    final soonToCloseMeetings = fullList.where((m) {
      return m.time.isAfter(DateTime.now()) && m.time.isBefore(DateTime.now().add(const Duration(hours: 3)));
    }).toList();
    
    final recommendedMeetings = user != null ? fullList.where((m) {
      final userRegion = user.region ?? '';
      final userInterests = user.interests?.split(',') ?? [];
      final meetingKeywords = m.keywords?.split(',') ?? [];
      
      bool regionMatch = userRegion.isNotEmpty && m.region == userRegion;
      bool interestMatch = userInterests.any((interest) => meetingKeywords.contains(interest.trim()));
      bool notParticipating = !participatingMeetingIds.contains(m.id);

      return regionMatch && interestMatch && notParticipating;
    }).toList() : <Meeting>[];

    final allMeetingsInRegion = (user?.region != null && user!.region!.isNotEmpty) 
      ? fullList.where((m) => m.region == user.region).toList() 
      : <Meeting>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("⏳ 곧 마감인 모임", style: AppTextStyles.titleMedium),
        const SizedBox(height: 16),
        if (soonToCloseMeetings.isNotEmpty)
          ...soonToCloseMeetings.map((m) => MeetingCard(
            title: m.title,
            location: m.location,
            date: m.time,
            currentCount: m.currentParticipants,
            maxCount: m.maxParticipants,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.meetingDetail, arguments: m.id);
            },
          ))
        else
          const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('곧 마감되는 모임이 없습니다.'))),
        const SizedBox(height: 32),

        Text("🔥 추천 모임", style: AppTextStyles.titleMedium),
        const SizedBox(height: 16),
        if (recommendedMeetings.isNotEmpty)
          ...recommendedMeetings.map((m) => MeetingCard(
            title: m.title,
            location: m.location,
            date: m.time,
            currentCount: m.currentParticipants,
            maxCount: m.maxParticipants,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.meetingDetail, arguments: m.id);
            },
          ))
        else
          const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('추천 모임이 없습니다. 관심사와 지역을 설정해보세요.'))),
        const SizedBox(height: 32),

        Text("🌐 전체 모임 (${user?.region ?? '지역 정보 로딩중...'})", style: AppTextStyles.titleMedium),
        const SizedBox(height: 16),
        if (allMeetingsInRegion.isNotEmpty)
          ...allMeetingsInRegion.map((m) => MeetingCard(
            title: m.title,
            location: m.location,
            date: m.time,
            currentCount: m.currentParticipants,
            maxCount: m.maxParticipants,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.meetingDetail, arguments: m.id);
            },
          ))
        else
          const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('해당 지역의 모임이 없습니다.'))),
      ],
    );
  }

  Widget _buildSearchResultsView(MeetingProvider meetingProvider) {
    final meetings = meetingProvider.meetings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("🔍 검색 결과 (${meetings.length}건)", style: AppTextStyles.titleMedium),
            TextButton(
              onPressed: () => context.read<MeetingProvider>().clearSearch(),
              child: const Text('검색 초기화'),
            )
          ],
        ),
        const SizedBox(height: 16),
        if (meetings.isNotEmpty)
          ...meetings.map((m) => MeetingCard(
            title: m.title,
            location: m.location,
            date: m.time,
            currentCount: m.currentParticipants,
            maxCount: m.maxParticipants,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.meetingDetail, arguments: m.id);
            },
          ))
        else
          const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('검색 결과에 맞는 모임이 없습니다.'))),
      ],
    );
  }
}