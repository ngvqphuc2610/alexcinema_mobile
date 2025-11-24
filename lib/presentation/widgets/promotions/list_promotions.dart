import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../data/models/dto/promotion_dto.dart';
import '../../bloc/common/bloc_status.dart';
import '../../bloc/promotion/promotion_bloc.dart';
import '../../bloc/promotion/promotion_event.dart';
import '../../bloc/promotion/promotion_state.dart';
import 'card_promotions.dart';
import 'detail_promotions.dart';

class PromotionListPage extends StatelessWidget {
  const PromotionListPage({super.key});

  static const _defaultQuery = PromotionQueryDto(limit: 50, status: 'active');

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          serviceLocator<PromotionBloc>()..add(const PromotionsRequested(query: _defaultQuery)),
      child: const _PromotionListView(),
    );
  }
}

class _PromotionListView extends StatelessWidget {
  const _PromotionListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ưu đãi')),
      body: BlocBuilder<PromotionBloc, PromotionState>(
        builder: (context, state) {
          if (state.status.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status.isFailure && state.items.isEmpty) {
            return _ErrorView(
              message: state.errorMessage ?? 'Không thể tải danh sách ưu đãi.',
              onRetry: () => context
                  .read<PromotionBloc>()
                  .add(const PromotionsRequested(query: PromotionListPage._defaultQuery)),
            );
          }
          if (state.items.isEmpty) {
            return const _EmptyView();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<PromotionBloc>()
                  .add(const PromotionsRequested(query: PromotionListPage._defaultQuery));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, index) {
                final item = state.items[index];
                return PromotionCard(
                  promotion: item,
                  onTap: () => _openDetail(context, item),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: state.items.length,
            ),
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, promotion) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PromotionDetailPage(promotion: promotion)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.black54),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_offer_outlined, size: 42, color: Colors.black45),
            ),
            const SizedBox(height: 12),
            const Text(
              'Chưa có ưu đãi',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Quay lại sau nhé.',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
