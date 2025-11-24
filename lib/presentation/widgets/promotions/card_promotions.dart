import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import '../../../data/models/entity/promotion_entity.dart';

class PromotionCard extends StatelessWidget {
  PromotionCard({
    super.key,
    required this.promotion,
    this.onTap,
  });

  final PromotionEntity promotion;
  final VoidCallback? onTap;

  static final DateFormat _dateFormatter = DateFormat('dd/MM');
  static final NumberFormat _moneyFormatter =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final discountText = _buildDiscountLabel();
    final timeRange = _buildTimeRange();

    return Material(
      color: theme.cardColor,
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: theme.colorScheme.primary.withOpacity(0.08),
        highlightColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh + badge giảm giá
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _PromotionImage(imageUrl: promotion.image),
                ),
                if (discountText != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _DiscountBadge(label: discountText),
                  ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: _Tag(
                    label: promotion.promotionCode,
                    color: Colors.black.withOpacity(0.65),
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),

            // Nội dung
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Text(
                    promotion.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Status + loại giảm giá
                  Row(
                    children: [
                      _Tag(
                        label: promotion.status,
                        color: const Color(0xFFE5E7EB),
                        textColor: const Color(0xFF374151),
                      ),
                      const SizedBox(width: 6),
                      if (discountText != null)
                        _Tag(
                          label: 'Ưu đãi',
                          color: const Color(0xFFECFEFF),
                          textColor: const Color(0xFF0E7490),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Mô tả ngắn
                  if (promotion.description != null &&
                      promotion.description!.isNotEmpty)
                    Text(
                      promotion.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  if (promotion.description != null &&
                      promotion.description!.isNotEmpty)
                    const SizedBox(height: 10),

                  // Hàng cuối: thời gian + icon
                  Row(
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          timeRange,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _buildDiscountLabel() {
    if (promotion.discountPercent != null) {
      final percent = promotion.discountPercent!;
      final text = percent.toStringAsFixed(percent % 1 == 0 ? 0 : 1);
      return '-$text%';
    }
    if (promotion.discountAmount != null) {
      return '-${_moneyFormatter.format(promotion.discountAmount)}';
    }
    return null;
  }

  String _buildTimeRange() {
    final start = _dateFormatter.format(promotion.startDate);
    final end = promotion.endDate != null
        ? _dateFormatter.format(promotion.endDate!)
        : 'Không giới hạn';
    return '$start  •  $end';
  }
}

class _PromotionImage extends StatelessWidget {
  const _PromotionImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final resolved = _resolveImageUrl(imageUrl);

    return Container(
      color: Colors.grey.shade200,
      child: resolved != null
          ? Image.network(
              resolved,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        Icons.local_offer_outlined,
        color: Colors.grey.shade400,
        size: 40,
      ),
    );
  }

  static String? _resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final env = dotenv.env;
    String? base =
        env['FLUTTER_API_URL'] ?? env['API_BASE_URL'] ?? env['BASE_URL'];

    // Đã là full URL
    if (raw.startsWith('http')) {
      final isLocal = raw.contains('localhost') ||
          raw.contains('127.0.0.1') ||
          raw.contains('10.0.2.2');
      if (isLocal && base != null && base.isNotEmpty) {
        final normalizedBase = _normalizeBase(base);
        return raw.replaceFirst(RegExp(r'^https?://[^/]+'), normalizedBase);
      }
      return raw;
    }

    // Chỉ là path -> ghép với base
    if (base == null || base.isEmpty) return raw;
    base = _normalizeBase(base);
    if (!raw.startsWith('/')) raw = '/$raw';
    return '$base$raw';
  }

  static String _normalizeBase(String base) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEF4444),
            Color(0xFFF97316),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}
