import 'package:flutter/material.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../data/models/dto/movie_dto.dart';
import '../../../data/models/entity/movie_entity.dart';
import '../../../domain/services/movie_service.dart';
import 'comingsoon/grid_movies_comingsoon.dart';
import 'detail/movie_detail_view.dart';
import 'nowshowing/grid_movies_nowshow.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  late final MovieService _movieService;
  List<MovieEntity> _nowShowing = const [];
  List<MovieEntity> _comingSoon = const [];
  bool _isLoadingNow = true;
  bool _isLoadingComing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _movieService = serviceLocator<MovieService>();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    setState(() {
      _isLoadingNow = true;
      _isLoadingComing = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _movieService.getMovies(
          const MovieQueryDto(status: 'now showing', limit: 10),
        ),
        _movieService.getMovies(
          const MovieQueryDto(status: 'coming soon', limit: 10),
        ),
      ]);

      setState(() {
        _nowShowing = results[0].items;
        _comingSoon = results[1].items;
        _isLoadingNow = false;
        _isLoadingComing = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoadingNow = false;
        _isLoadingComing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C0F2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Phim',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              const Text(
                'Không thể tải danh sách phim',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchMovies,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMovies,
      color: Colors.deepPurple,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // Section: Đang chiếu
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: const [
                Text(
                  'PHIM ĐANG CHIẾU',
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoadingNow)
            const _NowShowingSkeleton()
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: NowShowingMoviesGrid(
                movies: _mapNowShowing(),
                onBookMovie: _handleBookMovie,
                onMovieTap: _handleBookMovie,
              ),
            ),

          const SizedBox(height: 16),

          // Section: Sắp chiếu
          ComingSoonMoviesGrid(
            movies: _comingSoon,
            isLoading: _isLoadingComing,
            onMovieTap: _openMovieDetail,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            title: 'PHIM SẮP CHIẾU',
          ),
        ],
      ),
    );
  }

  List<NowShowingMovie> _mapNowShowing() {
    if (_nowShowing.isEmpty) {
      return const [];
    }

    return _nowShowing
        .map(
          (movie) => NowShowingMovie(
            id: movie.id,
            title: movie.title,
            posterUrl: movie.posterImage?.isNotEmpty == true
                ? movie.posterImage!
                : 'https://via.placeholder.com/300x450?text=No+Image',
            genre: movie.language?.isNotEmpty == true
                ? movie.language!
                : movie.country ?? 'Đang cập nhật',
            format: movie.subtitle?.isNotEmpty == true
                ? movie.subtitle!.toUpperCase()
                : '2D',
            ageRestriction: movie.ageRestriction?.isNotEmpty == true
                ? movie.ageRestriction!
                : 'P',
          ),
        )
        .toList();
  }

  void _handleBookMovie(NowShowingMovie movie) {
    final entity = _findMovieById(movie.id);
    if (entity != null) {
      _openMovieDetail(entity);
    }
  }

  MovieEntity? _findMovieById(int id) {
    for (final movie in _nowShowing) {
      if (movie.id == id) {
        return movie;
      }
    }
    for (final movie in _comingSoon) {
      if (movie.id == id) {
        return movie;
      }
    }
    return null;
  }

  void _openMovieDetail(MovieEntity movie) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => MovieDetailView(movie: movie)));
  }
}

class _NowShowingSkeleton extends StatelessWidget {
  const _NowShowingSkeleton();

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.white.withOpacity(0.08);

    return SizedBox(
      height: 340,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (_, __) => Container(
          width: 220,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: 3,
      ),
    );
  }
}
