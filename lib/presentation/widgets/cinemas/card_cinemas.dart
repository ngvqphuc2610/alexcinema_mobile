import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../data/models/entity/cinemas_entity.dart';

class CinemaCard extends StatelessWidget {
  const CinemaCard({
    super.key,
    required this.cinema,
    this.distanceKm,
    this.onTap,
  });

  final CinemaEntity cinema;
  final double? distanceKm;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPoster(),
            const SizedBox(width: 12),
            Expanded(child: _buildInfo()),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster() {
    final imageUrl = _resolveImageUrl(cinema.image);
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 110,
            height: 80,
            color: const Color(0xFFECECEC),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return _placeholder(isLoading: true);
                    },
                  )
                : _placeholder(),
          ),
        ),
        if (distanceKm != null)
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8D4CE8),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8D4CE8).withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                '${distanceKm!.toStringAsFixed(0)} km',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cinema.cinemaName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1C1C1C),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF616161)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                cinema.address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontSize: 13,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (cinema.contactNumber != null && cinema.contactNumber!.isNotEmpty)
          Row(
            children: [
              const Icon(Icons.phone_in_talk_outlined, size: 16, color: Color(0xFF616161)),
              const SizedBox(width: 6),
              Text(
                cinema.contactNumber!,
                style: const TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _placeholder({bool isLoading = false}) {
    return Container(
      color: const Color(0xFFECECEC),
      child: isLoading
          ? const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
          : Icon(
              Icons.theaters_outlined,
              size: 32,
              color: Colors.black.withOpacity(0.25),
            ),
    );
  }

  String? _resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final env = dotenv.env;
    String? base = env['FLUTTER_API_URL'] ?? env['API_BASE_URL'] ?? env['BASE_URL'];

    // If stored URL is absolute but local (localhost/emulator), rewrite host to current base.
    if (raw.startsWith('http')) {
      final isLocal = raw.contains('localhost') || raw.contains('127.0.0.1') || raw.contains('10.0.2.2');
      if (isLocal && base != null && base.isNotEmpty) {
        final normalizedBase = _normalizeBase(base);
        return raw.replaceFirst(RegExp(r'^https?://[^/]+'), normalizedBase);
      }
      return raw;
    }

    if (base == null || base.isEmpty) return raw;

    base = _normalizeBase(base);

    if (!raw.startsWith('/')) {
      raw = '/$raw';
    }
    return '$base$raw';
  }

  String _normalizeBase(String base) {
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    if (base.toLowerCase().endsWith('/api')) {
      base = base.substring(0, base.length - 4);
    }
    return base;
  }
}
