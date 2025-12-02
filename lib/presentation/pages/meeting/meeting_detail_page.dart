import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/constants.dart';
import '../../widgets/common/main_layout.dart';
import '../../state/meeting/meeting_detail_provider.dart';
import '../../../data/models/meeting_model.dart';
import '../../../config/app_routes.dart';

class MeetingDetailPage extends StatefulWidget {
  final int meetingId;
  const MeetingDetailPage({super.key, required this.meetingId});

  @override
  State<MeetingDetailPage> createState() => _MeetingDetailPageState();
}

class _MeetingDetailPageState extends State<MeetingDetailPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MeetingDetailProvider>(context, listen: false)
          .fetchMeetingDetail(widget.meetingId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _onJoinPressed(MeetingDetailProvider provider, int meetingId) async {
    try {
      await provider.joinMeeting(meetingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모임에 참여했습니다!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('참여 실패: ${e.toString()}')),
        );
      }
    }
  }

  void _onLeavePressed(MeetingDetailProvider provider, int meetingId) async {
    try {
      await provider.leaveMeeting(meetingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모임에서 나갔습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('나가기 실패: ${e.toString()}')),
        );
      }
    }
  }

  void _onCommentSubmitted() {
    // TODO: 댓글 제출 API 연동
    print('댓글 제출: ${_commentController.text}');
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout( // Use MainLayout
      body: Consumer<MeetingDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.errorMessage != null) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          } else if (provider.meeting == null) {
            return const Center(child: Text('모임 정보를 찾을 수 없습니다.'));
          }

          final meeting = provider.meeting!;
          // TODO: 현재 로그인한 사용자가 이 모임에 참여했는지 여부 확인
          bool isParticipating = false; // Placeholder

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pageHorizontalPadding,
                  vertical: 24,
                ),
                children: [
                  // 제목
                  Text(meeting.title, style: AppTextStyles.titleLarge),

                  const SizedBox(height: 16),

                  // 일정
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        "${meeting.time.month}월 ${meeting.time.day}일 · ${meeting.time.hour}:${meeting.time.minute.toString().padLeft(2, '0')}",
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 위치
                  Row(
                    children: [
                      const Icon(Icons.place, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(meeting.location, style: AppTextStyles.body),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 지역
                  Row(
                    children: [
                      const Icon(Icons.map_outlined, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(meeting.region, style: AppTextStyles.body),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 설명
                  Text("모임 설명", style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(meeting.content, style: AppTextStyles.body),
                  ),

                  const SizedBox(height: 24),

                  // 참가 현황
                  Text("참여 현황", style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    "${meeting.currentParticipants} / ${meeting.maxParticipants} 명 참여중",
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 12),

                  // TODO: 실제 참여자 목록 표시
                  // Wrap(
                  //   spacing: 12,
                  //   children: meeting.participants.map<Widget>(
                  //     (p) => Chip(
                  //       label: Text(p),
                  //       backgroundColor: Colors.white,
                  //       side: const BorderSide(color: AppColors.border),
                  //     ),
                  //   ).toList(),
                  // ),

                  const SizedBox(height: 24),

                  // 참여/나가기 버튼
                  ElevatedButton(
                    onPressed: isParticipating
                        ? () => _onLeavePressed(provider, meeting.id)
                        : () => _onJoinPressed(provider, meeting.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isParticipating ? AppColors.error : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(isParticipating ? "모임 나가기" : "참여하기"),
                  ),

                  const SizedBox(height: 32),

                  // 댓글 섹션
                  Text("문의 / 댓글", style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),

                  // TODO: 실제 댓글 목록 표시
                  // ...meeting["comments"].map<Widget>((c) {
                  //   return Container(
                  //     margin: const EdgeInsets.only(bottom: 12),
                  //     padding: const EdgeInsets.all(14),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       border: Border.all(color: AppColors.border),
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(c["author"], style: AppTextStyles.titleMedium),
                  //         const SizedBox(height: 4),
                  //         Text(c["content"], style: AppTextStyles.body),
                  //       ],
                  //     ),
                  //   );
                  // }).toList(),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "문의 내용을 입력하세요",
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _onCommentSubmitted,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
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
