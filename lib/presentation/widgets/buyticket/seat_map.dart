import 'package:flutter/material.dart';

import '../../../../data/models/entity/movie_entity.dart';
import '../../../../data/models/entity/showtime_entity.dart';
import 'booking_flow_shell.dart';
import '../products/products_page.dart';
import 'ticket_type_selector.dart';

class Seat {
  Seat({required this.id, required this.type, this.isBooked = false});

  final String id;
  final SeatType type;
  final bool isBooked;
}

class SeatMapPage extends StatefulWidget {
  const SeatMapPage({
    super.key,
    required this.movie,
    required this.showtime,
    required this.ticketOptions,
  });

  final MovieEntity movie;
  final ShowtimeEntity showtime;
  final List<TicketTypeOption> ticketOptions;

  @override
  State<SeatMapPage> createState() => _SeatMapPageState();
}

class _SeatMapPageState extends State<SeatMapPage> {
  late final List<List<Seat?>> _layout;
  final Set<String> _selected = {};

  int get _totalTickets =>
      widget.ticketOptions.fold(0, (sum, opt) => sum + opt.quantity);

  Map<SeatType, int> get _allowedByType {
    final map = <SeatType, int>{};
    for (final opt in widget.ticketOptions) {
      map[opt.seatType] = (map[opt.seatType] ?? 0) + opt.quantity;
    }
    return map;
  }

  Map<SeatType, int> get _selectedByType {
    final map = <SeatType, int>{};
    for (final seat in _flattenSeats()) {
      if (_selected.contains(seat.id)) {
        map[seat.type] = (map[seat.type] ?? 0) + 1;
      }
    }
    return map;
  }

  double get _totalPrice => widget.ticketOptions.fold(
    0,
    (sum, opt) => sum + opt.quantity * opt.price,
  );

  @override
  void initState() {
    super.initState();
    _layout = _buildMockLayout();
  }

  List<List<Seat?>> _buildMockLayout() {
    // Mock layout with a center aisle.
    Seat s(String id, {bool booked = false, SeatType type = SeatType.single}) =>
        Seat(id: id, type: type, isBooked: booked);
    return [
      [s('A01'), s('A02'), null, s('A03'), s('A04')],
      [s('B01'), s('B02'), null, s('B03'), s('B04', booked: true)],
      [s('C01'), s('C02'), null, s('C03'), s('C04')],
      [s('D01'), s('D02'), null, s('D03'), s('D04')],
      [s('E01'), s('E02'), null, s('E03'), s('E04')],
      [
        s('F01', type: SeatType.doubleSeat),
        null,
        null,
        null,
        s('F02', type: SeatType.doubleSeat),
      ],
    ];
  }

  List<Seat> _flattenSeats() {
    return _layout.expand((row) => row.whereType<Seat>()).toList();
  }

