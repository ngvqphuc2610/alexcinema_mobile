import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import '../../../data/models/entity/promotion_entity.dart';

class PromotionDetailPage extends StatelessWidget {
  PromotionDetailPage({super.key, required this.promotion})
      : _dateFormatter = DateFormat('dd/MM/yyyy'),
        _moneyFormatter = NumberFormat.currency(symbol: 'VND', decimalDigits: 0);

  final PromotionEntity promotion;
  final DateFormat _dateFormatter;
  final NumberFormat _moneyFormatter;

  @override
  Widget build(BuildContext context) {
    final timeRange = _buildTimeRange();
    final discountText = _buildDiscountLabel();

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiet uu dai')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroImage(imageUrl: promotion.image),
            const SizedBox(height: 16),
            Text(
              promotion.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _Tag(
                  label: 'Code: ${promotion.promotionCode}',
                  color: const Color(0xFFEDE9FE),
                  textColor: const Color(0xFF6B21A8),
                ),
                const SizedBox(width: 8),
                _Tag(label: promotion.status),
              ],
            ),
            const SizedBox(height: 14),
            if (discountText != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.percent, color: Color(0xFF15803D)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Uu dai',
                            style: TextStyle(
                              color: Color(0xFF15803D),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            discountText,
                            style: const TextStyle(
                              color: Color(0xFF166534),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.event_outlined,
              label: 'Thoi gian',
              value: timeRange,
            ),
            if (promotion.minPurchase != null)
              _InfoRow(
                icon: Icons.shopping_bag_outlined,
                label: 'Toi thieu',
                value: _moneyFormatter.format(promotion.minPurchase),
              ),
            if (promotion.maxDiscount != null)
              _InfoRow(
                icon: Icons.price_change_outlined,
                label: 'Giam toi da',
                value: _moneyFormatter.format(promotion.maxDiscount),
              ),
            if (promotion.usageLimit != null)
              _InfoRow(
                icon: Icons.repeat_on_outlined,
                label: 'So lan su dung',
                value: '${promotion.usageLimit}',
              ),
            const SizedBox(height: 12),
            if (promotion.description != null && promotion.description!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mo ta',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    promotion.description!,
                    style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String? _buildDiscountLabel() {
    if (promotion.discountPercent != null) {
      final percent = promotion.discountPercent!;
      return '${percent.toStringAsFixed(percent % 1 == 0 ? 0 : 1)}%';
    }
    if (promotion.discountAmount != null) {
      return _moneyFormatter.format(promotion.discountAmount);
    }
    return null;
  }

  String _buildTimeRange() {
    final start = _dateFormatter.format(promotion.startDate);
    final end = promotion.endDate != null ? _dateFormatter.format(promotion.endDate!) : 'Khong gioi han';
    return '$start - $end';
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final resolved = _resolveImageUrl(imageUrl);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 210,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: resolved != null
            ? Image.network(
                resolved,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Icon(
      Icons.card_giftcard_outlined,
      color: Colors.grey.shade400,
      size: 48,
    );
  }

  String? _resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final env = dotenv.env;
    String? base = env['FLUTTER_API_URL'] ?? env['API_BASE_URL'] ?? env['BASE_URL'];

    if (raw.startsWith('http')) {
      final isLocal = raw.contains('localhost') || raw.contains('127.0.0.1') || raw.contains('10.0.2.2');
      if (isLocal && base != null && base.isNotEmpty) {
        final normalizedBase = _normalizeBase(base);
        return raw.replaceFirst(RegExp(r'^https?://[^/]+'), normalizedBase);
      }
      return raw;
    }

    if (base == null || base.isEmpty) return raw;
    base = _normalizeBase(base);
    if (!raw.startsWith('/')) {
      raw = '/$raw';
    }
    return '$base$raw';
  }

  String _normalizeBase(String base) {
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    if (base.toLowerCase().endsWith('/api')) {
      base = base.substring(0, base.length - 4);
    }
    return base;
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    this.color = const Color(0xFFE5E7EB),
    this.textColor = const Color(0xFF374151),
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.grey.shade800),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
