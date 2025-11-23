import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../bloc/two_factor/two_factor_cubit.dart';
import '../../bloc/two_factor/two_factor_state.dart';
import '../../bloc/common/bloc_status.dart';
import 'backup_codes_page.dart';

class TwoFactorSetupPage extends StatefulWidget {
  const TwoFactorSetupPage({super.key});

  @override
  State<TwoFactorSetupPage> createState() => _TwoFactorSetupPageState();
}

class _TwoFactorSetupPageState extends State<TwoFactorSetupPage> {
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TwoFactorCubit>().enable2FA();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thiết lập 2FA')),
      body: BlocConsumer<TwoFactorCubit, TwoFactorState>(
        listener: (context, state) {
          if (state.status.isSuccess && state.backupCodes.isNotEmpty) {
            // Success, navigate to backup codes
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<TwoFactorCubit>(),
                  child: const BackupCodesPage(isSetup: true),
                ),
              ),
            );
          } else if (state.status.isFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Đã xảy ra lỗi')),
            );
          }
        },
        builder: (context, state) {
          if (state.status.isLoading && state.secret == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.secret == null) {
            return const Center(child: Text('Không thể tải thông tin 2FA'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Quét mã QR',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: state.qrCodeUrl != null
                      ? QrImageView(
                          data: state.qrCodeUrl!,
                          version: QrVersions.auto,
                          size: 200.0,
                        )
                      : const SizedBox(
                          height: 200,
                          width: 200,
                          child: Center(child: Text('No QR Code')),
                        ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Hoặc nhập khóa bí mật này vào ứng dụng xác thực của bạn:',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: state.secret!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã sao chép khóa bí mật')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.secret!,
                          style: const TextStyle(
                            fontFamily: 'Monospace',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.copy, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Nhập mã xác thực',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nhập mã 6 số từ ứng dụng xác thực để kích hoạt.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: '000000',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.status.isLoading
                        ? null
                        : () {
                            final code = _codeController.text.trim();
                            if (code.length == 6) {
                              context.read<TwoFactorCubit>().verify2FA(code);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state.status.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Kích hoạt'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
