import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection_container.dart';
import '../../data/models/dto/auth_request_dto.dart';
import '../../data/services/api_client.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/common/bloc_status.dart';
import '../widgets/buttons/btnRegisLogin.dart';
import '../widgets/register/register_otp_step.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static const routeName = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

enum RegisterStep { form, otp }

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  RegisterStep _currentStep = RegisterStep.form;
  DateTime? _otpExpiresAt;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (!_submitting) return;
            if (state.status.isFailure) {
              setState(() => _submitting = false);
              final message = state.errorMessage ?? 'Đăng ký thất bại.';
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            } else if (state.status.isSuccess && state.isAuthenticated) {
              setState(() => _submitting = false);
              Navigator.of(context).pop();
            }
          },
          child: _currentStep == RegisterStep.form
              ? _buildFormStep(theme)
              : _buildOtpStep(theme),
        ),
      ),
    );
  }

  Widget _buildFormStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.maybePop(context),
            ),
            const SizedBox(height: 8),
            Text(
              'Đăng ký',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tạo tài khoản thành viên mới để nhận ưu đãi',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _fullNameController,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                context,
                label: 'Họ và tên',
                hint: 'Nhập họ tên của bạn',
                icon: Icons.person_outline,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập họ tên';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                context,
                label: 'Tài khoản',
                hint: 'Tên đăng nhập',
                icon: Icons.account_circle_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tài khoản';
                }
                if (value.trim().length < 3) {
                  return 'Tài khoản phải có ít nhất 3 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                context,
                label: 'Email',
                hint: 'Nhập email của bạn',
                icon: Icons.mail_outline,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập email';
                }
                final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Email không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                context,
                label: 'Số điện thoại (tùy chọn)',
                hint: 'Nhập số điện thoại',
                icon: Icons.phone_outlined,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Thiết lập mật khẩu',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              decoration:
                  _inputDecoration(
                    context,
                    label: 'Mật khẩu',
                    hint: 'Nhập mật khẩu',
                    icon: Icons.lock_outline,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                if (value.length < 6) {
                  return 'Mật khẩu phải có ít nhất 6 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration:
                  _inputDecoration(
                    context,
                    label: 'Nhập lại mật khẩu',
                    hint: 'Xác nhận mật khẩu',
                    icon: Icons.lock_clock_outlined,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập lại mật khẩu';
                }
                if (value != _passwordController.text) {
                  return 'Mật khẩu nhập lại không khớp';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            RegisLoginButton(
              label: _submitting ? 'Đang xử lý...' : 'Đăng ký',
              onPressed: _submitting ? null : _submit,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: _submitting ? null : () => Navigator.pop(context),
                child: const Text('Đã có tài khoản? Đăng nhập'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpStep(ThemeData theme) {
    return _OtpStepWrapper(
      phoneNumber: _phoneController.text,
      expiresAt: _otpExpiresAt,
      onVerifySuccess: (otp) async {
        // Register with OTP
        setState(() => _submitting = true);
        try {
          final apiClient = sl<ApiClient>();
          await apiClient.post(
            '/auth/register-with-otp',
            body: {
              'username': _usernameController.text,
              'email': _emailController.text,
              'password': _passwordController.text,
              'fullName': _fullNameController.text,
              'phoneNumber': _phoneController.text,
              'otp': otp,
            },
          );

          // Login after successful registration
          if (mounted) {
            context.read<AuthBloc>().add(
              AuthLoginRequested(
                LoginRequestDto(
                  usernameOrEmail: _usernameController.text,
                  password: _passwordController.text,
                ),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() => _submitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đăng ký thất bại: ${e.toString()}')),
            );
          }
        }
      },
      onResend: () async {
        await _sendOtp();
      },
      onBack: () {
        setState(() {
          _currentStep = RegisterStep.form;
        });
      },
    );
  }

  Future<void> _sendOtp() async {
    try {
      final apiClient = sl<ApiClient>();
      final response = await apiClient.post(
        '/otp/send',
        body: {'phoneNumber': _phoneController.text},
      );

      if (response['expiresAt'] != null) {
        setState(() {
          _otpExpiresAt = DateTime.parse(response['expiresAt']);
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Mã OTP đã được gửi')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gửi OTP thất bại: ${e.toString()}')),
        );
      }
      rethrow;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate phone number
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số điện thoại')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      await _sendOtp();
      setState(() {
        _currentStep = RegisterStep.otp;
        _submitting = false;
      });
    } catch (e) {
      setState(() => _submitting = false);
    }
  }
}

// Wrapper widget for OTP step
class _OtpStepWrapper extends StatefulWidget {
  final String phoneNumber;
  final DateTime? expiresAt;
  final Future<void> Function(String otp) onVerifySuccess;
  final Future<void> Function() onResend;
  final VoidCallback onBack;

  const _OtpStepWrapper({
    required this.phoneNumber,
    required this.expiresAt,
    required this.onVerifySuccess,
    required this.onResend,
    required this.onBack,
  });

  @override
  State<_OtpStepWrapper> createState() => _OtpStepWrapperState();
}

class _OtpStepWrapperState extends State<_OtpStepWrapper> {
  final _otpController = TextEditingController();
  bool _isSubmitting = false;
  int _secondsRemaining = 300; // 5 minutes
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    if (widget.expiresAt != null) {
      final now = DateTime.now();
      final diff = widget.expiresAt!.difference(now);
      _secondsRemaining = diff.inSeconds.clamp(0, 300);
    }

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        if (_secondsRemaining > 0) _secondsRemaining--;
        if (_resendCountdown > 0) _resendCountdown--;
      });

      return _secondsRemaining > 0 || _resendCountdown > 0;
    });
  }

  Future<void> _handleSubmit() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ 6 số OTP')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.onVerifySuccess(_otpController.text);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleResend() async {
    if (_resendCountdown > 0) return;

    setState(() => _resendCountdown = 60);
    try {
      await widget.onResend();
      _startCountdown();
    } catch (e) {
      setState(() => _resendCountdown = 0);
    }
  }

  String _maskPhone(String phone) {
    if (phone.length < 4) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    return RegisterOtpStep(
      otpController: _otpController,
      secondsRemaining: _secondsRemaining,
      resendCountdown: _resendCountdown,
      isSubmitting: _isSubmitting,
      onSubmit: _handleSubmit,
      onResend: _handleResend,
      onBack: widget.onBack,
      maskedPhone: _maskPhone(widget.phoneNumber),
    );
  }
}

InputDecoration _inputDecoration(
  BuildContext context, {
  required String label,
  required String hint,
  IconData? icon,
}) {
  final theme = Theme.of(context);
  OutlineInputBorder border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(color: color, width: 1.2),
  );

  return InputDecoration(
    labelText: label,
    hintText: hint,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    suffixIcon: icon != null ? Icon(icon, color: Colors.grey.shade600) : null,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: border(Colors.black12),
    enabledBorder: border(Colors.black26),
    focusedBorder: border(theme.primaryColor),
  );
}
