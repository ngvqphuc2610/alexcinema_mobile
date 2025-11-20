import 'package:flutter/material.dart';

import 'card_movies_nowshow.dart';

class NowShowingMovie {
  final int id;
  final String title;
  final String posterUrl;
  final String genre;
  final String format; // 2D / 3D
  final String ageRestriction; // P / C13 / C16

  NowShowingMovie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.genre,
    required this.format,
    required this.ageRestriction,
  });
}

class NowShowingMoviesGrid extends StatelessWidget {
  final List<NowShowingMovie> movies;
  final void Function(NowShowingMovie movie)? onBookMovie;
  final void Function(NowShowingMovie movie)? onMovieTap;

  const NowShowingMoviesGrid({
    super.key,
    required this.movies,
    this.onBookMovie,
    this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề section: PHIM ĐANG CHIẾU
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'PHIM ĐANG CHIẾU',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 340,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return NowShowingMovieCard(
                title: movie.title,
                posterUrl: movie.posterUrl,
                genre: movie.genre,
                format: movie.format,
                ageRestriction: movie.ageRestriction,
                onBookPressed: () => onBookMovie?.call(movie),
                onTap: () => onMovieTap?.call(movie),
              );
            },
          ),
        ),
      ],
    );
  }
}
