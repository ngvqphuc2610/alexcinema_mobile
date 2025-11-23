import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../data/models/dto/entertainment_dto.dart';
import '../../../data/models/entity/entertainment_entity.dart';
import '../../bloc/common/bloc_status.dart';
import '../../bloc/entertainment/entertainment_bloc.dart';
import '../../bloc/entertainment/entertainment_event.dart';
import '../../bloc/entertainment/entertainment_state.dart';
import 'card_entertaiment.dart';
import 'detail_entertaimet.dart';

class EntertainmentGridPage extends StatelessWidget {
  const EntertainmentGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<EntertainmentBloc>()
        ..add(
          const EntertainmentRequested(
            query: EntertainmentQueryDto(limit: 50, status: 'active'),
          ),
        ),
      child: const _EntertainmentGridView(),
    );
  }
}

class _EntertainmentGridView extends StatelessWidget {
  const _EntertainmentGridView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sự kiện / Giải trí'),
      ),
      body: BlocBuilder<EntertainmentBloc, EntertainmentState>(
        builder: (context, state) {
          if (state.status.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status.isFailure) {
            return Center(
              child: Text(state.errorMessage ?? 'Không thể tải danh sách sự kiện'),
            );
          }
          if (state.items.isEmpty) {
            return const Center(child: Text('Chưa có sự kiện'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: state.items.length,
            itemBuilder: (_, index) {
              final item = state.items[index];
              return EntertainmentCard(
                item: item,
                onTap: () => _openDetail(context, item),
              );
            },
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, EntertainmentEntity item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EntertainmentDetailPage(itemId: item.id)),
    );
  }
}
