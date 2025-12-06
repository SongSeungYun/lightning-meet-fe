import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/constants.dart';
import '../../../config/app_routes.dart';
import '../../../data/models/meeting_model.dart';
import '../../state/meeting/meeting_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/main_layout.dart';
import '../../widgets/meeting/meeting_card.dart';

extension on Widget {
  SliverToBoxAdapter toSliver() => SliverToBoxAdapter(child: this);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final meetingProvider = Provider.of<MeetingProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      meetingProvider.fetchInitialMeetings();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (meetingProvider.hasMore && !meetingProvider.isLoadingMore) {
          meetingProvider.fetchMoreMeetings();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoryController.dispose();
    _regionController.dispose();
    _scrollController.dispose();
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
      body: Consumer<MeetingProvider>(
        builder: (context, provider, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: RefreshIndicator(
                onRefresh: () => provider.fetchInitialMeetings(), // Refresh both lists
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.pageHorizontalPadding,
                          vertical: 24,
                        ),
                        child: _buildSearchAndFilterBar(),
                      ),
                    ),
                    // Imminent Meetings Section
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppConstants.pageHorizontalPadding),
                            child: Text(
                              '⏰ 마감 임박!',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (provider.imminentMeetings.isNotEmpty)
                            SizedBox(
                              height: 200, // Fixed height for horizontal list
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: AppConstants.pageHorizontalPadding - 8), // Adjust padding for cards
                                itemCount: provider.imminentMeetings.length,
                                itemBuilder: (context, index) {
                                  final meeting = provider.imminentMeetings[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: SizedBox(
                                      width: 280, // Fixed width for each card
                                      child: MeetingCard(
                                        title: meeting.title,
                                        location: meeting.location,
                                        date: meeting.time,
                                        currentCount: meeting.currentParticipants,
                                        maxCount: meeting.maxParticipants,
                                        onTap: () {
                                          Navigator.pushNamed(context, AppRoutes.meetingDetail, arguments: meeting.id);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppConstants.pageHorizontalPadding),
                              child: Text(
                                '곧 마감인 모임이 없습니다.',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    
                    // Title for All Meetings
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.pageHorizontalPadding),
                        child: Text(
                          '⚡️ 전체 번개 모임',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16).toSliver(), // Extension to make SizedBox a Sliver
                    
                    if (provider.isLoading && provider.meetings.isEmpty)
                      const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (provider.errorMessage != null && provider.meetings.isEmpty)
                       SliverFillRemaining(
                        child: Center(child: Text(provider.errorMessage!)),
                      )
                    else if (provider.meetings.isEmpty)
                      const SliverFillRemaining(
                        child: Center(child: Text('표시할 모임이 없습니다.')),
                      )
                    else
                      _buildMeetingList(provider),
                    
                    if (provider.isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                  ],
                ),
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

  Widget _buildMeetingList(MeetingProvider provider) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final meeting = provider.meetings[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.pageHorizontalPadding, vertical: 8),
            child: MeetingCard(
              title: meeting.title,
              location: meeting.location,
              date: meeting.time,
              currentCount: meeting.currentParticipants,
              maxCount: meeting.maxParticipants,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.meetingDetail, arguments: meeting.id);
              },
            ),
          );
        },
        childCount: provider.meetings.length,
      ),
    );
  }
}