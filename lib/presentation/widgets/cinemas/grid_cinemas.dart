import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/helpers/location_helper.dart';
import '../../../../data/models/dto/cinema_dto.dart';
import '../../../../data/models/entity/cinemas_entity.dart';
import '../../bloc/cinema/cinema_bloc.dart';
import '../../bloc/cinema/cinema_event.dart';
import '../../bloc/cinema/cinema_state.dart';
import '../../bloc/common/bloc_status.dart';
import 'card_cinemas.dart';
import 'detail_cinemas.dart';

class CinemasListView extends StatefulWidget {
  const CinemasListView({
    super.key,
    required this.cinemas,
    this.isLoading = false,
    this.onCinemaTap,
    this.showDistance = true,
  });

  final List<CinemaEntity> cinemas;
  final bool isLoading;
  final ValueChanged<CinemaEntity>? onCinemaTap;
  final bool showDistance;

  @override
  State<CinemasListView> createState() => _CinemasListViewState();
}

class _CinemasListViewState extends State<CinemasListView> {
  LocationResult? _userLocation;
  bool _locationError = false;
  bool _locationLoading = false;
  final Map<int, Future<double?>> _distanceFutures = {};

  @override
  void initState() {
    super.initState();
    if (widget.showDistance && widget.cinemas.isNotEmpty) {
      _initLocation();
    }
  }

  Future<void> _initLocation() async {
    setState(() {
      _locationLoading = true;
      _locationError = false;
    });
    try {
      final loc = await LocationHelper.getCurrentLocation(needAddress: false);
      setState(() {
        _userLocation = loc;
        _locationLoading = false;
      });
    } catch (_) {
      setState(() {
        _locationError = true;
        _locationLoading = false;
      });
    }
  }

  Future<double?> _distanceForCinema(CinemaEntity cinema) {
    if (!widget.showDistance || _userLocation == null) {
      return Future.value(null);
    }
    if (_distanceFutures.containsKey(cinema.id)) {
      return _distanceFutures[cinema.id]!;
    }
    _distanceFutures[cinema.id] = _computeDistance(cinema);
    return _distanceFutures[cinema.id]!;
  }

  Future<double?> _computeDistance(CinemaEntity cinema) async {
    if (_userLocation == null) return null;
    final query = [cinema.address, cinema.city].where((e) => e.trim().isNotEmpty).join(', ');
    if (query.isEmpty) return null;

    try {
      final results = await locationFromAddress(query);
      if (results.isEmpty) return null;
      final dest = results.first;
      final meters = Geolocator.distanceBetween(
        _userLocation!.latitude,
        _userLocation!.longitude,
        dest.latitude,
        dest.longitude,
      );
      return meters / 1000;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const _SkeletonList();
    }
    if (widget.cinemas.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có rạp nào.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      children: [
        if (widget.showDistance && _locationError)
          _LocationHint(onRetry: _initLocation),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final cinema = widget.cinemas[index];
              return FutureBuilder<double?>(
                future: _distanceForCinema(cinema),
                builder: (context, snapshot) {
                  return CinemaCard(
                    cinema: cinema,
                    distanceKm: snapshot.data,
                    onTap: () => widget.onCinemaTap?.call(cinema),
                  );
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: widget.cinemas.length,
          ),
        ),
      ],
    );
  }
}

class _LocationHint extends StatelessWidget {
  const _LocationHint({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_off_outlined, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Chưa lấy được vị trí để tính khoảng cách. Cấp quyền Location và thử lại.',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.white.withOpacity(0.08);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (_, __) => Container(
        height: 100,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: 4,
    );
  }
}

class CinemasTab extends StatelessWidget {
  const CinemasTab({super.key});

  static const _defaultQuery = CinemaQueryDto(limit: 20, status: 'active');

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          serviceLocator<CinemaBloc>()..add(const CinemasRequested(query: _defaultQuery)),
      child: const _CinemasView(),
    );
  }
}

class _CinemasView extends StatelessWidget {
  const _CinemasView();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF0F1014)],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: BlocBuilder<CinemaBloc, CinemasState>(
                builder: (context, state) {
                  if (state.status.isLoading && state.items.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF8D4CE8)),
                    );
                  }
                  if (state.status.isFailure && state.items.isEmpty) {
                    return _CinemaError(
                      message: state.errorMessage ?? 'Không tải được danh sách rạp.',
                      onRetry: () => context
                          .read<CinemaBloc>()
                          .add(const CinemasRequested(query: CinemasTab._defaultQuery)),
                    );
                  }
                  return CinemasListView(
                    cinemas: state.items,
                    isLoading: state.status.isLoading,
                    onCinemaTap: (cinema) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CinemaDetailPage(cinema: cinema),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.location_city, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'MUA VÉ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Rạp gần bạn',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _CinemaError extends StatelessWidget {
  const _CinemaError({required this.message, required this.onRetry});

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
            const Icon(Icons.error_outline, color: Colors.white70, size: 40),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
