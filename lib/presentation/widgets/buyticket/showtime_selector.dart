import 'package:flutter/material.dart';

import '../../../../data/models/entity/movie_entity.dart';
import '../../../../data/models/entity/showtime_entity.dart';
import 'booking_flow_shell.dart';
import 'seat_map.dart';
import 'ticket_type_selector.dart';

class ShowtimeSelectorPage extends StatefulWidget {
  const ShowtimeSelectorPage({
    super.key,
    required this.movie,
    required this.showtime,
  });

  final MovieEntity movie;
  final ShowtimeEntity showtime;

  @override
  State<ShowtimeSelectorPage> createState() => _ShowtimeSelectorPageState();
}

class _ShowtimeSelectorPageState extends State<ShowtimeSelectorPage> {
  late List<TicketTypeOption> _ticketOptions;

  @override
  void initState() {
    super.initState();
    _ticketOptions = [
      TicketTypeOption(
        name: 'Nằm Người Lớn',
        price: widget.showtime.price > 0 ? widget.showtime.price : 129000,
        seatType: SeatType.single,
      ),
      TicketTypeOption(
        name: 'Nằm HSSV-U22-GV',
        price: (widget.showtime.price > 0 ? widget.showtime.price : 99000) * 0.77,
        seatType: SeatType.single,
      ),
    ];
  }

  int get _totalTickets =>
      _ticketOptions.fold<int>(0, (total, opt) => total + opt.quantity);

  double get _totalPrice => _ticketOptions.fold<double>(
        0,
        (total, opt) => total + opt.quantity * opt.price,
      );

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final showtime = widget.showtime;
    final dateLabel =
        '${showtime.showDate.day}/${showtime.showDate.month}/${showtime.showDate.year}';
    final timeLabel = TimeOfDay.fromDateTime(showtime.startTime).format(context);

    return BookingFlowShell(
      title: movie.title,
      subtitle: 'Suất chiếu: $timeLabel - $dateLabel',
      summaryLines: [
        '${_totalTickets} Ghế',
        'Tổng cộng: ${_formatCurrency(_totalPrice)}',
      ],
      primaryLabel: 'Tiếp tục',
      primaryEnabled: _totalTickets > 0,
      onPrimaryAction: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SeatMapPage(
              movie: movie,
              showtime: showtime,
              ticketOptions: _ticketOptions
                  .map(
                    (e) => TicketTypeOption(
                      name: e.name,
                      price: e.price,
                      description: e.description,
                      quantity: e.quantity,
                      seatType: e.seatType,
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MovieInfoHeader(
              movie: movie,
              showtime: showtime,
              dateLabel: dateLabel,
              timeLabel: timeLabel,
            ),
            const SizedBox(height: 16),
            TicketTypeSelector(
              options: _ticketOptions,
              onChanged: (items) {
                setState(() {
                  _ticketOptions = items
                      .map(
                        (e) => TicketTypeOption(
                          name: e.name,
                          price: e.price,
                          description: e.description,
                          quantity: e.quantity,
                          seatType: e.seatType,
                        ),
                      )
                      .toList();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double price) {
    final text = price.toStringAsFixed(0);
    return '$text đ';
  }
}

class _MovieInfoHeader extends StatelessWidget {
  const _MovieInfoHeader({
    required this.movie,
    required this.showtime,
    required this.dateLabel,
    required this.timeLabel,
  });

  final MovieEntity movie;
  final ShowtimeEntity showtime;
  final String dateLabel;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: movie.posterImage != null
                ? Image.network(
                    movie.posterImage!,
                    width: 80,
                    height: 110,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 80,
                    height: 110,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.movie_outlined),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (showtime.format != null && showtime.format!.isNotEmpty)
                      _Chip(text: showtime.format!),
                    if (movie.language != null && movie.language!.isNotEmpty)
                      _Chip(text: movie.language!),
                    if (movie.ageRestriction != null && movie.ageRestriction!.isNotEmpty)
                      _Chip(text: movie.ageRestriction!),
                    _Chip(text: timeLabel),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        showtime.screen?.cinema?.cinemaName ??
                            showtime.screen?.screenName ??
                            'Đang cập nhật',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      'Suất chiếu: $timeLabel - $dateLabel',
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}
