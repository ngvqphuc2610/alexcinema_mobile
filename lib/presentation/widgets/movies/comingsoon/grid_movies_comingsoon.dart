import 'package:flutter/material.dart';

import '../../../../data/models/entity/movie_entity.dart';
import 'card_movies_comingsoon.dart';

class ComingSoonMoviesGrid extends StatelessWidget {
  const ComingSoonMoviesGrid({
    super.key,
    required this.movies,
    this.isLoading = false,
    this.onSeeAll,
    this.onMovieTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.title = 'PHIM SẮP CHIẾU',
  });

  final List<MovieEntity> movies;
  final bool isLoading;
  final VoidCallback? onSeeAll;
  final ValueChanged<MovieEntity>? onMovieTap;
  final EdgeInsetsGeometry padding;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          SizedBox(
            height: 270,
            child: _buildBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Colors.black87,
            ),
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('Xem tất cả'),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return _LoadingList();
    }
    if (movies.isEmpty) {
      return _EmptyView(
        message: 'Hiện chưa có phim sắp chiếu nào.',
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final movie = movies[index];
        return ComingSoonMovieCard(
          movie: movie,
          onTap: onMovieTap != null ? () => onMovieTap!(movie) : null,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemCount: movies.length,
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.black45),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) => const _SkeletonCard(),
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemCount: 4,
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 150,
          height: 225,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 120,
          height: 14,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 80,
          height: 12,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
}
