import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/dependency_injection.dart';
import '../../data/models/dto/entertainment_dto.dart';
import '../../data/models/dto/promotion_dto.dart';
import '../bloc/common/bloc_status.dart';
import '../bloc/entertainment/entertainment_bloc.dart';
import '../bloc/entertainment/entertainment_event.dart';
import '../bloc/entertainment/entertainment_state.dart';
import '../bloc/promotion/promotion_bloc.dart';
import '../bloc/promotion/promotion_event.dart';
import '../bloc/promotion/promotion_state.dart';
import '../pages/account_page.dart';
import '../pages/home_page.dart';
import '../widgets/products/products_page.dart';
import '../widgets/movies/movies_page.dart';
import 'news/card_news.dart';
import 'news/grid_news.dart';

class NavbarMainShell extends StatefulWidget {
  const NavbarMainShell({super.key});

  @override
  State<NavbarMainShell> createState() => _NavbarMainShellState();
}

class _NavbarMainShellState extends State<NavbarMainShell>
    with SingleTickerProviderStateMixin {
  static const int _newsPageIndex = 2;

  final List<_NavDestination> _destinations = const [
    _NavDestination(
      icon: Icons.home_outlined,
      label: 'Trang chủ',
      pageIndex: 0,
    ),
    _NavDestination(icon: Icons.movie_outlined, label: 'Phim', pageIndex: 1),
    _NavDestination(
      icon: Icons.confirmation_number_outlined,
      label: 'Ưu đãi',
      pageIndex: 3,
    ),
    _NavDestination(
      icon: Icons.person_outline,
      label: 'Tài khoản',
      pageIndex: 4,
    ),
  ];

  late final List<Widget> _pages;
  int _currentPage = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _pages = const [
      HomePage(),
      MoviesPage(),
      _NewsTab(),
      ProductsPage(),
      AccountPage(),
    ];
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: IndexedStack(index: _currentPage, children: _pages),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildFab(BuildContext context) {
    final isActive = _currentPage == _newsPageIndex;
    return AnimatedScale(
      scale: isActive ? 1.15 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: FloatingActionButton(
        heroTag: 'newsFab',
        backgroundColor: isActive
            ? Theme.of(context).primaryColor
            : Colors.deepPurple,
        elevation: isActive ? 8 : 3,
        onPressed: () => _onSelectPage(_newsPageIndex),
        child: const Icon(Icons.campaign_outlined, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            for (var i = 0; i < _destinations.length; i++) ...[
              if (i == 2) const SizedBox(width: 48),
              Expanded(
                child: _NavButton(
                  destination: _destinations[i],
                  isActive: _currentPage == _destinations[i].pageIndex,
                  onTap: () => _onSelectPage(_destinations[i].pageIndex),
                  activeColor: theme.primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onSelectPage(int index) {
    if (index == _currentPage) return;
    setState(() => _currentPage = index);
    _animationController.forward(from: 0);
  }
}

class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.label,
    required this.pageIndex,
  });

  final IconData icon;
  final String label;
  final int pageIndex;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.destination,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
  });

  final _NavDestination destination;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : Colors.grey.shade500;
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: color,
      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                transform: Matrix4.translationValues(0, isActive ? -2 : 0, 0),
                child: Icon(destination.icon, color: color),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              style: textStyle ?? const TextStyle(),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: Text(
                destination.label,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.upcoming_outlined,
                size: 48,
                color: Colors.deepPurple.shade200,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Nội dung sẽ sớm được cập nhật.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsTab extends StatelessWidget {
  const _NewsTab();

  static const _newsQuery = EntertainmentQueryDto(
    limit: 10,
    status: 'active',
    featured: true,
  );
  static const _promoQuery = PromotionQueryDto(limit: 10, status: 'active');

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              serviceLocator<EntertainmentBloc>()
                ..add(const EntertainmentRequested(query: _newsQuery)),
        ),
        BlocProvider(
          create: (_) =>
              serviceLocator<PromotionBloc>()
                ..add(const PromotionsRequested(query: _promoQuery)),
        ),
      ],
      child: const _NewsTabView(),
    );
  }
}

enum _NewsSegment { news, promotions }

