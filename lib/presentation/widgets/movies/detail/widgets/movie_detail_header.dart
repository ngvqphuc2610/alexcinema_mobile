import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../data/models/entity/movie_entity.dart';

class MovieDetailHeader extends StatelessWidget {
  const MovieDetailHeader({
    super.key,
    required this.movie,
    this.formatLabel,
    this.genreLabel,
    this.classificationLabel,
    this.onPlayPressed,
  });

  final MovieEntity movie;
  final String? formatLabel;
  final String? genreLabel;
  final String? classificationLabel;
  final VoidCallback? onPlayPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final infoStyle = theme.textTheme.bodyMedium?.copyWith(
      color: Colors.black87,
    );

    return Card(
      elevation: 6,
      shadowColor: theme.primaryColor.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PosterImage(imageUrl: movie.posterImage),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Thoi luong: ${movie.duration} phut', style: infoStyle),
                  if (genreLabel?.isNotEmpty == true)
                    Text(genreLabel!, style: infoStyle),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if ((formatLabel ?? '').isNotEmpty)
                        _LabeledChip(label: formatLabel!),
                      if ((classificationLabel ?? '').isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _LabeledChip(
                          label: classificationLabel!,
                          backgroundColor: const Color(0xFFFFF3CD),
                          textColor: const Color(0xFF8A6D3B),
                        ),
                      ],
                      const Spacer(),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: onPlayPressed,
                        icon: const Icon(Icons.play_arrow_rounded),
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
}

class _PosterImage extends StatelessWidget {
  const _PosterImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    const size = Size(90, 130);
    final borderRadius = BorderRadius.circular(16);

    Widget child;
    if (imageUrl?.isNotEmpty == true) {
      child = CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _PosterPlaceholder(
          icon: Icons.local_movies_outlined,
          color: Colors.grey.shade200,
        ),
        errorWidget: (_, __, ___) => _PosterPlaceholder(
          icon: Icons.broken_image_outlined,
          color: Colors.grey.shade300,
        ),
      );
    } else {
      child = _PosterPlaceholder(
        icon: Icons.movie_filter_outlined,
        color: Colors.grey.shade200,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: child,
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Icon(icon, color: Colors.black45, size: 36),
      ),
    );
  }
}

class _LabeledChip extends StatelessWidget {
  const _LabeledChip({
    required this.label,
    this.backgroundColor = const Color(0xFFEDE7F6),
    this.textColor = const Color(0xFF4A148C),
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
