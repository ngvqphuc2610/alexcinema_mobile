import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../data/models/entity/membership_entity.dart';
import '../../bloc/common/bloc_status.dart';
import '../../bloc/membership/membership_bloc.dart';
import '../../bloc/membership/membership_event.dart';
import '../../bloc/membership/membership_state.dart';

class MembershipDetailPage extends StatelessWidget {
  const MembershipDetailPage({super.key, required this.itemId, this.prefetched});

  final int itemId;
  final MembershipEntity? prefetched;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<MembershipBloc>()
        ..add(
          const MembershipsRequested(),
        ),
      child: _MembershipDetailView(itemId: itemId, prefetched: prefetched),
    );
  }
}

class _MembershipDetailView extends StatelessWidget {
  const _MembershipDetailView({required this.itemId, this.prefetched});

  final int itemId;
  final MembershipEntity? prefetched;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết hạng thành viên')),
      body: BlocBuilder<MembershipBloc, MembershipState>(
        builder: (context, state) {
          final item = state.items.firstWhere(
            (e) => e.id == itemId,
            orElse: () => prefetched ?? const MembershipEntity(
              id: 0,
              code: '',
              title: '',
              status: '',
            ),
          );

          if (state.status.isLoading && item.id == 0) {
            return const Center(child: CircularProgressIndicator());
          }
          if (item.id == 0) {
            return Center(child: Text(state.errorMessage ?? 'Không tìm thấy hạng'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroImage(imageUrl: item.image),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                _Tag(label: item.code, color: Colors.deepPurple.withOpacity(0.12), textColor: Colors.deepPurple),
                const SizedBox(height: 12),
                if (item.description != null && item.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      item.description!,
                      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                    ),
                  ),
                if (item.benefits != null && item.benefits!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Quyền lợi', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(item.benefits!, style: const TextStyle(height: 1.4)),
                ],
                if (item.criteria != null && item.criteria!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Điều kiện', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(item.criteria!, style: const TextStyle(height: 1.4)),
                ],
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
        height: 200,
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
      Icons.card_membership_outlined,
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

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.color = const Color(0xFFE5E7EB), this.textColor = const Color(0xFF374151)});

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
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
