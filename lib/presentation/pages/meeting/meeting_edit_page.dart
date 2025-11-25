import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/constants.dart';

class MeetingEditPage extends StatefulWidget {
  const MeetingEditPage({super.key});

  @override
  State<MeetingEditPage> createState() => _MeetingEditPageState();
}

class _MeetingEditPageState extends State<MeetingEditPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxCountController = TextEditingController();

  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("모임 수정")),
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
                ),
                const SizedBox(height: 20),

                // 설명
                Text("설명", style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descController,
                  decoration: _input(),
                  maxLines: 4,
                ),
                const SizedBox(height: 20),

                // 날짜/시간
                Text("날짜/시간", style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: _box(),
                    child: Text(
                      selectedDate == null
                          ? "날짜 선택"
                          : "${selectedDate!.month}월 ${selectedDate!.day}일 ${selectedDate!.hour}:${selectedDate!.minute.toString().padLeft(2, '0')}",
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text("위치", style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _locationController,
                  decoration: _input(),
                ),
                const SizedBox(height: 20),

                Text("정원", style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _maxCountController,
                  decoration: _input(),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                // create 버튼
                ElevatedButton(
                  onPressed: () {
                    // TODO: API 연동
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("생성하기"),
                )
              ],
            ),
          ),
        ),
      ),
    );
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

  Future<void> _pickDate() async {
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
        initialTime: const TimeOfDay(hour: 18, minute: 0),
      );

      if (time != null) {
        setState(() {
          selectedDate =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }
}
