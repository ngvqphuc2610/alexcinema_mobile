import 'package:flutter/material.dart';

class BiometricLoginButton extends StatelessWidget {
  const BiometricLoginButton({
    super.key,
    required this.enabled,
    required this.onPressed,
    this.helperText,
  });

  final bool enabled;
  final VoidCallback? onPressed;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: enabled ? onPressed : null,
          icon: const Icon(Icons.fingerprint, size: 22),
          label: const Text('Đăng nhập bằng sinh trắc'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                enabled ? theme.primaryColor : Colors.grey.shade300,
            foregroundColor: enabled ? Colors.white : Colors.black54,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: enabled ? 2 : 0,
          ),
        ),
        if (helperText != null && helperText!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black54,
            ),
          ),
        ],
      ],
    );
  }
}
