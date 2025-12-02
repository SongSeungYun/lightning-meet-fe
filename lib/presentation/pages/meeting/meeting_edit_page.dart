import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/constants.dart';
import '../../widgets/common/main_layout.dart';
import '../../../data/services/meeting_service.dart';
import 'package:provider/provider.dart';
import '../../state/meeting/meeting_provider.dart';

class MeetingEditPage extends StatefulWidget {
  final int meetingId;
  const MeetingEditPage({super.key, required this.meetingId});

  @override
  State<MeetingEditPage> createState() => _MeetingEditPageState();
}

class _MeetingEditPageState extends State<MeetingEditPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _regionController = TextEditingController(); // Renamed
  final _locationController = TextEditingController(); // New
  final _keywordsController = TextEditingController(); // New
  final _maxCountController = TextEditingController();

  DateTime? _selectedDateTime;
  bool _isLoading = true;
  String? _errorMessage;

  final MeetingService _meetingService = MeetingService();

  @override
  void initState() {
    super.initState();
    _loadMeetingData();
  }

  Future<void> _loadMeetingData() async {
    try {
      final meeting = await _meetingService.getMeetingDetail(widget.meetingId);
      setState(() {
        _titleController.text = meeting.title;
        _descController.text = meeting.content;
        _regionController.text = meeting.region;
        _locationController.text = meeting.location;
        _keywordsController.text = meeting.keywords ?? '';
        _maxCountController.text = meeting.maxParticipants.toString();
        _selectedDateTime = meeting.time;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _regionController.dispose();
    _locationController.dispose();
    _keywordsController.dispose();
    _maxCountController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 30)), // Allow past dates for editing
      lastDate: now.add(const Duration(days: 365)),
      initialDate: _selectedDateTime ?? now,
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

  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await _meetingService.updateMeeting(
        meetingId: widget.meetingId,
        title: _titleController.text,
        content: _descController.text,
        region: _regionController.text,
        location: _locationController.text,
        keywords: _keywordsController.text,
        maxParticipants: int.parse(_maxCountController.text),
        time: _selectedDateTime,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모임이 성공적으로 수정되었습니다.')),
        );
        Provider.of<MeetingProvider>(context, listen: false).fetchMeetings();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('모임 수정 실패: ${e.toString()}')),
        );
      }
    }
  }

  InputDecoration _input({String? hintText}) => InputDecoration(
        hintText: hintText,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : Center(
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
                          Text("모임 수정", style: AppTextStyles.titleLarge),
                          const SizedBox(height: 24),

                          Text("제목", style: AppTextStyles.titleMedium),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _titleController,
                            decoration: _input(hintText: "모임의 제목을 알려주세요."),
                            validator: (value) => (value?.isEmpty ?? true) ? '제목을 입력해주세요.' : null,
                          ),
                          const SizedBox(height: 20),

                          Text("설명", style: AppTextStyles.titleMedium),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _descController,
                            decoration: _input(hintText: "모임에 대해 자세하게 설명해주세요."),
                            maxLines: 4,
                            validator: (value) => (value?.isEmpty ?? true) ? '설명을 입력해주세요.' : null,
                          ),
                          const SizedBox(height: 20),

                          Text("지역", style: AppTextStyles.titleMedium),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _regionController,
                            decoration: _input(hintText: "예: 서울 강남구"),
                            validator: (value) => (value?.isEmpty ?? true) ? '지역을 입력해주세요.' : null,
                          ),
                          const SizedBox(height: 20),

                          Text("상세 장소", style: AppTextStyles.titleMedium),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _locationController,
                            decoration: _input(hintText: "예: 강남역 10번 출구"),
                            validator: (value) => (value?.isEmpty ?? true) ? '상세 장소를 입력해주세요.' : null,
                          ),
                          const SizedBox(height: 20),

                          Text("검색 키워드", style: AppTextStyles.titleMedium),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _keywordsController,
                            decoration: _input(hintText: "쉼표(,)로 구분하여 입력해주세요."),
                          ),
                          const SizedBox(height: 20),
                          
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

                          Text("정원", style: AppTextStyles.titleMedium),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _maxCountController,
                            decoration: _input(hintText: "최대 참여 인원을 입력하세요."),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return '정원을 입력해주세요.';
                              if (int.tryParse(value) == null || int.parse(value) <= 0) return '유효한 숫자를 입력해주세요.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          ElevatedButton(
                            onPressed: _onSavePressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "저장하기",
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
