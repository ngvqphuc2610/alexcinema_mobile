import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../data/models/dto/movie_dto.dart';
import '../../../../data/models/entity/movie_entity.dart';
import '../../../bloc/common/bloc_status.dart';
import '../../../bloc/movie/movie_bloc.dart';
import '../../../bloc/movie/movie_event.dart';
import '../../../bloc/movie/movie_state.dart';
import '../detail/movie_detail_screen.dart';

class ComingSoonListPage extends StatelessWidget {
  const ComingSoonListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<MovieBloc>()
        ..add(
          const MoviesRequested(
            query: MovieQueryDto(status: 'coming soon', limit: 100),
          ),
        ),
      child: const _ComingSoonListView(),
    );
  }
}

class _ComingSoonListView extends StatelessWidget {
  const _ComingSoonListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phim sap chieu'),
      ),
      body: BlocBuilder<MovieBloc, MoviesState>(
        builder: (context, state) {
          if (state.status.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status.isFailure) {
            return Center(
              child: Text(state.errorMessage ?? 'Khong the tai danh sach phim'),
            );
          }
          if (state.items.isEmpty) {
            return const Center(child: Text('Chua co phim sap chieu'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, index) {
              final movie = state.items[index];
              return _MovieListTile(
                movie: movie,
                onTap: () => _openDetail(context, movie),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: state.items.length,
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, MovieEntity movie) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
    );
  }
}

class _MovieListTile extends StatelessWidget {
  const _MovieListTile({required this.movie, this.onTap});

  final MovieEntity movie;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.all(12),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          movie.posterImage ?? '',
          width: 60,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 60,
            height: 90,
            color: Colors.grey.shade300,
            child: const Icon(Icons.movie_outlined),
          ),
        ),
      ),
      title: Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            movie.subtitle?.isNotEmpty == true ? movie.subtitle! : (movie.language ?? ''),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              _Tag(label: movie.status),
              if (movie.ageRestriction?.isNotEmpty == true) _Tag(label: movie.ageRestriction!),
            ],
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
