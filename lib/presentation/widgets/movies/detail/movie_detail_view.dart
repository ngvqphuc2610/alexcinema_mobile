import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/models/entity/movie_entity.dart';
import '../../../../data/models/entity/showtime_entity.dart';
import 'widgets/movie_detail_date_selector.dart';
import 'widgets/movie_detail_description.dart';
import 'widgets/movie_detail_header.dart';
import 'widgets/movie_detail_schedule_card.dart';
import 'widgets/movie_empty_message.dart';

class MovieDetailView extends StatefulWidget {
  const MovieDetailView({
    super.key,
    required this.movie,
    this.showtimes = const [],
    this.isLoadingShowtimes = false,
    this.onShowtimeSelected,
    this.onBack,
    this.formatLabel,
    this.genreLabel,
    this.classificationLabel,
  });

  final MovieEntity movie;
  final List<ShowtimeEntity> showtimes;
  final bool isLoadingShowtimes;
  final ValueChanged<ShowtimeEntity>? onShowtimeSelected;
  final VoidCallback? onBack;
  final String? formatLabel;
  final String? genreLabel;
  final String? classificationLabel;

  @override
  State<MovieDetailView> createState() => _MovieDetailViewState();
}

class _MovieDetailViewState extends State<MovieDetailView> {
  static final DateFormat _timeFormatter = DateFormat('HH:mm');

  DateTime? _selectedDate;
  String? _expandedCinemaKey;

  @override
  void initState() {
    super.initState();
    _selectedDate = _resolveSelectedDate(widget.showtimes, null);
    _expandedCinemaKey = _resolveExpandedKey(
      widget.showtimes,
      _selectedDate,
      null,
    );
  }

