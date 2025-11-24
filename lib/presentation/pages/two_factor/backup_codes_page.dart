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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mã dự phòng'),
        automaticallyImplyLeading: !widget.isSetup,
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<TwoFactorCubit, TwoFactorState>(
          builder: (context, state) {
            if (state.status.isLoading && state.backupCodes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status.isFailure) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 56,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.errorMessage ?? 'Lỗi tải mã dự phòng',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () =>
                            context.read<TwoFactorCubit>().loadBackupCodes(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final codes = state.backupCodes;

            return Column(
              children: [
                // Phần thông tin / header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.isSetup) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user,
                              size: 28,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '2FA đã được kích hoạt',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 22,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Lưu các mã dự phòng này ở nơi an toàn. '
                                'Bạn có thể dùng chúng để đăng nhập nếu mất quyền truy cập vào ứng dụng xác thực.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Grid hiển thị mã
                Expanded(
                  child: codes.isEmpty
                      ? Center(
                          child: Text(
                            'Chưa có mã dự phòng.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Danh sách mã dự phòng',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Mỗi mã chỉ sử dụng được một lần.',
                                    style:
                                        theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // GridView hiển thị code như “chip”
                                  Expanded(
                                    child: GridView.builder(
                                      itemCount: codes.length,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 12,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: 2.8,
                                      ),
                                      itemBuilder: (context, index) {
                                        final code = codes[index];

                                        return InkWell(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          onTap: () {
                                            Clipboard.setData(
                                              ClipboardData(text: code),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Đã sao chép mã: $code'),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: theme
                                                    .colorScheme.primary
                                                    .withOpacity(0.2),
                                              ),
                                              color: theme
                                                  .colorScheme.surfaceVariant
                                                  .withOpacity(0.4),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 6,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    code,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontFamily: 'monospace',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing: 1.6,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                const Icon(
                                                  Icons.copy_rounded,
                                                  size: 18,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),

                // Thanh action bên dưới
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Copy all
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: codes.isEmpty
                              ? null
                              : () {
                                  final text = codes.join('\n');
                                  Clipboard.setData(
                                    ClipboardData(text: text),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã sao chép tất cả mã'),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.copy_all_rounded),
                          label: const Text('Sao chép tất cả mã dự phòng'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            textStyle: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          if (!widget.isSetup)
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  context
                                      .read<TwoFactorCubit>()
                                      .regenerateBackupCodes();
                                },
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Tạo mã mới'),
                              ),
                            ),
                          if (!widget.isSetup) const SizedBox(width: 12),
                          if (widget.isSetup)
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                },
                                style: FilledButton.styleFrom(
                                  minimumSize:
                                      const Size(double.infinity, 48),
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                                child: const Text('Hoàn tất'),
                              ),
                            ),
                        ],
                      ),

                      if (!widget.isSetup)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Bạn có thể tạo lại mã mới bất kỳ lúc nào.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
