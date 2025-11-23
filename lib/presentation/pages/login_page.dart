import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/biometric_service.dart';
import '../../data/models/dto/auth_request_dto.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/common/bloc_status.dart';
import '../widgets/BiometricLoginButton.dart';
import '../widgets/buttons/btnRegisLogin.dart';
import 'forgotpassword_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _submitting = false;
  bool _obscurePassword = true;
  bool _biometricAvailable = false;
  List<BiometricAccount> _biometricAccounts = const [];

  @override
  void initState() {
    super.initState();
    _loadBiometric();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadBiometric() async {
    final available = await BiometricAuth.canAuthenticate();
    final accounts = available ? await BiometricAuth.getAccounts() : <BiometricAccount>[];
    if (!mounted) return;
    setState(() {
      _biometricAvailable = available;
      _biometricAccounts = accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) async {
            if (!_submitting) return;
            if (state.status.isFailure) {
              setState(() => _submitting = false);
              final message = state.errorMessage ?? 'Đăng nhập thất bại.';
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
            } else if (state.status.isSuccess && state.isAuthenticated) {
              // Lưu thông tin đăng nhập cho sinh trắc học
              if (_biometricAvailable &&
                  _usernameController.text.isNotEmpty &&
                  _passwordController.text.isNotEmpty) {
                final userId = state.user?.id.toString() ?? _usernameController.text.trim();
                await BiometricAuth.saveAccount(
                  BiometricAccount(
                    userId: userId,
                    email: _usernameController.text.trim(),
                    password: _passwordController.text.trim(),
                    fullName: state.user?.fullName ?? '',
                    role: state.user?.role ?? '',
                  ),
                );
                await BiometricAuth.setEnabled(userId, true);
                await _loadBiometric();
              }
              setState(() => _submitting = false);
              Navigator.of(context).pop();
            }
          },
          child: SingleChildScrollView(
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
                    'Đăng nhập',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Đăng nhập bằng tài khoản hoặc email của bạn',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  if (_biometricAvailable) ...[
                    const SizedBox(height: 18),
                    BiometricLoginButton(
                      enabled: _biometricAccounts.isNotEmpty && !_submitting,
                      onPressed:
                          _biometricAccounts.isNotEmpty && !_submitting ? _loginWithBiometric : null,
                      helperText: _biometricAccounts.isNotEmpty
                          ? 'Đăng nhập nhanh bằng vân tay / Face ID.'
                          : 'Bật đăng nhập sinh trắc trong trang Tài khoản.',
                    ),
                  ],
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      context,
                      label: 'Tài khoản hoặc Email',
                      hint: 'Nhập tài khoản hoặc email của bạn',
                      icon: Icons.mail_outline,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tài khoản hoặc email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration(
                      context,
                      label: 'Mật khẩu',
                      hint: 'Nhập mật khẩu',
                      icon: _obscurePassword ? Icons.lock_outline : Icons.lock_open,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                  const SizedBox(height: 28),
                  RegisLoginButton(
                    label: _submitting ? 'Đang xử lý...' : 'Đăng nhập',
                    onPressed: _submitting ? null : _submit,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _submitting ? null : () => _openForgotPassword(context),
                        child: const Text('Quên mật khẩu?'),
                      ),
                      Text(
                        '/',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black45,
                        ),
                      ),
                      TextButton(
                        onPressed: _submitting ? null : () => _openRegister(context),
                        child: const Text('Tạo tài khoản'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loginWithBiometric() async {
    if (_biometricAccounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có thông tin đăng nhập dạng vân tay.')),
      );
      return;
    }
    final account = await _pickAccount();
    if (account == null) return;

    final approved = await BiometricAuth.authenticate(
      reason: 'Xác thực để đăng nhập bằng vân tay',
    );
    if (!approved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xác thực sinh trắc không thành công.')),
      );
      return;
    }
    setState(() => _submitting = true);
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            LoginRequestDto(
              usernameOrEmail: account.email,
              password: account.password,
            ),
          ),
        );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            LoginRequestDto(
              usernameOrEmail: _usernameController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          ),
        );
  }

  Future<void> _openRegister(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  Future<BiometricAccount?> _pickAccount() async {
    if (_biometricAccounts.length == 1) return _biometricAccounts.first;
    return showModalBottomSheet<BiometricAccount>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Chọn tài khoản đăng nhập',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              for (final acc in _biometricAccounts)
                ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: Text(acc.email),
                  subtitle: Text(acc.fullName.isNotEmpty ? acc.fullName : acc.role),
                  onTap: () => Navigator.of(context).pop(acc),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openForgotPassword(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
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
    suffixIcon: icon != null
        ? Icon(
            icon,
            color: Colors.grey.shade600,
          )
        : null,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: border(Colors.black12),
    enabledBorder: border(Colors.black26),
    focusedBorder: border(theme.primaryColor),
  );
}
