import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/constants.dart';
import '../../../config/app_routes.dart';
import '../../../data/services/auth_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _onSignupPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_passwordController.text != _passwordConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    try {
      await _authService.signup(
        loginId: _emailController.text,
        password: _passwordController.text,
        email: _emailController.text,
        nickname: _nameController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 성공! 로그인해주세요.')),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _onGotoLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pageHorizontalPadding,
                vertical: 40,
              ),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.cardBorderRadius,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '회원가입',
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '이름과 이메일을 입력하고 새로운 번개모임 계정을 만들어보세요.',
                          style: AppTextStyles.body,
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          label: '이름',
                          hintText: '홍길동',
                          controller: _nameController,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: '이메일',
                          hintText: 'you@example.com',
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: '비밀번호',
                          hintText: '8자 이상 비밀번호',
                          obscureText: true,
                          controller: _passwordController,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: '비밀번호 확인',
                          hintText: '비밀번호를 한 번 더 입력하세요',
                          obscureText: true,
                          controller: _passwordConfirmController,
                        ),
                        const SizedBox(height: 16),
                        // 약관 동의 영역은 지금은 UI만 간단히
                        Row(
                          children: [
                            Checkbox(
                              value: true,
                              onChanged: (val) {
                                // TODO: 실제 상태관리 붙이기
                              },
                            ),
                            Expanded(
                              child: Text(
                                '서비스 이용약관 및 개인정보 처리방침에 동의합니다.',
                                style: AppTextStyles.body,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CustomButton(
                          label: '회원가입',
                          onPressed: _onSignupPressed,
                          isPrimary: true,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '이미 계정이 있으신가요?',
                              style: AppTextStyles.body,
                            ),
                            TextButton(
                              onPressed: _onGotoLogin,
                              child: const Text('로그인'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
