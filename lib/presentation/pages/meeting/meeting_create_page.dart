import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/constants.dart';
import '../../widgets/common/main_layout.dart';
import '../../../data/services/meeting_service.dart';
import 'package:provider/provider.dart';
import '../../state/meeting/meeting_provider.dart'; // To refresh meeting list

class MeetingCreatePage extends StatefulWidget {
  const MeetingCreatePage({super.key});

  @override
  State<MeetingCreatePage> createState() => _MeetingCreatePageState();
}

class _MeetingCreatePageState extends State<MeetingCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxCountController = TextEditingController();

  DateTime? _selectedDateTime; // Use _selectedDateTime for clarity

  final MeetingService _meetingService = MeetingService(); // Instantiate service

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _maxCountController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: now,
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? now),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _onCreatePressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDateTime == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('날짜와 시간을 선택해주세요.')),
        );
      }
      return;
    }

    try {
      await _meetingService.createMeeting(
        title: _titleController.text,
        content: _descController.text,
        region: _locationController.text, // Assuming location is region
        maxParticipants: int.parse(_maxCountController.text),
        eventAt: _selectedDateTime!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모임이 성공적으로 생성되었습니다.')),
        );
        // Optionally refresh the meeting list on the home page
        Provider.of<MeetingProvider>(context, listen: false).fetchMeetings();
        Navigator.pop(context); // Go back to previous page
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('모임 생성 실패: ${e.toString()}')),
        );
      }
    }
  }

  InputDecoration _input() => InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      );

  BoxDecoration _box() => BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      );

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pageHorizontalPadding,
                vertical: 24,
              ),
              children: [
                Text("새 모임 만들기", style: AppTextStyles.titleLarge),
                const SizedBox(height: 24),

                // 제목
                Text("제목", style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  decoration: _input(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '제목을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 설명
                Text("설명", style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descController,
                  decoration: _input(),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '설명을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 날짜/시간
                Text("날짜/시간", style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _pickDateTime,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: _box(),
                    child: Text(
                      _selectedDateTime == null
                          ? "날짜와 시간을 선택해주세요."
                          : "${_selectedDateTime!.month}월 ${_selectedDateTime!.day}일 ${_selectedDateTime!.hour}시 ${_selectedDateTime!.minute.toString().padLeft(2, '0')}분",
                      style: AppTextStyles.body,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 위치
                Text("위치", style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _locationController,
                  decoration: _input(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '위치를 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 정원
                Text("정원", style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _maxCountController,
                  decoration: _input(),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '정원을 입력해주세요.';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return '유효한 숫자를 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // create 버튼
                ElevatedButton(
                  onPressed: _onCreatePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "생성하기",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
