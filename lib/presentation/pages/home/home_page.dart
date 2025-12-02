import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/constants.dart';
import '../../widgets/meeting/meeting_card.dart';
import '../../../config/app_routes.dart';
import '../../state/meeting/meeting_provider.dart';
import '../../state/profile/profile_provider.dart';
import '../../widgets/common/main_layout.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../../data/models/meeting_model.dart'; // Add this import

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
      // Fetch both meetings and user profile when the page initializes
      Provider.of<MeetingProvider>(context, listen: false).fetchMeetings();
      Provider.of<ProfileProvider>(context, listen: false).fetchUserProfile();
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
      body: Consumer2<MeetingProvider, ProfileProvider>( // Use Consumer2 to get both providers
        builder: (context, meetingProvider, profileProvider, child) {
          if (meetingProvider.isLoading || profileProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (meetingProvider.errorMessage != null) {
            return Center(child: Text('Meeting Error: ${meetingProvider.errorMessage}'));
          }
           if (profileProvider.errorMessage != null) {
            return Center(child: Text('Profile Error: ${profileProvider.errorMessage}'));
          }

          final allMeetings = meetingProvider.meetings;
          final user = profileProvider.user;

          // 2. "곧 마감인 모임" 필터링: 현재 시간으로부터 3시간 이내 마감
          final soonToCloseMeetings = allMeetings.where((m) {
            return m.time.isAfter(DateTime.now()) && m.time.isBefore(DateTime.now().add(const Duration(hours: 3)));
          }).toList();
          
          // 3. "추천 모임" 필터링: 사용자 지역 및 관심사 일치
          final recommendedMeetings = user != null ? allMeetings.where((m) {
            final userRegion = user.region ?? '';
            final userInterests = user.interests?.split(',') ?? [];
            final meetingKeywords = m.keywords?.split(',') ?? [];
            
            bool regionMatch = userRegion.isNotEmpty && m.region == userRegion;
            bool interestMatch = userInterests.any((interest) => meetingKeywords.contains(interest.trim()));

            return regionMatch && interestMatch;
          }).toList() : <Meeting>[];

          // 4. "전체 모임" 필터링: 사용자 지역과 일치
          final allMeetingsInRegion = user != null ? allMeetings.where((m) {
             final userRegion = user.region ?? '';
             return userRegion.isNotEmpty && m.region == userRegion;
          }).toList() : allMeetings;


          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pageHorizontalPadding,
                  vertical: 24,
                ),
                children: [
                  // 검색창
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

                  // 곧 마감인 모임
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
                    const Center(child: Text('곧 마감되는 모임이 없습니다.')),
                  const SizedBox(height: 32),

                  // 추천 모임
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
                    const Center(child: Text('추천 모임이 없습니다. 관심사와 지역을 설정해보세요.')),
                  const SizedBox(height: 32),

                  // 전체 모임
                  Text("🌐 전체 모임 (${user?.region ?? '모든 지역'})", style: AppTextStyles.titleMedium),
                  const SizedBox(height: 16),

                  ...allMeetingsInRegion.map((m) => MeetingCard(
                    title: m.title,
                    location: m.location,
                    date: m.time,
                    currentCount: m.currentParticipants,
                    maxCount: m.maxParticipants,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.meetingDetail, arguments: m.id);
                    },
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
