import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Simple DTO used by the news widgets so we don't have to pass
/// entire entities to the UI layer.
class NewsCardData {
  const NewsCardData({
    required this.title,
    this.description,
    this.imageUrl,
    this.badgeLabel,
    this.publishedAt,
  });

  final String title;
  final String? description;
  final String? imageUrl;
  final String? badgeLabel;
  final DateTime? publishedAt;

  String get formattedDate {
    if (publishedAt == null) {
      return '';
    }
    return DateFormat('dd/MM/yyyy').format(publishedAt!);
  }
}

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.data});

  final NewsCardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImage(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((data.badgeLabel ?? '').isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data.badgeLabel!.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  data.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if ((data.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    data.description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (data.formattedDate.isNotEmpty)
                      Text(
                        data.formattedDate,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = data.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return _ImagePlaceholder(
        icon: Icons.newspaper_rounded,
        color: Colors.deepPurple.shade200,
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(18),
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        height: 180,
        width: double.infinity,
        placeholder: (_, __) => _ImagePlaceholder(
          icon: Icons.photo_library_outlined,
          color: Colors.deepPurple.shade50,
        ),
        errorWidget: (_, __, ___) => _ImagePlaceholder(
          icon: Icons.broken_image_outlined,
          color: Colors.grey.shade200,
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
      child: Icon(
        icon,
        size: 48,
        color: Colors.black26,
      ),
    );
  }
}