  void _toggleSeat(Seat seat) {
    if (seat.isBooked) return;
    final selectedByType = _selectedByType;
    final allowedByType = _allowedByType;

    if (_selected.contains(seat.id)) {
      setState(() {
        _selected.remove(seat.id);
      });
      return;
    }

    final maxForType = allowedByType[seat.type] ?? 0;
    final currentForType = selectedByType[seat.type] ?? 0;
    if (maxForType == 0) {
      _showInfo('Bạn chưa chọn vé cho loại ghế này.');
      return;
    }
    if (currentForType >= maxForType) {
      _showInfo('Đã đủ số ghế cho loại này.');
      return;
    }
    if (_selected.length >= _totalTickets) {
      _showInfo('Bạn đã chọn đủ $_totalTickets ghế.');
      return;
    }

    setState(() {
      _selected.add(seat.id);
    });
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = TimeOfDay.fromDateTime(
      widget.showtime.startTime,
    ).format(context);
    final dateLabel =
        '${widget.showtime.showDate.day}/${widget.showtime.showDate.month}/${widget.showtime.showDate.year}';

    return BookingFlowShell(
      title: widget.movie.title,
      subtitle: 'Chọn ghế - $timeLabel $dateLabel',
      summaryLines: [
        '${_selected.length}/${_totalTickets} Ghế: ${_selected.isEmpty ? '-' : _selected.join(', ')}',
        'Tổng cộng: ${_formatCurrency(_totalPrice)}',
      ],
      primaryLabel: 'Tiếp tục',
      primaryEnabled: _selected.length == _totalTickets,
      onPrimaryAction: () {
        if (_selected.length != _totalTickets) {
          _showInfo('Chọn đủ số ghế đã mua.');
          return;
        }

        // Build seat prices map
        final seatPrices = <String, double>{};
        for (final seatId in _selected) {
          final seat = _flattenSeats().firstWhere((s) => s.id == seatId);
          final ticketType = widget.ticketOptions.firstWhere(
            (opt) => opt.seatType == seat.type,
            orElse: () => widget.ticketOptions.first,
          );
          seatPrices[seatId] = ticketType.price;
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductsPage(
              bookingId: widget
                  .showtime
                  .id, // Using showtime ID as booking ID placeholder
              showtimeId: widget.showtime.id,
              cinemaName:
                  widget.showtime.screen?.cinema?.cinemaName ??
                  'Rạp chiếu phim',
              showtime: DateTime(
                widget.showtime.showDate.year,
                widget.showtime.showDate.month,
                widget.showtime.showDate.day,
                widget.showtime.startTime.hour,
                widget.showtime.startTime.minute,
              ),
              screenName: widget.showtime.screen?.screenName ?? 'Phòng chiếu',
              movieTitle: widget.movie.title,
              posterUrl:
                  widget.movie.posterImage ?? widget.movie.bannerImage ?? '',
              durationText: '${widget.movie.duration} phút',
              tags: [
                if (widget.movie.ageRestriction != null)
                  widget.movie.ageRestriction!,
                if (widget.movie.language != null) widget.movie.language!,
              ],
              selectedSeats: _selected.toList()..sort(),
              seatPrices: seatPrices,
              ticketTotal: _totalPrice,
            ),
          ),
        );
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ScreenHeader(showtime: widget.showtime),
            const SizedBox(height: 20),
            _buildSeatGrid(),
            const SizedBox(height: 16),
            _Legend(),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatGrid() {
    return Column(
      children: _layout
          .map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((seat) {
                  if (seat == null) {
                    return const SizedBox(width: 24);
                  }
                  final isSelected = _selected.contains(seat.id);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _SeatTile(
                      seat: seat,
                      isSelected: isSelected,
                      onTap: () => _toggleSeat(seat),
                    ),
                  );
                }).toList(),
              ),
            ),
          )
          .toList(),
    );
  }

  String _formatCurrency(double price) {
    final text = price.toStringAsFixed(0);
    return '$text đ';
  }
}

class _SeatTile extends StatelessWidget {
  const _SeatTile({
    required this.seat,
    required this.isSelected,
    required this.onTap,
  });

  final Seat seat;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    if (seat.isBooked) {
      bg = Colors.grey.shade300;
      border = Colors.grey.shade400;
    } else if (isSelected) {
      bg = const Color(0xFF00A8E8);
      border = bg;
    } else if (seat.type == SeatType.doubleSeat) {
      bg = const Color(0xFF6A1B9A);
      border = bg;
    } else {
      bg = const Color(0xFFFFA726);
      border = bg;
    }

    return InkWell(
      onTap: seat.isBooked ? null : onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: border, width: 1.2),
        ),
        child: Text(
          seat.id,
          style: TextStyle(
            color: seat.isBooked ? Colors.black54 : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({required this.showtime});

  final ShowtimeEntity showtime;

  @override
  Widget build(BuildContext context) {
    final timeLabel = TimeOfDay.fromDateTime(
      showtime.startTime,
    ).format(context);
    final dateLabel =
        '${showtime.showDate.day}/${showtime.showDate.month}/${showtime.showDate.year}';
    return Column(
      children: [
        Text(
          showtime.screen?.cinema?.cinemaName ?? 'Rạp',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Suất chiếu: $timeLabel - $dateLabel',
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 18),
        Container(
          width: 180,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF7B1FA2),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'MÀN HÌNH',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget item(Color color, String text) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        item(const Color(0xFFFFA726), 'Ghế đơn'),
        item(const Color(0xFF6A1B9A), 'Ghế đôi'),
        item(const Color(0xFF00A8E8), 'Đang chọn'),
        item(Colors.grey.shade400, 'Đã bán'),
      ],
    );
  }
}
