import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'card_movies_nowshow.dart';

class NowShowingMovie {
  final int id;
  final String title;
  final String posterUrl;
  final String genre;
  final String format; // 2D / 3D
  final String ageRestriction; // P / C13 / C16 / C18
  final double? rating; // Optional: điểm đánh giá (VD: 8.5)
  final String? duration; // Optional: thời lượng phim (VD: "2h 30m")

  NowShowingMovie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.genre,
    required this.format,
    required this.ageRestriction,
    this.rating,
    this.duration,
  });
}

class NowShowingMoviesGrid extends StatefulWidget {
  final List<NowShowingMovie> movies;
  final void Function(NowShowingMovie movie)? onBookMovie;
  final void Function(NowShowingMovie movie)? onMovieTap;
  final String? sectionTitle;
  final bool showViewAllButton;
  final VoidCallback? onViewAllPressed;
  final bool useCarousel; // Toggle giữa Carousel và ListView

  const NowShowingMoviesGrid({
    super.key,
    required this.movies,
    this.onBookMovie,
    this.onMovieTap,
    this.sectionTitle = 'PHIM ĐANG CHIẾU',
    this.showViewAllButton = false,
    this.onViewAllPressed,
    this.useCarousel = true, // Mặc định dùng Carousel
  });

  @override
  State<NowShowingMoviesGrid> createState() => _NowShowingMoviesGridState();
}

class _NowShowingMoviesGridState extends State<NowShowingMoviesGrid>
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
    if (widget.movies.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: 16),
          widget.useCarousel ? _buildCarouselView() : _buildListView(),
          if (widget.useCarousel) ...[
            const SizedBox(height: 16),
            _buildPageIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Icon với gradient
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
              Icons.movie_filter_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sectionTitle ?? 'PHIM ĐANG CHIẾU',
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

          // View All Button (optional)
          if (widget.showViewAllButton)
            TextButton(
              onPressed: widget.onViewAllPressed,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Xem tất cả',
                    style: TextStyle(
                      color: const Color(0xFF8D4CE8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Color(0xFF8D4CE8),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // CAROUSEL VIEW - Sử dụng carousel_slider
  Widget _buildCarouselView() {
    return CarouselSlider.builder(
      carouselController: _carouselController,
      itemCount: widget.movies.length,
      options: CarouselOptions(
        height: 430,
        viewportFraction: 0.62,
        enlargeCenterPage: true,
        enlargeFactor: 0.12,
        enableInfiniteScroll: widget.movies.length > 1,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 700),
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
              child: NowShowingMovieCard(
                title: movie.title,
                posterUrl: movie.posterUrl,
                genre: movie.genre,
                format: movie.format,
                ageRestriction: movie.ageRestriction,
                rating: movie.rating,
                duration: movie.duration,
                onBookPressed: () => widget.onBookMovie?.call(movie),
                onTap: () => widget.onMovieTap?.call(movie),
              ),
            ),
          ),
        );
      },
    );
  }

  // LIST VIEW - Scroll ngang truyền thống
  Widget _buildListView() {
    return SizedBox(
      height: 430,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
    
    // Staggered animation cho mỗi card
    final delay = index * 50; // 50ms delay cho mỗi card
    
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
      child: SizedBox(
        width: 220,
        child: NowShowingMovieCard(
          title: movie.title,
          posterUrl: movie.posterUrl,
          genre: movie.genre,
          format: movie.format,
          ageRestriction: movie.ageRestriction,
          rating: movie.rating,
          duration: movie.duration,
          onBookPressed: () => widget.onBookMovie?.call(movie),
          onTap: () => widget.onMovieTap?.call(movie),
        ),
      ),
    );
  }

  // PAGE INDICATOR - Sử dụng smooth_page_indicator
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.movie_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Chưa có phim đang chiếu',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng quay lại sau',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
