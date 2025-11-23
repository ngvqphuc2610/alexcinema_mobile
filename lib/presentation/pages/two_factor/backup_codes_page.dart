import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/two_factor/two_factor_cubit.dart';
import '../../bloc/two_factor/two_factor_state.dart';
import '../../bloc/common/bloc_status.dart';

class BackupCodesPage extends StatefulWidget {
  const BackupCodesPage({super.key, this.isSetup = false});

  final bool isSetup;

  @override
  State<BackupCodesPage> createState() => _BackupCodesPageState();
}

class _BackupCodesPageState extends State<BackupCodesPage> {
  @override
  void initState() {
    super.initState();
    if (!widget.isSetup) {
      context.read<TwoFactorCubit>().loadBackupCodes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mã dự phòng'),
        automaticallyImplyLeading: !widget.isSetup,
      ),
      body: BlocBuilder<TwoFactorCubit, TwoFactorState>(
        builder: (context, state) {
          if (state.status.isLoading && state.backupCodes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status.isFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage ?? 'Lỗi tải mã dự phòng'),
                  ElevatedButton(
                    onPressed: () => context.read<TwoFactorCubit>().loadBackupCodes(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (widget.isSetup) ...[
                      const Icon(Icons.check_circle, color: Colors.green, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        '2FA đã được kích hoạt!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const Text(
                      'Hãy lưu lại các mã dự phòng này ở nơi an toàn. Bạn có thể sử dụng chúng để đăng nhập nếu mất quyền truy cập vào thiết bị xác thực.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: state.backupCodes.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final code = state.backupCodes[index];
                    return ListTile(
                      title: Text(
                        code,
                        style: const TextStyle(
                          fontFamily: 'Monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        final text = state.backupCodes.join('\n');
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã sao chép tất cả mã')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Sao chép tất cả'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.isSetup)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Hoàn tất'),
                      )
                    else
                      TextButton(
                        onPressed: () {
                          // Regenerate codes logic
                          context.read<TwoFactorCubit>().regenerateBackupCodes();
                        },
                        child: const Text('Tạo mã mới'),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
