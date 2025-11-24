import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../data/models/dto/promotion_dto.dart';
import '../../../data/models/entity/promotion_entity.dart';
import '../../bloc/common/bloc_status.dart';
import '../../bloc/promotion/promotion_bloc.dart';
import '../../bloc/promotion/promotion_event.dart';
import '../../bloc/promotion/promotion_state.dart';
import 'detail_promotions.dart';

class PromotionGridPage extends StatefulWidget {
  const PromotionGridPage({super.key});

  static const _defaultQuery = PromotionQueryDto(limit: 50, status: 'active');

  @override
  State<PromotionGridPage> createState() => _PromotionGridPageState();
}

class _PromotionGridPageState extends State<PromotionGridPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<PromotionBloc>()
        ..add(
          const PromotionsRequested(query: PromotionGridPage._defaultQuery),
        ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Ưu đãi nổi bật')),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: BlocBuilder<PromotionBloc, PromotionState>(
            builder: (context, state) {
              if (state.status.isLoading && state.items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status.isFailure && state.items.isEmpty) {
                return _ErrorView(
                  message:
                      state.errorMessage ?? 'Không thể tải danh sách ưu đãi.',
                  onRetry: () => context.read<PromotionBloc>().add(
                    const PromotionsRequested(
                      query: PromotionGridPage._defaultQuery,
                    ),
                  ),
                );
              }

              if (state.items.isEmpty) {
                return const _EmptyView();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PromotionBloc>().add(
                    const PromotionsRequested(
                      query: PromotionGridPage._defaultQuery,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8D4CE8), Color(0xFFB565F5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF8D4CE8,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.card_giftcard_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Ưu đãi',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: _buildCarousel(state)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Center(
                        child: AnimatedSmoothIndicator(
                          activeIndex: _currentIndex,
                          count: state.items.length,
                          effect: ExpandingDotsEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            spacing: 6,
                            activeDotColor: const Color(0xFF8D4CE8),
                            dotColor: Colors.grey.withOpacity(0.4),
                            expansionFactor: 3,
                          ),
                          onDotClicked: (index) {
                            _carouselController.animateToPage(index);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel(PromotionState state) {
    return CarouselSlider.builder(
      carouselController: _carouselController,
      itemCount: state.items.length,
      options: CarouselOptions(
        height: 260,
        viewportFraction: 0.9,
        enlargeCenterPage: true,
        enlargeFactor: 0.12,
        enableInfiniteScroll: state.items.length > 1,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        autoPlayAnimationDuration: const Duration(milliseconds: 700),
        onPageChanged: (index, _) => setState(() => _currentIndex = index),
      ),
      itemBuilder: (context, index, realIndex) {
        final item = state.items[index];
        final isActive = index == _currentIndex;
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: isActive ? 6 : 14,
            ),
            child: Transform.scale(
              scale: isActive ? 1.0 : 0.92,
              child: Opacity(
                opacity: isActive ? 1 : 0.8,
                child: GestureDetector(
                  onTap: () => _openDetail(context, item),
                  child: _PromotionHeroCard(
                    promotion: item,
                    isActive: isActive,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openDetail(BuildContext context, PromotionEntity promotion) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PromotionDetailPage(promotion: promotion),
      ),
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
            ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
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
              child: const Icon(
                Icons.local_offer_outlined,
                size: 42,
                color: Colors.black45,
              ),
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

class _PromotionHeroCard extends StatelessWidget {
  const _PromotionHeroCard({required this.promotion, required this.isActive});

  final PromotionEntity promotion;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(promotion.image);
    final discountLabel = _buildDiscountLabel();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isActive ? 0.25 : 0.15),
            blurRadius: isActive ? 26 : 16,
            offset: const Offset(0, 16),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF7B1FA2),
                    Color(0xFF512DA8),
                  ],
                ),
              ),
            ),
            if (imageUrl != null)
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.12),
                    Colors.black.withOpacity(0.45),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: const Text(
                          'ƯU ĐÃI HOT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (discountLabel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade400,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.shade200.withOpacity(0.6),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Text(
                            discountLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF4C1D95),
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    promotion.title.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          promotion.promotionCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          promotion.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (promotion.description != null && promotion.description!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      promotion.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _buildDiscountLabel() {
    if (promotion.discountPercent != null) {
      final percent = promotion.discountPercent!;
      return '-${percent.toStringAsFixed(percent % 1 == 0 ? 0 : 1)}%';
    }
    if (promotion.discountAmount != null) {
      final amount = promotion.discountAmount!;
      if (amount >= 1000) {
        return '-${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}K';
      }
      return '-$amount';
    }
    return null;
  }

  String? _resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final env = dotenv.env;
    String? base = env['FLUTTER_API_URL'] ?? env['API_BASE_URL'] ?? env['BASE_URL'];

    if (raw.startsWith('http')) {
      final isLocal =
          raw.contains('localhost') || raw.contains('127.0.0.1') || raw.contains('10.0.2.2');
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
