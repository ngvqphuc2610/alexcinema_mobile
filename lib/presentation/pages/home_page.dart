
import 'package:flutter/material.dart';

import '../../presentation/widgets/navbar_widget.dart';
import '../widgets/products/products_page.dart';
import 'account_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alex Cinema'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => _openPage(context, const AccountPage()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 8),
          Text(
            'Khám phá nhanh',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _FeatureCard(
            title: 'Phim & Lịch chiếu',
            description: 'Xem tin tức, ưu đãi và đặt vé phim nhanh chóng.',
            icon: Icons.movie_creation_outlined,
            color: Colors.deepPurple,
            onTap: () => _openPage(context, const NavbarMainShell()),
          ),
          _FeatureCard(
            title: 'Combo & Sản phẩm',
            description: 'Chọn combo bắp nước, snack và đồ uống yêu thích.',
            icon: Icons.fastfood_outlined,
            color: Colors.orange.shade700,
            onTap: () => _openPage(context, const ProductsPage()),
          ),
          _FeatureCard(
            title: 'Tài khoản của tôi',
            description: 'Đăng nhập, quản lý thông tin và cài đặt bảo mật.',
            icon: Icons.person_outline,
            color: Colors.teal,
            onTap: () => _openPage(context, const AccountPage()),
          ),
        ],
      ),
    );
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
