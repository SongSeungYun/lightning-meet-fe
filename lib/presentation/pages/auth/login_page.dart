import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/constants.dart';
import '../../../config/app_routes.dart';
import '../../state/auth/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      await context.read<AuthProvider>().login(
            _emailController.text,
            _passwordController.text,
          );
      // Navigation is handled by the Consumer in app.dart
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _onGotoSignup() {
    Navigator.pushNamed(context, AppRoutes.signup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
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
                          '번개모임에 오신 것을 환영합니다',
                          style: AppTextStyles.titleLarge,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '로그인 후 근처의 번개모임을 빠르게 찾아보세요.',
                          style: AppTextStyles.body,
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          label: '이메일',
                          hintText: 'you@example.com',
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: '비밀번호',
                          hintText: '비밀번호를 입력하세요',
                          obscureText: true,
                          controller: _passwordController,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: 비밀번호 찾기 페이지 만들면 연결
                            },
                            child: const Text('비밀번호를 잊으셨나요?'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomButton(
                          label: '로그인',
                          onPressed: _onLoginPressed,
                          isPrimary: true,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '아직 계정이 없으신가요?',
                              style: AppTextStyles.body,
                            ),
                            TextButton(
                              onPressed: _onGotoSignup,
                              child: const Text('회원가입'),
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
