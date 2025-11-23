import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../data/models/dto/showtime_dto.dart';
import '../../../../data/models/entity/movie_entity.dart';
import '../../../bloc/showtime/showtime_bloc.dart';
import '../../../bloc/showtime/showtime_event.dart';
import '../../../bloc/showtime/showtime_state.dart';
import 'movie_detail_view.dart';
import '../../../bloc/common/bloc_status.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movie});

  final MovieEntity movie;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<ShowtimeBloc>()
        ..add(
          ShowtimesRequested(
            query: ShowtimeQueryDto(
              movieId: movie.id,
              limit: 200,
            ),
          ),
        ),
      child: BlocBuilder<ShowtimeBloc, ShowtimeState>(
        builder: (context, state) {
          return MovieDetailView(
            movie: movie,
            showtimes: state.items,
            isLoadingShowtimes: state.status.isLoading,
          );
        },
      ),
    );
  }
}
