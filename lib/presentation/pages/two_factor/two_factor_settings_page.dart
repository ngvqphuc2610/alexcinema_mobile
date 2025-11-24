import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/dependency_injection.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/common/bloc_status.dart';
import '../../bloc/two_factor/two_factor_cubit.dart';
import '../../bloc/two_factor/two_factor_state.dart';
import 'backup_codes_page.dart';
import 'two_factor_setup_page.dart';

class TwoFactorSettingsPage extends StatelessWidget {
  const TwoFactorSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<TwoFactorCubit>(),
      child: const _TwoFactorSettingsView(),
    );
  }
}

class _TwoFactorSettingsView extends StatelessWidget {
  const _TwoFactorSettingsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Xác thực 2 lớp (2FA)')),
      body: BlocListener<TwoFactorCubit, TwoFactorState>(
        listener: (context, state) {
          if (state.status == BlocStatus.success && state.secret == null) {
            // 2FA was disabled successfully
            context.read<AuthBloc>().add(const AuthProfileRequested());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã tắt 2FA thành công')),
            );
          } else if (state.status == BlocStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Đã xảy ra lỗi')),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final isEnabled = authState.user?.twoFactorEnabled ?? false;

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Icon(
                  isEnabled ? Icons.lock : Icons.lock_open,
                  size: 80,
                  color: isEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(height: 24),
                Text(
                  isEnabled ? '2FA đang BẬT' : '2FA đang TẮT',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isEnabled ? Colors.green : Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isEnabled
                      ? 'Tài khoản của bạn được bảo vệ thêm một lớp bảo mật.'
                      : 'Bảo vệ tài khoản của bạn bằng cách yêu cầu mã xác thực khi đăng nhập.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                if (!isEnabled)
                  ElevatedButton(
                    onPressed: () => _openSetup(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Thiết lập 2FA'),
                  ),
                if (isEnabled) ...[
                  OutlinedButton.icon(
                    onPressed: () => _viewBackupCodes(context),
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Xem mã dự phòng'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _disable2FA(context),
                    icon: const Icon(
                      Icons.no_encryption_gmailerrorred_outlined,
                    ),
                    label: const Text('Tắt 2FA'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _openSetup(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<TwoFactorCubit>(),
              child: const TwoFactorSetupPage(),
            ),
          ),
        )
        .then((_) {
          // Refresh profile to update 2FA status
          context.read<AuthBloc>().add(const AuthProfileRequested());
        });
  }

  void _viewBackupCodes(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TwoFactorCubit>(),
          child: const BackupCodesPage(),
        ),
      ),
    );
  }

  void _disable2FA(BuildContext context) {
    // Show confirmation dialog or input OTP to disable
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tắt 2FA?'),
        content: const Text(
          'Bạn có chắc chắn muốn tắt xác thực 2 lớp không? Tài khoản của bạn sẽ kém an toàn hơn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Call disable API
              // For simplicity, we might need an OTP to disable, but let's assume we just call disable for now
              // or prompt for OTP in a bottom sheet.
              // Implementing simple disable for now.
              _confirmDisable(context);
            },
            child: const Text('Tắt', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDisable(BuildContext context) {
    // In a real app, we should ask for OTP here.
    // For this task, I'll assume we can just call disable with a dummy code or empty if API allows,
    // OR prompt for OTP. Given the requirement "complete it", I should probably prompt.
    // But to keep it simple and fit the task, I'll try to disable.
    // If the API requires code, I'll show an input dialog.

    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Nhập mã OTP để tắt'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Nhập mã 6 số'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<TwoFactorCubit>().disable2FA(controller.text);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}