class _NewsTabView extends StatefulWidget {
  const _NewsTabView();

  @override
  State<_NewsTabView> createState() => _NewsTabViewState();
}

class _NewsTabViewState extends State<_NewsTabView>
    with AutomaticKeepAliveClientMixin {
  _NewsSegment _segment = _NewsSegment.news;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TIN TỨC & ƯU ĐÃI',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => _refreshCurrent(context),
                ),
              ],
            ),
          ),
          const Divider(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SegmentedSelector(
              segment: _segment,
              onSelect: (segment) => setState(() => _segment = segment),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _segment == _NewsSegment.news
                  ? BlocBuilder<EntertainmentBloc, EntertainmentState>(
                      key: const ValueKey('news'),
                      builder: _buildNewsList,
                    )
                  : BlocBuilder<PromotionBloc, PromotionState>(
                      key: const ValueKey('promotions'),
                      builder: _buildPromotionList,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(BuildContext context, EntertainmentState state) {
    if (state.status.isLoading && state.items.isEmpty) {
      return const _LoadingView(message: 'Đang tải tin tức...');
    }

    if (state.status.isFailure && state.items.isEmpty) {
      return _ErrorView(
        message: state.errorMessage ?? 'Không thể tải tin tức.',
        onRetry: () => _refreshNews(context),
      );
    }

    final newsItems = state.items
        .map(
          (item) => NewsCardData(
            title: item.title,
            description: item.description,
            imageUrl: item.imageUrl,
            badgeLabel: 'Tin tức',
            publishedAt: item.startDate,
          ),
        )
        .toList(growable: false);

    return RefreshIndicator(
      onRefresh: () => _refreshNews(context),
      child: NewsGrid(
        items: newsItems,
        emptyMessage: 'Hiện chưa có tin tức mới.',
      ),
    );
  }

  Widget _buildPromotionList(BuildContext context, PromotionState state) {
    if (state.status.isLoading && state.items.isEmpty) {
      return const _LoadingView(message: 'Đang tải ưu đãi...');
    }

    if (state.status.isFailure && state.items.isEmpty) {
      return _ErrorView(
        message: state.errorMessage ?? 'Không thể tải ưu đãi.',
        onRetry: () => _refreshPromotions(context),
      );
    }

    final items = state.items
        .map(
          (promo) => NewsCardData(
            title: promo.title,
            description:
                promo.description ??
                'Mã: ${promo.promotionCode} • Giảm lên tới ${promo.discountPercent ?? promo.discountAmount ?? ''}',
            imageUrl: null,
            badgeLabel: 'Ưu đãi',
            publishedAt: promo.startDate,
          ),
        )
        .toList(growable: false);

    return RefreshIndicator(
      onRefresh: () => _refreshPromotions(context),
      child: NewsGrid(items: items, emptyMessage: 'Chưa có ưu đãi khả dụng.'),
    );
  }

  Future<void> _refreshNews(BuildContext context) async {
    context.read<EntertainmentBloc>().add(
      const EntertainmentRequested(query: _NewsTab._newsQuery),
    );
  }

  Future<void> _refreshPromotions(BuildContext context) async {
    context.read<PromotionBloc>().add(
      const PromotionsRequested(query: _NewsTab._promoQuery),
    );
  }

  void _refreshCurrent(BuildContext context) {
    if (_segment == _NewsSegment.news) {
      _refreshNews(context);
    } else {
      _refreshPromotions(context);
    }
  }
}

class _SegmentedSelector extends StatelessWidget {
  const _SegmentedSelector({required this.segment, required this.onSelect});

  final _NewsSegment segment;
  final ValueChanged<_NewsSegment> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.primaryColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.grey.shade200,
      ),
      child: Row(
        children: [
          _SegmentButton(
            label: 'Tin tức',
            isSelected: segment == _NewsSegment.news,
            onTap: () => onSelect(_NewsSegment.news),
            activeColor: activeColor,
          ),
          _SegmentButton(
            label: 'Ưu đãi',
            isSelected: segment == _NewsSegment.promotions,
            onTap: () => onSelect(_NewsSegment.promotions),
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: isSelected ? Colors.white : Colors.transparent,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isSelected ? activeColor : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(message),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}