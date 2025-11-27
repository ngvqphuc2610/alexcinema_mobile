import 'package:flutter/material.dart';

import '../../../data/models/dto/payment_dto.dart';

class BookingResultPage extends StatelessWidget {
  const BookingResultPage({
    super.key,
    required this.status,
    this.onClose,
    this.onViewTickets,
  });

  final PaymentStatusDto status;
  final VoidCallback? onClose;
  final VoidCallback? onViewTickets;

  bool get _isSuccess => status.status.toLowerCase() == 'success';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: onClose ?? () => Navigator.maybePop(context),
                  icon: const Icon(Icons.close),
                ),
              ),
              const SizedBox(height: 12),
              _ResultIcon(success: _isSuccess),
              const SizedBox(height: 12),
              Text(
                _isSuccess ? 'Thanh toán thành công' : 'Thanh toán thất bại',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _buildMessage(),
                style: const TextStyle(color: Colors.black54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              _InfoRow(label: 'Mã giao dịch', value: status.transactionId),
              if (status.bookingCode != null && status.bookingCode!.isNotEmpty)
                _InfoRow(label: 'Mã đặt vé', value: status.bookingCode!),
              if (status.amount != null)
                _InfoRow(label: 'Số tiền', value: _formatCurrency(status.amount!)),
              if (status.updatedAt != null)
                _InfoRow(label: 'Cập nhật', value: _formatDate(status.updatedAt!)),
              const Spacer(),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onViewTickets ?? onClose ?? () => Navigator.maybePop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _isSuccess ? 'XEM VÉ' : 'THỬ LẠI',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onClose ?? () => Navigator.maybePop(context),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildMessage() {
    if (_isSuccess) {
      return 'Vé và thông tin thanh toán đã được gửi tới email của bạn.';
    }
    return 'Không thể hoàn tất thanh toán. Vui lòng thử lại hoặc chọn phương thức khác.';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ResultIcon extends StatelessWidget {
  const _ResultIcon({required this.success});

  final bool success;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 38,
      backgroundColor: success ? Colors.green.shade100 : Colors.red.shade100,
      child: Icon(
        success ? Icons.check_circle : Icons.cancel,
        size: 52,
        color: success ? Colors.green.shade700 : Colors.red.shade700,
      ),
    );
  }
}

String _formatCurrency(double value) {
  final intPart = value.round();
  final str = intPart.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
    buffer.write(str[i]);
  }
  return '${buffer.toString()} đ';
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
