import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../data/models/entity/movie_entity.dart';
import 'card_movies_comingsoon.dart';

class ComingSoonMoviesGrid extends StatefulWidget {
  const ComingSoonMoviesGrid({
    super.key,
    required this.movies,
    this.isLoading = false,
    this.onSeeAll,
    this.onMovieTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.title = 'PHIM SAP CHIEU',
    this.useCarousel = true,
  });

  final List<MovieEntity> movies;
  final bool isLoading;
  final VoidCallback? onSeeAll;
  final ValueChanged<MovieEntity>? onMovieTap;
  final EdgeInsetsGeometry padding;
  final String title;
  final bool useCarousel;

  @override
  State<ComingSoonMoviesGrid> createState() => _ComingSoonMoviesGridState();
}

class _ComingSoonMoviesGridState extends State<ComingSoonMoviesGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Padding(
        padding: widget.padding,
        child: const _LoadingList(),
      );
    }

    if (widget.movies.isEmpty) {
      return Padding(
        padding: widget.padding,
        child: _EmptyView(
          message: 'Chua co phim sap chieu.',
        ),
      );
    }

    return Padding(
      padding: widget.padding,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            widget.useCarousel ? _buildCarouselView() : _buildListView(),
            if (widget.useCarousel) ...[
              const SizedBox(height: 12),
              _buildPageIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
                color: const Color(0xFF8D4CE8).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.upcoming_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        if (widget.onSeeAll != null)
          TextButton(
            onPressed: widget.onSeeAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Xem tat ca',
                  style: TextStyle(
                    color: Color(0xFF8D4CE8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Color(0xFF8D4CE8),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCarouselView() {
    return CarouselSlider.builder(
      carouselController: _carouselController,
      itemCount: widget.movies.length,
      options: CarouselOptions(
        height: 320,
        viewportFraction: 0.42,
        enlargeCenterPage: false,
        enableInfiniteScroll: widget.movies.length > 1,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 700),
        autoPlayCurve: Curves.easeInOut,
        scrollDirection: Axis.horizontal,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      itemBuilder: (context, index, realIndex) {
        final movie = widget.movies[index];
        final isActive = index == _currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Transform.scale(
            scale: isActive ? 1.0 : 0.9,
            child: Opacity(
              opacity: isActive ? 1.0 : 0.7,
              child: ComingSoonMovieCard(
                movie: movie,
                onTap: () => widget.onMovieTap?.call(movie),
                onNotifyPressed: () => widget.onMovieTap?.call(movie),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView() {
    return SizedBox(
      height: 340,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        physics: const BouncingScrollPhysics(),
        itemCount: widget.movies.length,
        itemBuilder: (context, index) {
          return _buildAnimatedMovieCard(index);
        },
      ),
    );
  }

  Widget _buildAnimatedMovieCard(int index) {
    final movie = widget.movies[index];
    final delay = index * 50;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: ComingSoonMovieCard(
        movie: movie,
        onTap: () => widget.onMovieTap?.call(movie),
        onNotifyPressed: () => widget.onMovieTap?.call(movie),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Center(
      child: AnimatedSmoothIndicator(
        activeIndex: _currentIndex,
        count: widget.movies.length,
        effect: ExpandingDotsEffect(
          dotHeight: 8,
          dotWidth: 8,
          spacing: 6,
          activeDotColor: const Color(0xFF8D4CE8),
          dotColor: Colors.white.withOpacity(0.3),
          expansionFactor: 3,
        ),
        onDotClicked: (index) {
          _carouselController.animateToPage(index);
        },
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.white.withOpacity(0.35),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.white.withOpacity(0.08);

    return SizedBox(
      height: 340,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (_, __) => Container(
          width: 150,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: 4,
      ),
    );
  }
}
