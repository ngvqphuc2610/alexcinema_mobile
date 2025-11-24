import 'package:flutter/material.dart';

class BookingFlowShell extends StatelessWidget {
  const BookingFlowShell({
    super.key,
    required this.title,
    required this.child,
    required this.summaryLines,
    required this.onPrimaryAction,
    this.subtitle,
    this.primaryLabel = 'Tiếp tục',
    this.primaryEnabled = true,
    this.showBack = true,
    this.backgroundColor = Colors.white,
    this.footerAccessory,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<String> summaryLines;
  final VoidCallback onPrimaryAction;
  final String primaryLabel;
  final bool primaryEnabled;
  final bool showBack;
  final Color backgroundColor;
  final Widget? footerAccessory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.6,
        leading: showBack
            ? IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: child,
      ),
      bottomNavigationBar: BookingBottomBar(
        summaryLines: summaryLines,
        primaryLabel: primaryLabel,
        enabled: primaryEnabled,
        onPressed: onPrimaryAction,
        accessory: footerAccessory,
      ),
    );
  }
}

class BookingBottomBar extends StatelessWidget {
  const BookingBottomBar({
    super.key,
    required this.summaryLines,
    required this.onPressed,
    this.enabled = true,
    this.primaryLabel = 'Tiếp tục',
    this.accessory,
  });

  final List<String> summaryLines;
  final VoidCallback onPressed;
  final bool enabled;
  final String primaryLabel;
  final Widget? accessory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (accessory != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: accessory!,
                  ),
                  const SizedBox(height: 4),
                ],
                ...summaryLines
                    .where((line) => line.isNotEmpty)
                    .map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          line,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: const Color(0xFF6A1B9A),
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade600,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  primaryLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
