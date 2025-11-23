import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../data/models/dto/membership_dto.dart';
import '../../../data/models/entity/membership_entity.dart';
import '../../bloc/common/bloc_status.dart';
import '../../bloc/membership/membership_bloc.dart';
import '../../bloc/membership/membership_event.dart';
import '../../bloc/membership/membership_state.dart';
import 'card_membership.dart';
import 'detail_membership.dart';

class MembershipGridPage extends StatelessWidget {
  const MembershipGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<MembershipBloc>()
        ..add(
          const MembershipsRequested(
            query: MembershipQueryDto(limit: 50, status: 'active'),
          ),
        ),
      child: const _MembershipGridView(),
    );
  }
}

class _MembershipGridView extends StatelessWidget {
  const _MembershipGridView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hạng thành viên'),
      ),
      body: BlocBuilder<MembershipBloc, MembershipState>(
        builder: (context, state) {
          if (state.status.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status.isFailure) {
            return Center(
              child: Text(state.errorMessage ?? 'Không thể tải danh sách hạng'),
            );
          }
          if (state.items.isEmpty) {
            return const Center(child: Text('Chưa có hạng thành viên'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: state.items.length,
            itemBuilder: (_, index) {
              final item = state.items[index];
              return MembershipCard(
                item: item,
                onTap: () => _openDetail(context, item),
              );
            },
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, MembershipEntity item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MembershipDetailPage(itemId: item.id, prefetched: item)),
    );
  }
}