  @override
  void didUpdateWidget(covariant MovieDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showtimes != widget.showtimes) {
      setState(() {
        _selectedDate = _resolveSelectedDate(widget.showtimes, _selectedDate);
        _expandedCinemaKey = _resolveExpandedKey(
          widget.showtimes,
          _selectedDate,
          _expandedCinemaKey,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dates = _uniqueDates(widget.showtimes);
    final showtimesForDate = _filterShowtimesByDate(
      widget.showtimes,
      _selectedDate,
    );
    final groupedSchedules = _groupShowtimesByCinema(showtimesForDate);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BackButton(onPressed: widget.onBack),
              const SizedBox(height: 16),
              MovieDetailHeader(
                movie: widget.movie,
                formatLabel: widget.formatLabel,
                genreLabel: widget.genreLabel,
                classificationLabel:
                    widget.classificationLabel ??
                    widget.movie.ageRestriction ??
                    'Chua phan loai',
                onPlayPressed: _shouldEnableTrailer ? _handlePlayTrailer : null,
              ),
              const SizedBox(height: 16),
              _CreditsInfo(
                director: widget.movie.director,
                actors: widget.movie.actors,
              ),
              const SizedBox(height: 16),
              MovieDetailDescription(description: widget.movie.description),
              const SizedBox(height: 24),
              MovieDetailDateSelector(
                isLoading: widget.isLoadingShowtimes,
                dates: dates,
                selectedDate: _selectedDate,
                dateLabelBuilder: _dateLabel,
                onDateSelected: (date) => setState(() {
                  _selectedDate = date;
                  _expandedCinemaKey = _resolveExpandedKey(
                    widget.showtimes,
                    _selectedDate,
                    _expandedCinemaKey,
                  );
                }),
              ),
              const SizedBox(height: 16),
              if (widget.isLoadingShowtimes)
                const Center(child: CircularProgressIndicator())
              else if (groupedSchedules.isEmpty)
                const MovieEmptyMessage(
                  message: 'Chua co lich chieu cho phim nay',
                  icon: Icons.sentiment_dissatisfied_outlined,
                )
              else
                Column(
                  children: [
                    for (final schedule in groupedSchedules)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MovieScheduleCard(
                          title: schedule.title,
                          address: schedule.address,
                          
                          times: schedule.showtimes
                              .map(
                                (show) => ShowtimePillData(
                                  label: _timeFormatter.format(show.startTime),
                                  subLabel:
                                      show.screen?.screenName ??
                                      show.format ??
                                      show.language ??
                                      '2D',
                                  onTap: widget.onShowtimeSelected != null
                                      ? () => widget.onShowtimeSelected!(show)
                                      : null,
                                ),
                              )
                              .toList(),
                          isExpanded: schedule.key == _expandedCinemaKey,
                          onToggle: () {
                            setState(() {
                              _expandedCinemaKey =
                                  _expandedCinemaKey == schedule.key
                                  ? null
                                  : schedule.key;
                            });
                          },
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  static List<DateTime> _uniqueDates(List<ShowtimeEntity> showtimes) {
    final seen = <String>{};
    final results = <DateTime>[];

    for (final show in showtimes) {
      final clean = DateTime(
        show.showDate.year,
        show.showDate.month,
        show.showDate.day,
      );
      final key = '${clean.year}-${clean.month}-${clean.day}';
      if (seen.add(key)) {
        results.add(clean);
      }
    }
    results.sort();
    return results;
  }

  static DateTime? _resolveSelectedDate(
    List<ShowtimeEntity> showtimes,
    DateTime? current,
  ) {
    final dates = _uniqueDates(showtimes);
    if (dates.isEmpty) {
      return null;
    }
    if (current == null) {
      return dates.first;
    }
    return dates.any((date) => _isSameDate(date, current))
        ? current
        : dates.first;
  }

  static List<ShowtimeEntity> _filterShowtimesByDate(
    List<ShowtimeEntity> showtimes,
    DateTime? date,
  ) {
    if (date == null) {
      return const [];
    }
    final filtered =
        showtimes.where((show) => _isSameDate(show.showDate, date)).toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return filtered;
  }

  static List<_CinemaSchedule> _groupShowtimesByCinema(
    List<ShowtimeEntity> showtimes,
  ) {
    if (showtimes.isEmpty) {
      return const [];
    }

    final map = <String, _CinemaSchedule>{};
    for (final show in showtimes) {
      final cinema = show.screen?.cinema;
      final screen = show.screen;
      final key = cinema != null
          ? 'cinema-${cinema.id}'
          : 'screen-${screen?.id ?? show.id}';
      final title = cinema != null
          ? '${cinema.cinemaName} ${cinema.city.isNotEmpty ? '(${cinema.city})' : ''}'
                .trim()
          : screen?.screenName ?? 'Rap ${show.id}';
      final address = cinema?.address?.trim();
      final image = cinema?.image;

      map.putIfAbsent(
        key,
        () => _CinemaSchedule(
          key: key,
          title: title,
          address: (address == null || address.isEmpty)
              ? (cinema?.city ?? 'Dang cap nhat')
              : address,
          imageUrl: image,
          showtimes: [],
        ),
      );
      map[key]!.showtimes.add(show);
    }
    return map.values.toList();
  }

  static String? _resolveExpandedKey(
    List<ShowtimeEntity> showtimes,
    DateTime? selectedDate,
    String? currentKey,
  ) {
    final grouped = _groupShowtimesByCinema(
      _filterShowtimesByDate(showtimes, selectedDate),
    );
    if (grouped.isEmpty) {
      return null;
    }
    if (currentKey == null ||
        grouped.indexWhere((schedule) => schedule.key == currentKey) == -1) {
      return grouped.first.key;
    }
    return currentKey;
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_isSameDate(date, today)) {
      return 'Hom nay';
    }
    const names = [
      'Chu nhat',
      'Thu 2',
      'Thu 3',
      'Thu 4',
      'Thu 5',
      'Thu 6',
      'Thu 7',
    ];
    return names[date.weekday % 7];
  }

  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool get _shouldEnableTrailer =>
      widget.movie.trailerUrl != null && widget.movie.trailerUrl!.isNotEmpty;

  Future<void> _handlePlayTrailer() async {
    final trailerUrl = widget.movie.trailerUrl;
    if (trailerUrl == null || trailerUrl.isEmpty) {
      _showSnackBar('Phim chua co trailer.');
      return;
    }
    final uri = Uri.tryParse(trailerUrl);
    if (uri == null) {
      _showSnackBar('Lien ket trailer khong hop le.');
      return;
    }
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!success) {
      _showSnackBar('Khong the mo trailer.');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CinemaSchedule {
  _CinemaSchedule({
    required this.key,
    required this.title,
    required this.address,
    required this.imageUrl,
    required this.showtimes,
  });

  final String key;
  final String title;
  final String address;
  final String? imageUrl;
  final List<ShowtimeEntity> showtimes;
}

class _BackButton extends StatelessWidget {
  const _BackButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: onPressed ?? () => Navigator.maybePop(context),
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withValues(alpha: 0.05),
          shape: const CircleBorder(),
        ),
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
    );
  }
}

class _CreditsInfo extends StatelessWidget {
  const _CreditsInfo({this.director, this.actors});

  final String? director;
  final String? actors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget infoRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
            children: [
              TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              TextSpan(text: value.isEmpty ? 'Dang cap nhat' : value),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        infoRow('Dao dien', director?.trim() ?? ''),
        infoRow('Dien vien', actors?.trim() ?? ''),
      ],
    );
  }
}
