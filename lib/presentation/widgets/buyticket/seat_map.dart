import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../core/di/injection_container.dart';
import '../../../data/models/entity/movie_entity.dart';
import '../../../data/models/entity/seat_entity.dart';
import '../../../data/models/entity/showtime_entity.dart';
import '../../../data/services/seat_service.dart';
import '../../../data/services/socket_service.dart';
import 'booking_flow_shell.dart';
import '../products/products_page.dart';
import 'ticket_type_selector.dart';

class Seat {
  Seat({
    required this.id,
    required this.type,
    required this.row,
    required this.number,
    this.isBooked = false,
    this.seatTypeId,
  });

  final int id; // Database ID
  final SeatType type;
  final String row;
  final int number;
  final bool isBooked;
  final int? seatTypeId;

  String get label => '$row$number';
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
  List<List<Seat?>> _layout = [];
  final Set<int> _selected = {};
  final Set<int> _lockedByOthers = {}; // Seats locked by other users
  bool _isLoading = true;
  String? _errorMessage;
  bool _socketConnected = false;

  late final SeatService _seatService;
  late final SocketService _socketService;

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
    _seatService = sl<SeatService>();
    _socketService = sl<SocketService>();
    _initializeSocket();
    _loadSeats();
  }

  Future<void> _initializeSocket() async {
    try {
      // Get API base URL from .env file
      final apiUrl = dotenv.env['FLUTTER_API_URL'] ?? 'http://10.0.2.2:3000';

      print('🔌 Connecting to Socket.IO at: $apiUrl');

      // Setup callbacks
      _socketService.onSeatLocked = (seatId, sessionId) {
        if (mounted) {
          setState(() {
            _lockedByOthers.add(seatId);
            // Remove from selected if we had it selected
            _selected.remove(seatId);
          });
          print('🔒 Seat $seatId locked by another user');
        }
      };

      _socketService.onSeatUnlocked = (seatId) {
        if (mounted) {
          setState(() {
            _lockedByOthers.remove(seatId);
          });
          print('🔓 Seat $seatId unlocked');
        }
      };

      _socketService.onConnected = () {
        if (mounted) {
          setState(() => _socketConnected = true);
          print('✅ Socket connected! Session: ${_socketService.sessionId}');
          _joinShowtimeRoom();
        }
      };

      _socketService.onDisconnected = () {
        if (mounted) {
          setState(() => _socketConnected = false);
          print('❌ Socket disconnected');
        }
      };

      _socketService.onError = (error) {
        print('⚠️ Socket error: $error');
      };

      // Connect to socket
      _socketService.connect(apiUrl);
    } catch (e) {
      print('❌ Error initializing socket: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi kết nối real-time: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _joinShowtimeRoom() async {
    try {
      final lockedSeats = await _socketService.joinShowtime(widget.showtime.id);
      if (mounted) {
        setState(() {
          _lockedByOthers.clear();
          for (final seat in lockedSeats) {
            final seatId = seat['seatId'] as int?;
            final sessionId = seat['sessionId'] as String?;
            // Only add if locked by others (not by us)
            if (seatId != null &&
                sessionId != null &&
                sessionId != _socketService.sessionId) {
              _lockedByOthers.add(seatId);
            }
          }
        });
        print(
          '📺 Joined showtime ${widget.showtime.id}, ${_lockedByOthers.length} seats locked by others',
        );
      }
    } catch (e) {
      print('❌ Error joining showtime: $e');
    }
  }

  Future<void> _loadSeats() async {
    if (widget.showtime.screen?.id == null) {
      setState(() {
        _errorMessage = 'Không tìm thấy thông tin phòng chiếu';
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Fetch seats for this screen
      final seats = await _seatService.getSeatsForScreen(
        widget.showtime.screen!.id,
      );
      print(
        '🪑 Fetched ${seats.length} seats for screen ${widget.showtime.screen!.id}',
      );

      // Fetch booked seats for this showtime
      final bookedSeatIds = await _seatService.getBookedSeatsForShowtime(
        widget.showtime.id,
      );
      print(
        '🔒 Booked seat IDs for showtime ${widget.showtime.id}: $bookedSeatIds',
      );

      // Build layout from seats
      final layout = _buildLayoutFromSeats(seats, bookedSeatIds);
      print('📐 Built layout with ${layout.length} rows');

      setState(() {
        _layout = layout;
        _isLoading = false;
        // Clear selected seats when reloading (in case seats are now booked)
        _selected.clear();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải sơ đồ ghế: $e';
        _isLoading = false;
      });
    }
  }

  List<List<Seat?>> _buildLayoutFromSeats(
    List<SeatEntity> seats,
    Set<int> bookedSeatIds,
  ) {
    if (seats.isEmpty) return [];

    print(
      '🏗️ Building layout from ${seats.length} seats, ${bookedSeatIds.length} booked',
    );

    // Group seats by row
    final Map<String, List<SeatEntity>> seatsByRow = {};
    for (final seat in seats) {
      if (seat.isActive) {
        // Only show active seats
        seatsByRow.putIfAbsent(seat.seatRow, () => []).add(seat);
      }
    }

    print('📊 Grouped into ${seatsByRow.length} rows');

    // Sort rows alphabetically
    final sortedRows = seatsByRow.keys.toList()..sort();

    // Build layout with center aisle
    final layout = <List<Seat?>>[];
    int totalBookedInLayout = 0;

    for (final rowKey in sortedRows) {
      final rowSeats = seatsByRow[rowKey]!;
      // Sort by seat number
      rowSeats.sort((a, b) => a.seatNumber.compareTo(b.seatNumber));

      final rowLayout = <Seat?>[];
      final midPoint = rowSeats.length ~/ 2;

      for (int i = 0; i < rowSeats.length; i++) {
        final seatEntity = rowSeats[i];
        final isBooked = bookedSeatIds.contains(seatEntity.idSeats);

        if (isBooked) {
          totalBookedInLayout++;
          print(
            '🔒 Seat ${seatEntity.seatRow}${seatEntity.seatNumber} (ID: ${seatEntity.idSeats}) is BOOKED',
          );
        }

        // Determine seat type
        SeatType seatType = SeatType.single;
        if (seatEntity.seatType != null) {
          if (seatEntity.seatType!.isDouble) {
            seatType = SeatType.doubleSeat;
          } else if (seatEntity.seatType!.isVip) {
            seatType = SeatType.single; // Can add VIP type if needed
          }
        }

        rowLayout.add(
          Seat(
            id: seatEntity.idSeats,
            type: seatType,
            row: seatEntity.seatRow,
            number: seatEntity.seatNumber,
            isBooked: isBooked,
            seatTypeId: seatEntity.idSeatType,
          ),
        );

        // Add aisle in the middle (for rows with 6+ seats)
        if (i == midPoint - 1 && rowSeats.length >= 6) {
          rowLayout.add(null); // Aisle
        }
      }

      layout.add(rowLayout);
    }

    print('✅ Layout complete: $totalBookedInLayout booked seats in layout');

    return layout;
  }

  List<Seat> _flattenSeats() {
    return _layout.expand((row) => row.whereType<Seat>()).toList();
  }

  String _getSelectedSeatLabels() {
    final seats = _flattenSeats();
    final selectedSeats = seats.where((s) => _selected.contains(s.id)).toList();
    selectedSeats.sort((a, b) {
      final rowCompare = a.row.compareTo(b.row);
      if (rowCompare != 0) return rowCompare;
      return a.number.compareTo(b.number);
    });
    return selectedSeats.map((s) => s.label).join(', ');
  }

  Future<void> _toggleSeat(Seat seat) async {
    if (seat.isBooked) return;

    // Check if locked by another user
    if (_lockedByOthers.contains(seat.id)) {
      _showInfo('Ghế này đã có người khác chọn');
      return;
    }

    final selectedByType = _selectedByType;
    final allowedByType = _allowedByType;

    // Deselect - unlock seat
    if (_selected.contains(seat.id)) {
      try {
        await _socketService.unlockSeat(widget.showtime.id, seat.id);
        setState(() {
          _selected.remove(seat.id);
        });
      } catch (e) {
        print('❌ Error unlocking seat: $e');
        _showInfo('Lỗi khi bỏ chọn ghế');
      }
      return;
    }

    // Validation
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

    // Select - lock seat
    try {
      await _socketService.lockSeat(widget.showtime.id, seat.id);
      setState(() {
        _selected.add(seat.id);
      });
    } catch (e) {
      print('❌ Error locking seat: $e');
      _showInfo('Không thể chọn ghế này. Có thể đã có người chọn.');
    }
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    // Unlock all selected seats when leaving
    for (final seatId in _selected) {
      _socketService.unlockSeat(widget.showtime.id, seatId).catchError((e) {
        print('Error unlocking seat on dispose: $e');
        return false; // Return bool to satisfy Future<bool>
      });
    }
    super.dispose();
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
      subtitle:
          'Chọn ghế - $timeLabel $dateLabel ${_socketConnected ? "🟢" : "🔴"}',
      summaryLines: [
        '${_selected.length}/${_totalTickets} Ghế: ${_selected.isEmpty ? '-' : _getSelectedSeatLabels()}',
        'Tổng cộng: ${_formatCurrency(_totalPrice)}',
      ],
      primaryLabel: 'Tiếp tục',
      primaryEnabled: _selected.length == _totalTickets,
      onPrimaryAction: () {
        if (_selected.length != _totalTickets) {
          _showInfo('Chọn đủ số ghế đã mua.');
          return;
        }

        // Build seat labels and prices map
        final seats = _flattenSeats();
        final selectedSeats = seats
            .where((s) => _selected.contains(s.id))
            .toList();
        selectedSeats.sort((a, b) {
          final rowCompare = a.row.compareTo(b.row);
          if (rowCompare != 0) return rowCompare;
          return a.number.compareTo(b.number);
        });

        final seatLabels = selectedSeats.map((s) => s.label).toList();
        final seatIds = selectedSeats.map((s) => s.id).toList();
        final seatPrices = <String, double>{};
        for (final seat in selectedSeats) {
          final ticketType = widget.ticketOptions.firstWhere(
            (opt) => opt.seatType == seat.type,
            orElse: () => widget.ticketOptions.first,
          );
          seatPrices[seat.label] = ticketType.price;
        }

        Navigator.of(context)
            .push(
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
                  screenName:
                      widget.showtime.screen?.screenName ?? 'Phòng chiếu',
                  movieTitle: widget.movie.title,
                  posterUrl:
                      widget.movie.posterImage ??
                      widget.movie.bannerImage ??
                      '',
                  durationText: '${widget.movie.duration} phút',
                  tags: [
                    if (widget.movie.ageRestriction != null)
                      widget.movie.ageRestriction!,
                    if (widget.movie.language != null) widget.movie.language!,
                  ],
                  selectedSeats: seatLabels,
                  seatIds: seatIds,
                  seatPrices: seatPrices,
                  ticketTotal: _totalPrice,
                ),
              ),
            )
            .then((_) {
              // Reload seats when returning from products/payment page
              _loadSeats();
            });
      },
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSeats,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
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
                  final isLockedByOther = _lockedByOthers.contains(seat.id);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _SeatTile(
                      seat: seat,
                      isSelected: isSelected,
                      isLockedByOther: isLockedByOther,
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

class _SeatTile extends StatefulWidget {
  const _SeatTile({
    required this.seat,
    required this.isSelected,
    this.isLockedByOther = false,
    required this.onTap,
  });

  final Seat seat;
  final bool isSelected;
  final bool isLockedByOther;
  final VoidCallback onTap;

  @override
  State<_SeatTile> createState() => _SeatTileState();
}

class _SeatTileState extends State<_SeatTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isLockedByOther) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      )..repeat(reverse: true);

      _pulseAnimation = Tween<double>(
        begin: 1.0,
        end: 1.08,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    } else {
      // Create dummy controller to avoid null checks
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1),
        vsync: this,
      );
      _pulseAnimation = Tween<double>(
        begin: 1.0,
        end: 1.0,
      ).animate(_controller);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textColor;

    if (widget.seat.isBooked) {
      // Permanently booked - dark grey
      bg = Colors.grey.shade400;
      border = Colors.grey.shade600;
      textColor = Colors.white70;
    } else if (widget.isLockedByOther) {
      // Locked by other user - warm yellow-orange with animation
      bg = const Color.fromARGB(255, 255, 95, 77); // Warm yellow-orange
      border = const Color.fromARGB(255, 255, 95, 77); // Darker orange border
      textColor = Colors.white;
    } else if (widget.isSelected) {
      // Selected by current user - blue
      bg = const Color.fromARGB(255, 0, 168, 232);
      border = bg;
      textColor = Colors.white;
    } else if (widget.seat.type == SeatType.doubleSeat) {
      // Available double seat - purple
      bg = const Color.fromARGB(255, 106, 27, 154);
      border = bg;
      textColor = Colors.white;
    } else {
      // Available single seat - light orange
      bg = const Color.fromARGB(255, 255, 167, 38);
      border = bg;
      textColor = Colors.white;
    }

    Widget child = widget.isLockedByOther
        ? const Icon(
            Icons.person, // User icon instead of lock
            color: Colors.white,
            size: 20,
          )
        : Text(
            widget.seat.label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          );

    Widget seatWidget = Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1.5),
      ),
      child: child,
    );

    // Wrap with animation if locked by other
    if (widget.isLockedByOther) {
      seatWidget = ScaleTransition(scale: _pulseAnimation, child: seatWidget);
    }

    return InkWell(
      onTap: (widget.seat.isBooked || widget.isLockedByOther)
          ? null
          : widget.onTap,
      borderRadius: BorderRadius.circular(6),
      child: seatWidget,
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
        item(const Color.fromARGB(255, 255, 95, 77), 'Đang có người giữ'),
      ],
    );
  }
}
