import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../state/profile/profile_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  late TextEditingController _regionController;
  late TextEditingController _interestsController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<ProfileProvider>(context, listen: false).user;
    _nicknameController = TextEditingController(text: user?.nickname ?? '');
    _regionController = TextEditingController(text: user?.region ?? '');
    _interestsController = TextEditingController(text: user?.interests ?? '');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _regionController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  void _onSavePressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await Provider.of<ProfileProvider>(context, listen: false).updateUserProfile(
        nickname: _nicknameController.text,
        region: _regionController.text,
        interests: _interestsController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 성공적으로 업데이트되었습니다.')),
        );
        Navigator.pop(context); // Go back to profile page
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 업데이트 실패: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("프로필 수정")),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pageHorizontalPadding,
                vertical: 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      label: '닉네임',
                      hintText: '새 닉네임을 입력하세요',
                      controller: _nicknameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '닉네임을 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: '지역',
                      hintText: '활동 지역을 입력하세요',
                      controller: _regionController,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: '관심사 (쉼표로 구분)',
                      hintText: '운동, 스터디, 카페',
                      controller: _interestsController,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      label: '저장하기',
                      onPressed: _onSavePressed,
                      isPrimary: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
