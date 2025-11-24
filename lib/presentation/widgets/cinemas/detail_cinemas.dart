import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../data/models/dto/showtime_dto.dart';
import '../../../data/models/entity/cinemas_entity.dart';
import '../../../data/models/entity/showtime_entity.dart';
import '../../bloc/showtime/showtime_bloc.dart';
import '../../bloc/showtime/showtime_event.dart';
import '../../bloc/showtime/showtime_state.dart';
import '../../bloc/common/bloc_status.dart';
import '../buyticket/showtime_selector.dart';
import 'widgets/cinema_showtime_list.dart';

class CinemaDetailPage extends StatefulWidget {
  const CinemaDetailPage({super.key, required this.cinema});

  final CinemaEntity cinema;

  @override
  State<CinemaDetailPage> createState() => _CinemaDetailPageState();
}

class _CinemaDetailPageState extends State<CinemaDetailPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<ShowtimeBloc>()
        ..add(
          ShowtimesRequested(
            query: ShowtimeQueryDto(limit: 200, cinemaId: widget.cinema.id),
          ),
        ),
      child: BlocBuilder<ShowtimeBloc, ShowtimeState>(
        builder: (context, state) {
          final showtimes = _filterByCinema(state.items, widget.cinema.id);

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.cinema.cinemaName),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CinemaHeader(cinema: widget.cinema),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: CinemaShowtimeList(
                      showtimes: showtimes,
                      isLoading: state.status.isLoading,
                      onShowtimeTap: (showtime) {
                        final movie = showtime.movie;
                        if (movie == null) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ShowtimeSelectorPage(
                              movie: movie,
                              showtime: showtime,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<ShowtimeEntity> _filterByCinema(
    List<ShowtimeEntity> showtimes,
    int cinemaId,
  ) {
    return showtimes.where((show) {
      final screen = show.screen;
      if (screen == null) return false;
      final screenCinemaId = screen.cinemaId ?? screen.cinema?.id;
      return screenCinemaId == cinemaId;
    }).toList();
  }
}

class _CinemaHeader extends StatelessWidget {
  const _CinemaHeader({required this.cinema});

  final CinemaEntity cinema;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cinema.cinemaName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  cinema.address,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
