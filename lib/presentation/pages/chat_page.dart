import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../data/models/dto/showtime_dto.dart';
import '../../data/models/entity/chat_message_entity.dart';
import '../../data/models/entity/movie_entity.dart';
import '../../data/models/entity/showtime_entity.dart';
import '../../domain/services/gemini_service.dart';
import '../../domain/services/movie_service.dart';
import '../../domain/services/showtime_service.dart';
import '../../domain/services/speech_service.dart';
import '../bloc/chat/chat_cubit.dart';
import '../bloc/chat/chat_state.dart';
import '../widgets/buyticket/showtime_selector.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<ChatCubit>(),
      child: const _ChatPageContent(),
    );
  }
}

class _ChatPageContent extends StatefulWidget {
  const _ChatPageContent();

  @override
  State<_ChatPageContent> createState() => _ChatPageContentState();
}

class _ChatPageContentState extends State<_ChatPageContent> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatCubit>().sendMessage(text);
      _textController.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: const AssetImage(
                'assets/images/avatarchatbox.jpg',
              ),
              onBackgroundImageError: (_, __) {},
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.deepPurple, width: 2),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Alex Cinema',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.isSpeaking ? Icons.volume_off : Icons.volume_up,
                  color: state.isSpeaking ? Colors.deepPurple : Colors.grey,
                ),
                onPressed: () {
                  if (state.isSpeaking) {
                    context.read<ChatCubit>().stopSpeaking();
                  }
                },
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Xóa lịch sử'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'clear') {
                context.read<ChatCubit>().clearChat();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state.messages.isNotEmpty) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      state.messages.length +
                      (state.status == ChatStatus.loading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.messages.length &&
                        state.status == ChatStatus.loading) {
                      return const _TypingIndicator();
                    }

                    final message = state.messages[index];
                    return _MessageBubble(
                      message: message,
                      onSpeak: () => context.read<ChatCubit>().speakMessage(
                        message.content,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _SuggestionsRow(),
          _MessageInput(
            controller: _textController,
            onSend: _sendMessage,
            onVoice: () {
              final cubit = context.read<ChatCubit>();
              if (cubit.state.isListening) {
                cubit.stopVoiceInput();
              } else {
                cubit.startVoiceInput();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.onSpeak});

  final ChatMessage message;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isError = message.isError;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/images/avatarchatbox.jpg'),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Colors.deepPurple
                        : isError
                        ? Colors.red[50]
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : isError
                              ? Colors.red[900]
                              : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                      if (message.isBookingIntent) ...[
                        const SizedBox(height: 8),
                        _BookingIntentCard(bookingData: message.bookingData!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(message.timestamp),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    if (!isUser && !isError) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onSpeak,
                        child: Icon(
                          Icons.volume_up,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _BookingIntentCard extends StatefulWidget {
  const _BookingIntentCard({required this.bookingData});

  final Map<String, dynamic> bookingData;

  @override
  State<_BookingIntentCard> createState() => _BookingIntentCardState();
}

class _BookingIntentCardState extends State<_BookingIntentCard> {
  bool _isLoading = false;

  /// Manual booking - Navigate to movie list or showtime selection
  Future<void> _handleManualBooking() async {
    try {
      final movieName = widget.bookingData['movieName'] as String?;
      final dateStr = widget.bookingData['date'] as String?;
      final timeStr = widget.bookingData['time'] as String?;

      // Try to find the movie if we have the name
      if (movieName != null && movieName.isNotEmpty) {
        setState(() => _isLoading = true);

        final movieService = GetIt.I<MovieService>();
        final moviesResponse = await movieService.getMovies(null);

        final matchingMovie = moviesResponse.items
            .where(
              (m) => m.title.toLowerCase().contains(movieName.toLowerCase()),
            )
            .toList();

        setState(() => _isLoading = false);

        if (matchingMovie.isNotEmpty) {
          // If we found the movie, try to find showtimes
          if (dateStr != null && dateStr.isNotEmpty) {
            await _showShowtimesForMovie(matchingMovie.first, dateStr);
          } else {
            // Just show all showtimes for this movie
            await _showShowtimesForMovie(matchingMovie.first, null);
          }
          return;
        }
      }

      // If no movie name or not found, navigate to home page (movie list)
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);

      // Show message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            movieName != null
                ? 'Không tìm thấy phim "$movieName". Vui lòng chọn phim từ danh sách.'
                : 'Vui lòng chọn phim từ danh sách.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      print('Error in manual booking: $e');
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Auto booking - Try to find exact showtime and navigate directly
  Future<void> _handleAutoBooking() async {
    setState(() => _isLoading = true);

    try {
      // Parse booking data
      print('📋 [BookingIntent] Full data: ${widget.bookingData}');

      final movieName = widget.bookingData['movieName'] as String?;
      final dateStr = widget.bookingData['date'] as String?;
      final timeStr = widget.bookingData['time'] as String?;

      print('📋 [BookingIntent] movieName: $movieName');
      print('📋 [BookingIntent] dateStr: $dateStr');
      print('📋 [BookingIntent] timeStr: $timeStr');

      if (movieName == null || dateStr == null || timeStr == null) {
        _showError(
          'Thông tin không đầy đủ để đặt vé tự động. Vui lòng thử "Chọn suất chiếu".',
        );
        return;
      }

      // Parse date and time
      DateTime? showDate;
      DateTime? showTime;

      try {
        // Parse date (format: dd/MM/yyyy or yyyy-MM-dd)
        final dateParts = dateStr.split('/');
        if (dateParts.length == 3) {
          showDate = DateTime(
            int.parse(dateParts[2]), // year
            int.parse(dateParts[1]), // month
            int.parse(dateParts[0]), // day
          );
        } else {
          showDate = DateTime.parse(dateStr);
        }

        // Parse time (format: HH:mm or HH:mm:ss)
        final timeParts = timeStr.split(':');
        if (timeParts.length >= 2) {
          showTime = DateTime(
            showDate.year,
            showDate.month,
            showDate.day,
            int.parse(timeParts[0]), // hour
            int.parse(timeParts[1]), // minute
          );
        }
      } catch (e) {
        print('Error parsing date/time: $e');
        _showError('Định dạng ngày giờ không hợp lệ');
        return;
      }

      if (showDate == null || showTime == null) {
        _showError('Không thể xác định ngày giờ chiếu');
        return;
      }

      // Search for matching showtime
      final showtimeService = GetIt.I<ShowtimeService>();
      final movieService = GetIt.I<MovieService>();

      // First, find the movie by name
      final moviesResponse = await movieService.getMovies(null);
      final matchingMovie = moviesResponse.items.firstWhere(
        (m) => m.title.toLowerCase().contains(movieName.toLowerCase()),
        orElse: () => throw Exception('Không tìm thấy phim "$movieName"'),
      );

      // Then find showtimes for that movie on the specified date
      final showtimesResponse = await showtimeService.getShowtimes(
        ShowtimeQueryDto(
          movieId: matchingMovie.id,
          showDate: showDate,
          limit: 100,
        ),
      );

      if (showtimesResponse.items.isEmpty) {
        _showError('Không tìm thấy suất chiếu cho phim này vào ngày $dateStr');
        return;
      }

      // Find the showtime that matches the time
      ShowtimeEntity? matchingShowtime;
      for (final showtime in showtimesResponse.items) {
        final showtimeHour = showtime.startTime.hour;
        final showtimeMinute = showtime.startTime.minute;
        final targetHour = showTime.hour;
        final targetMinute = showTime.minute;

        if (showtimeHour == targetHour && showtimeMinute == targetMinute) {
          matchingShowtime = showtime;
          break;
        }
      }

      if (matchingShowtime == null) {
        // If exact match not found, show all showtimes for that day
        _showShowtimeSelection(matchingMovie, showtimesResponse.items);
        return;
      }

      // Navigate to booking screen
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ShowtimeSelectorPage(
            movie: matchingMovie,
            showtime: matchingShowtime!,
          ),
        ),
      );
    } catch (e) {
      print('Error handling booking: $e');
      _showError('Có lỗi xảy ra: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Show showtimes for a specific movie
  Future<void> _showShowtimesForMovie(
    MovieEntity movie,
    String? dateStr,
  ) async {
    try {
      setState(() => _isLoading = true);

      final showtimeService = GetIt.I<ShowtimeService>();

      // Parse date if provided
      DateTime? showDate;
      if (dateStr != null && dateStr.isNotEmpty) {
        try {
          final dateParts = dateStr.split('/');
          if (dateParts.length == 3) {
            showDate = DateTime(
              int.parse(dateParts[2]), // year
              int.parse(dateParts[1]), // month
              int.parse(dateParts[0]), // day
            );
          } else {
            showDate = DateTime.parse(dateStr);
          }
        } catch (e) {
          print('Error parsing date: $e');
        }
      }

      // Query showtimes
      final showtimesResponse = await showtimeService.getShowtimes(
        ShowtimeQueryDto(movieId: movie.id, showDate: showDate, limit: 100),
      );

      setState(() => _isLoading = false);

      if (showtimesResponse.items.isEmpty) {
        _showError(
          'Không tìm thấy suất chiếu cho phim này${showDate != null ? ' vào ngày ${DateFormat('dd/MM/yyyy').format(showDate)}' : ''}',
        );
        return;
      }

      // Show showtime selection dialog
      if (!mounted) return;
      _showShowtimeSelection(movie, showtimesResponse.items);
    } catch (e) {
      print('Error loading showtimes: $e');
      _showError('Có lỗi khi tải suất chiếu: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showShowtimeSelection(
    MovieEntity movie,
    List<ShowtimeEntity> showtimes,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn suất chiếu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[700],
              ),
            ),
            const SizedBox(height: 16),
            ...showtimes.map((showtime) {
              final timeLabel = TimeOfDay.fromDateTime(
                showtime.startTime,
              ).format(context);
              final cinemaName =
                  showtime.screen?.cinema?.cinemaName ?? 'Rạp chiếu phim';
              return ListTile(
                leading: Icon(Icons.access_time, color: Colors.deepPurple[700]),
                title: Text(timeLabel),
                subtitle: Text(cinemaName),
                trailing: Text(
                  '${showtime.price.toStringAsFixed(0)} đ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ShowtimeSelectorPage(
                        movie: movie,
                        showtime: showtime,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.movie, size: 16, color: Colors.deepPurple[700]),
              const SizedBox(width: 4),
              Text(
                'Thông tin đặt vé',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple[700],
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.bookingData['movieName'] != null)
            _InfoRow(
              label: 'Phim',
              value: widget.bookingData['movieName'].toString(),
            ),
          if (widget.bookingData['date'] != null)
            _InfoRow(
              label: 'Ngày',
              value: widget.bookingData['date'].toString(),
            ),
          if (widget.bookingData['time'] != null)
            _InfoRow(
              label: 'Giờ',
              value: widget.bookingData['time'].toString(),
            ),
          if (widget.bookingData['seats'] != null)
            _InfoRow(
              label: 'Số ghế',
              value: widget.bookingData['seats'].toString(),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleManualBooking,
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Chọn suất chiếu'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: BorderSide(color: Colors.deepPurple[200]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleAutoBooking,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.flash_on, size: 18),
                  label: const Text('Đặt ngay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage('assets/images/avatarchatbox.jpg'),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _TypingDot(delay: index * 200),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  const _TypingDot({required this.delay});

  final int delay;

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[400]!.withValues(
              alpha: 0.5 + (_controller.value * 0.5),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class _SuggestionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state.suggestions.isEmpty) return const SizedBox.shrink();

        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = state.suggestions[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(suggestion),
                  onPressed: () =>
                      context.read<ChatCubit>().useSuggestion(suggestion),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.onVoice,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onVoice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              return IconButton(
                onPressed: onVoice,
                icon: Icon(
                  state.isListening ? Icons.mic : Icons.mic_none,
                  color: state.isListening ? Colors.red : Colors.grey[700],
                ),
                style: IconButton.styleFrom(
                  backgroundColor: state.isListening
                      ? Colors.red[50]
                      : Colors.grey[100],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onSend,
            icon: const Icon(Icons.send),
            color: Colors.white,
            style: IconButton.styleFrom(backgroundColor: Colors.deepPurple),
          ),
        ],
      ),
    );
  }
}
