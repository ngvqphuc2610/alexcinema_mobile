import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/biometric_service.dart';
import '../../core/di/dependency_injection.dart';
import '../../data/models/entity/user_entity.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/common/bloc_status.dart';
import '../bloc/two_factor/two_factor_cubit.dart';
import '../widgets/buttons/btnRegisLogin.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'two_factor/two_factor_settings_page.dart';
import '../pages/two_factor/backup_codes_page.dart';
import 'customer_care_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Tài khoản'),
            actions: [
              // Customer Care button
              IconButton(
                icon: const Icon(Icons.support_agent),
                onPressed: () => CustomerCareBottomSheet.show(context),
                tooltip: 'Chăm sóc khách hàng',
              ),
              if (state.isAuthenticated)
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () =>
                      context.read<AuthBloc>().add(const AuthLogoutRequested()),
                  tooltip: 'Đăng xuất',
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AuthState state) {
    if (state.status.isLoading && !state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.isAuthenticated && state.user != null) {
      return _AuthenticatedView(user: state.user!);
    }
    return _GuestView(
      onLogin: () => _openLogin(context),
      onRegister: () => _openRegister(context),
    );
  }

  Future<void> _openLogin(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  Future<void> _openRegister(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterPage()));
  }
}

class _GuestView extends StatelessWidget {
  const _GuestView({required this.onLogin, required this.onRegister});

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Icon(Icons.lock_outline, size: 72, color: theme.primaryColor),
          const SizedBox(height: 20),
          Text(
            'Bạn chưa đăng nhập',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy đăng nhập hoặc tạo tài khoản để quản lý thông tin và bảo mật 2FA.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          RegisLoginButton(label: 'Đăng nhập', onPressed: onLogin),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRegister,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text('Tạo tài khoản'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Cần hỗ trợ?',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => CustomerCareBottomSheet.show(context),
            icon: Icon(Icons.support_agent, color: theme.primaryColor),
            label: const Text('Liên hệ chăm sóc khách hàng'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              side: BorderSide(color: theme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthenticatedView extends StatefulWidget {
  const _AuthenticatedView({required this.user});

  final UserEntity user;

  @override
  State<_AuthenticatedView> createState() => _AuthenticatedViewState();
}

class _AuthenticatedViewState extends State<_AuthenticatedView> {
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _biometricLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    final available = await BiometricAuth.canAuthenticate();
    final enabled = available
        ? await BiometricAuth.isEnabled(widget.user.id.toString())
        : false;
    if (!mounted) return;
    setState(() {
      _biometricAvailable = available;
      _biometricEnabled = available && enabled;
      _biometricLoading = false;
    });
  }

  Future<void> _toggleBiometric(bool enable) async {
    if (_biometricLoading) return;
    if (enable) {
      if (!_biometricAvailable) {
        _showMessage('Thiết bị của bạn không hỗ trợ sinh trắc học.');
        return;
      }
      final approved = await BiometricAuth.authenticate(
        reason: 'Xác thực để bật đăng nhập vân tay',
      );
      if (!approved) {
        _showMessage('Không thể bật đăng nhập vân tay.');
        return;
      }
      final password = await _askPassword();
      if (password == null || password.trim().isEmpty) {
        return;
      }
      await BiometricAuth.saveAccount(
        BiometricAccount(
          userId: widget.user.id.toString(),
          email: widget.user.email,
          password: password.trim(),
          fullName: widget.user.fullName,
          role: widget.user.role,
        ),
      );
      await BiometricAuth.setEnabled(widget.user.id.toString(), true);
      if (!mounted) return;
      setState(() => _biometricEnabled = true);
      _showMessage('Đã bật đăng nhập sinh trắc học.');
      return;
    }

    await BiometricAuth.deleteAccount(widget.user.id.toString());
    if (!mounted) return;
    setState(() => _biometricEnabled = false);
    _showMessage('Đã tắt đăng nhập sinh trắc học.');
  }

  Future<String?> _askPassword() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nhập mật khẩu của bạn'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Mật khẩu hiện tại'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullName = widget.user.fullName;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: theme.primaryColor.withOpacity(0.15),
                      child: Text(
                        fullName.isNotEmpty ? fullName[0] : '?',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.user.email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Thiết lập bảo mật',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Icon(Icons.fingerprint, color: theme.primaryColor),
                  title: const Text('Đăng nhập sinh trắc'),
                  subtitle: Text(
                    _biometricLoading
                        ? 'Đang kiểm tra hỗ trợ...'
                        : _biometricAvailable
                        ? 'Bật xác thực vân tay / Face ID để đăng nhập nhanh.'
                        : 'Thiết bị không hỗ trợ sinh trắc học.',
                  ),
                  trailing: _biometricLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Switch.adaptive(
                          value: _biometricEnabled,
                          onChanged: _biometricAvailable
                              ? _toggleBiometric
                              : null,
                        ),
                  onTap: _biometricLoading || !_biometricAvailable
                      ? null
                      : () => _toggleBiometric(!_biometricEnabled),
                ),
                ListTile(
                  leading: Icon(
                    Icons.shield_outlined,
                    color: theme.primaryColor,
                  ),
                  title: const Text('Mã OTP & TOTP'),
                  subtitle: const Text(
                    'Quản lý OTP, TOTP Google Authenticator',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TwoFactorSettingsPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.key, color: theme.primaryColor),
                  title: const Text('Mã dự phòng (Backup Codes)'),
                  subtitle: const Text(
                    'Xem và sao chép các mã dự phòng 2FA của bạn.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => serviceLocator<TwoFactorCubit>(),
                          child: const BackupCodesPage(
                            isSetup: false,
                          ),
                        ),
                    )
                    );
                  },
                ),
                const Divider(height: 32),
                Text(
                  'Hỗ trợ',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Icon(
                    Icons.support_agent,
                    color: theme.primaryColor,
                  ),
                  title: const Text('Chăm sóc khách hàng'),
                  subtitle: const Text(
                    'Liên hệ với chúng tôi để được hỗ trợ',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => CustomerCareBottomSheet.show(context),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () =>
              context.read<AuthBloc>().add(const AuthLogoutRequested()),
          icon: const Icon(Icons.logout),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          label: const Text('Đăng xuất'),
        ),
      ],
    );
  }
}
