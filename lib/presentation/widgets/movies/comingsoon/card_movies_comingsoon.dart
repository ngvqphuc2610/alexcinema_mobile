import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/entity/movie_entity.dart';

class ComingSoonMovieCard extends StatelessWidget {
  const ComingSoonMovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.width = 150,
  });

  final MovieEntity movie;
  final VoidCallback? onTap;
  final double width;

  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final releaseDate = _dateFormatter.format(movie.releaseDate);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Poster(posterUrl: movie.posterImage),
            const SizedBox(height: 10),
            Text(
              movie.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              releaseDate,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.posterUrl});

  final String? posterUrl;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(22);
    final placeholderColor = Colors.grey.shade200;

    Widget child;
    if (posterUrl?.isNotEmpty == true) {
      child = CachedNetworkImage(
        imageUrl: posterUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _PosterPlaceholder(color: placeholderColor),
        errorWidget: (_, __, ___) => _PosterPlaceholder(
          color: placeholderColor,
          icon: Icons.broken_image_outlined,
        ),
      );
    } else {
      child = const _PosterPlaceholder(
        color: Color(0xFFEDE7F6),
        icon: Icons.movie_creation_outlined,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: child,
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder({
    required this.color,
    this.icon = Icons.local_movies_outlined,
  });

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Icon(
          icon,
          size: 40,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}
