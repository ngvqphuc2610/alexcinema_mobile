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
import '../widgets/cinemas/grid_cinemas.dart';
import '../pages/enter_memship_page.dart';

class NavbarMainShell extends StatefulWidget {
  const NavbarMainShell({super.key});

  @override
  State<NavbarMainShell> createState() => _NavbarMainShellState();
}

class _NavbarMainShellState extends State<NavbarMainShell>
    with TickerProviderStateMixin {
  // Navigation data
  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Trang chủ'),
    _NavItem(icon: Icons.movie_rounded, label: 'Phim'),
    _NavItem(icon: Icons.location_on_rounded, label: 'Rạp'),
    _NavItem(icon: Icons.campaign_rounded, label: 'Tin tức'),
    _NavItem(icon: Icons.confirmation_number_rounded, label: 'Ưu đãi'),
    _NavItem(icon: Icons.person_rounded, label: 'Tài khoản'),
  ];

  late final List<Widget> _pages;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pages = const [
      HomePage(),
      MoviesPage(),
      CinemasTab(),
      EnterMemshipPage(),
      ProductsPage(),
      AccountPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1014),
      body: IndexedStack(index: _currentPage, children: _pages),
      bottomNavigationBar: _ModernBottomNavBar(
        items: _navItems,
        currentIndex: _currentPage,
        onTap: (index) => setState(() => _currentPage = index),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}

class _ModernBottomNavBar extends StatefulWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ModernBottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<_ModernBottomNavBar> createState() => _ModernBottomNavBarState();
}

class _ModernBottomNavBarState extends State<_ModernBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(_ModernBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF15151E),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
          BoxShadow(
            color: const Color(0xFF8D4CE8).withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, -15),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / widget.items.length;

              return Stack(
                children: [
                  // Animated FAB Indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    left: itemWidth * widget.currentIndex +
                        (itemWidth - 60) / 2,
                    top: 0,
                    child: _AnimatedFab(
                      animation: _animationController,
                      item: widget.items[widget.currentIndex],
                    ),
                  ),

                  // Nav Items
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      widget.items.length,
                      (index) => _NavBarItem(
                        item: widget.items[index],
                        isActive: widget.currentIndex == index,
                        onTap: () => widget.onTap(index),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AnimatedFab extends StatelessWidget {
  final Animation<double> animation;
  final _NavItem item;

  const _AnimatedFab({
    required this.animation,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Bounce effect với overshoot
        final scale = Tween<double>(begin: 1.0, end: 1.3).evaluate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
          ),
        );

        final scaleBack = Tween<double>(begin: 1.3, end: 1.0).evaluate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
          ),
        );

        final currentScale = animation.value < 0.4 ? scale : scaleBack;

        // Rotation effect
        final rotation = Tween<double>(begin: 0.0, end: 0.1).evaluate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
          ),
        );

        final rotationBack = Tween<double>(begin: 0.1, end: 0.0).evaluate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
          ),
        );

        final currentRotation = animation.value < 0.5 ? rotation : rotationBack;

        return Transform.scale(
          scale: currentScale,
          child: Transform.rotate(
            angle: currentRotation,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8D4CE8),
                    Color(0xFFB565F5),
                    Color(0xFFD896FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8D4CE8).withOpacity(0.6),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: const Color(0xFFB565F5).withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 0,
                    offset: const Offset(0, 20),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  // Icon
                  Icon(
                    item.icon,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Icon - Chỉ hiển thị khi KHÔNG active (FAB sẽ hiển thị khi active)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: widget.isActive ? 0.0 : 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: widget.isActive ? 0 : 24,
                    child: Icon(
                      widget.item.icon,
                      size: 20,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),

                // Spacing khi active để FAB có chỗ
                SizedBox(height: widget.isActive ? 6 : 2),

                // Label - ẩn hoàn toàn khi active
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget.isActive
                      ? const SizedBox.shrink()
                      : AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                          child: Text(
                            widget.item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),

                // Spacer dưới label
                const SizedBox(height: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}






class _ModernSegmentButton extends StatelessWidget {
  const _ModernSegmentButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF8D4CE8), Color(0xFFB565F5)],
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF8D4CE8).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== LOADING & ERROR VIEWS =====

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF8D4CE8),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8D4CE8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Thử lại',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
