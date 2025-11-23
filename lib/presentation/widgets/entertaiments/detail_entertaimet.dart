import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../data/models/entity/entertainment_entity.dart';
import '../../bloc/common/bloc_status.dart';
import '../../bloc/entertainment/entertainment_bloc.dart';
import '../../bloc/entertainment/entertainment_event.dart';
import '../../bloc/entertainment/entertainment_state.dart';

class EntertainmentDetailPage extends StatelessWidget {
  const EntertainmentDetailPage({super.key, required this.itemId, this.prefetched});

  final int itemId;
  final EntertainmentEntity? prefetched;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<EntertainmentBloc>()
        ..add(
          EntertainmentRequested(
            query: null,
          ),
        ),
      child: _EntertainmentDetailView(prefetched: prefetched),
    );
  }
}

class _EntertainmentDetailView extends StatelessWidget {
  _EntertainmentDetailView({this.prefetched});

  final EntertainmentEntity? prefetched;
  final DateFormat _dateFmt = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sự kiện'),
      ),
      body: BlocBuilder<EntertainmentBloc, EntertainmentState>(
        builder: (context, state) {
          final item = state.items.isNotEmpty ? state.items.firstWhere((e) => e.id == prefetched?.id || e.id == state.lastQuery?.page) : prefetched;
          if (state.status.isLoading && item == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (item == null) {
            return Center(
              child: Text(state.errorMessage ?? 'Không tìm thấy sự kiện'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroImage(imageUrl: item.imageUrl),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Chip(
                      label:
                          '${_dateFmt.format(item.startDate)} - ${item.endDate != null ? _dateFmt.format(item.endDate!) : 'N/A'}',
                    ),
                    const SizedBox(width: 8),
                    _Chip(label: item.status),
                    if (item.featured == true) ...[
                      const SizedBox(width: 8),
                      _Chip(label: 'Nổi bật', color: Colors.orange.shade100, textColor: Colors.orange.shade800),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                if (item.description != null && item.description!.isNotEmpty)
                  Text(
                    item.description!,
                    style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final resolved = _resolveImageUrl(imageUrl);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 220,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: resolved != null
            ? Image.network(
                resolved,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Icon(
      Icons.event_note_outlined,
      color: Colors.grey.shade400,
      size: 48,
    );
  }

  String? _resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final env = dotenv.env;
    String? base = env['FLUTTER_API_URL'] ?? env['API_BASE_URL'] ?? env['BASE_URL'];

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

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.color, this.textColor});

  final String label;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color ?? Colors.deepPurple.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor ?? Colors.deepPurple,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
