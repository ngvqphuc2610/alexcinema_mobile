import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/dependency_injection.dart';
import '../../data/models/dto/entertainment_dto.dart';
import '../../data/models/dto/membership_dto.dart';
import '../../data/models/entity/entertainment_entity.dart';
import '../../data/models/entity/membership_entity.dart';
import '../bloc/common/bloc_status.dart';
import '../bloc/entertainment/entertainment_bloc.dart';
import '../bloc/entertainment/entertainment_event.dart';
import '../bloc/entertainment/entertainment_state.dart';
import '../bloc/membership/membership_bloc.dart';
import '../bloc/membership/membership_event.dart';
import '../bloc/membership/membership_state.dart';
import '../widgets/entertaiments/card_entertaiment.dart';
import '../widgets/member-ships/card_membership.dart';
import '../widgets/member-ships/detail_membership.dart';
import '../widgets/entertaiments/detail_entertaimet.dart';

class EnterMemshipPage extends StatefulWidget {
  const EnterMemshipPage({super.key});

  @override
  State<EnterMemshipPage> createState() => _EnterMemshipPageState();
}

class _EnterMemshipPageState extends State<EnterMemshipPage> {
  int _tabIndex = 0; // 0: entertainment, 1: membership

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entertaiment & Membership'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _TabSwitcher(
            index: _tabIndex,
            onChanged: (value) => setState(() => _tabIndex = value),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _tabIndex == 0 ? const _EntertainmentSection() : const _MembershipSection(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TabButton(
          label: 'Entertaiment',
          selected: index == 0,
          onTap: () => onChanged(0),
        ),
        const SizedBox(width: 12),
        _TabButton(
          label: 'Membership',
          selected: index == 1,
          onTap: () => onChanged(1),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF5B21B6) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF5B21B6)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF5B21B6),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EntertainmentSection extends StatelessWidget {
  const _EntertainmentSection();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<EntertainmentBloc>()
        ..add(
          const EntertainmentRequested(
            query: EntertainmentQueryDto(status: 'active', limit: 50),
          ),
        ),
      child: BlocBuilder<EntertainmentBloc, EntertainmentState>(
        builder: (context, state) {
          if (state.status.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status.isFailure) {
            return Center(child: Text(state.errorMessage ?? 'Không tải được danh sách sự kiện'));
          }
          if (state.items.isEmpty) {
            return const Center(child: Text('Chưa có sự kiện'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, index) {
              final item = state.items[index];
              return EntertainmentCard(
                item: item,
                onTap: () => _openEntertainmentDetail(context, item),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: state.items.length,
          );
        },
      ),
    );
  }

  void _openEntertainmentDetail(BuildContext context, EntertainmentEntity item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EntertainmentDetailPage(itemId: item.id, prefetched: item)),
    );
  }
}

class _MembershipSection extends StatelessWidget {
  const _MembershipSection();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<MembershipBloc>()
        ..add(
          const MembershipsRequested(
            query: MembershipQueryDto(status: 'active', limit: 50),
          ),
        ),
      child: BlocBuilder<MembershipBloc, MembershipState>(
        builder: (context, state) {
          if (state.status.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status.isFailure) {
            return Center(child: Text(state.errorMessage ?? 'Không tải được hạng thành viên'));
          }
          if (state.items.isEmpty) {
            return const Center(child: Text('Chưa có ưu đãi/hạng thành viên'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, index) {
              final item = state.items[index];
              return MembershipCard(
                item: item,
                onTap: () => _openMembershipDetail(context, item),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: state.items.length,
          );
        },
      ),
    );
  }

  void _openMembershipDetail(BuildContext context, MembershipEntity item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MembershipDetailPage(itemId: item.id, prefetched: item)),
    );
  }
}
