import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/entity/movie_entity.dart';

class ComingSoonMovieCard extends StatefulWidget {
  final MovieEntity movie;
  final VoidCallback? onTap;
  final double width;

  const ComingSoonMovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.width = 150, required void Function() onNotifyPressed,
  });

  @override
  State<ComingSoonMovieCard> createState() => _ComingSoonMovieCardState();
}

class _ComingSoonMovieCardState extends State<ComingSoonMovieCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  static final DateFormat _releaseDateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) => _controller.forward();
  void _handleTapUp(TapUpDetails details) => _controller.reverse();
  void _handleTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPoster(),
              const SizedBox(height: 10),
              _buildReleaseDate(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoster() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Image.network(
            _posterUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF1A1A2E),
              child: const Icon(
                Icons.movie_outlined,
                size: 48,
                color: Colors.white54,
              ),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: const Color(0xFF1A1A2E),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: const Color(0xFF8D4CE8),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReleaseDate() {
    return Text(
      _releaseDateFormat.format(widget.movie.releaseDate),
      style: const TextStyle(
        color: Color(0xFF7E57C2),
        fontWeight: FontWeight.w700,
        fontSize: 14,
        letterSpacing: 0.3,
      ),
    );
  }

  String get _posterUrl {
    if (widget.movie.posterImage?.isNotEmpty == true) {
      return widget.movie.posterImage!;
    }
    return 'https://via.placeholder.com/300x450?text=No+Image';
  }
}
