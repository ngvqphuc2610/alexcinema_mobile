import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/entity/movie_entity.dart';
import '../../../../data/models/entity/showtime_entity.dart';
import '../../movies/detail/widgets/movie_detail_date_selector.dart';

class CinemaShowtimeList extends StatefulWidget {
  const CinemaShowtimeList({
    super.key,
    required this.showtimes,
    required this.isLoading,
  });

  final List<ShowtimeEntity> showtimes;
  final bool isLoading;

  @override
  State<CinemaShowtimeList> createState() => _CinemaShowtimeListState();
}

class _CinemaShowtimeListState extends State<CinemaShowtimeList> {
  DateTime? _selectedDate;

  @override
  void didUpdateWidget(covariant CinemaShowtimeList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showtimes != widget.showtimes) {
      _selectedDate = _resolveSelectedDate(widget.showtimes, _selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dates = _uniqueDates(widget.showtimes);
    _selectedDate ??= dates.isNotEmpty ? dates.first : null;
    final showtimesForDate = _filterByDate(widget.showtimes, _selectedDate);
    final movies = _groupByMovie(showtimesForDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MovieDetailDateSelector(
          isLoading: widget.isLoading,
          dates: dates,
          selectedDate: _selectedDate,
          onDateSelected: (date) => setState(() => _selectedDate = date),
          dateLabelBuilder: _dateLabel,
        ),
        const SizedBox(height: 12),
        if (widget.isLoading && movies.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (movies.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('Khong co lich chieu')),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemBuilder: (_, index) {
              final item = movies[index];
              return _MovieScheduleCard(
                movie: item.movie,
                showtimes: item.showtimes,
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: movies.length,
          ),
      ],
    );
  }

  List<DateTime> _uniqueDates(List<ShowtimeEntity> showtimes) {
    final seen = <String>{};
    final results = <DateTime>[];
    for (final show in showtimes) {
      final clean = DateTime(show.showDate.year, show.showDate.month, show.showDate.day);
      final key = '${clean.year}-${clean.month}-${clean.day}';
      if (seen.add(key)) {
        results.add(clean);
      }
    }
    results.sort();
    return results;
  }

  List<ShowtimeEntity> _filterByDate(List<ShowtimeEntity> showtimes, DateTime? date) {
    if (date == null) return const [];
    return showtimes
        .where((show) => show.showDate.year == date.year && show.showDate.month == date.month && show.showDate.day == date.day)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<_MovieSchedule> _groupByMovie(List<ShowtimeEntity> showtimes) {
    if (showtimes.isEmpty) return const [];
    final map = <int, _MovieSchedule>{};
    for (final show in showtimes) {
      final movie = show.movie;
      final movieId = movie?.id ?? -1;
      map.putIfAbsent(
        movieId,
        () => _MovieSchedule(
          movie: movie ??
              MovieEntity(
                id: movieId,
                title: 'Phim dang cap nhat',
                duration: 0,
                releaseDate: DateTime.now(),
                status: 'coming_soon',
              ),
          showtimes: [],
        ),
      );
      map[movieId]!.showtimes.add(show);
    }
    return map.values.toList();
  }

  DateTime? _resolveSelectedDate(
    List<ShowtimeEntity> showtimes,
    DateTime? current,
  ) {
    final dates = _uniqueDates(showtimes);
    if (dates.isEmpty) return null;
    if (current == null) return dates.first;
    return dates.any((date) => _isSameDate(date, current)) ? current : dates.first;
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_isSameDate(date, today)) {
      return 'Hom nay';
    }
    const names = ['Chu nhat', 'Thu 2', 'Thu 3', 'Thu 4', 'Thu 5', 'Thu 6', 'Thu 7'];
    final weekdayName = names[date.weekday % 7];
    final formatter = DateFormat('dd/MM');
    return '$weekdayName';
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _MovieSchedule {
  _MovieSchedule({required this.movie, required this.showtimes});

  final MovieEntity movie;
  final List<ShowtimeEntity> showtimes;
}

class _MovieScheduleCard extends StatelessWidget {
  const _MovieScheduleCard({required this.movie, required this.showtimes});

  final MovieEntity movie;
  final List<ShowtimeEntity> showtimes;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Poster(imageUrl: movie.posterImage),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (movie.subtitle != null && movie.subtitle!.isNotEmpty)
                      _Tag(label: movie.subtitle!),
                    if (movie.language != null && movie.language!.isNotEmpty)
                      _Tag(label: movie.language!),
                    _Tag(
                      label: movie.ageRestriction?.isNotEmpty == true ? movie.ageRestriction! : 'T16',
                      color: const Color(0xFFF6B20F),
                      textColor: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: showtimes
                      .map(
                        (show) => _TimePill(
                          label: timeFormat.format(show.startTime),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 90,
        height: 130,
        color: const Color(0xFFECECEC),
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Icon(
      Icons.movie_creation_outlined,
      color: Colors.black.withOpacity(0.25),
      size: 32,
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.color = const Color(0xFFE6EEFF), this.textColor = const Color(0xFF0F172A)});

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
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

class _TimePill extends StatelessWidget {
  const _TimePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF8D4CE8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
