import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class NoFabNavBarExample extends StatefulWidget {
  const NoFabNavBarExample({super.key});

  @override
  State<NoFabNavBarExample> createState() => _NoFabNavBarExampleState();
}

class _NoFabNavBarExampleState extends State<NoFabNavBarExample> {
  int _index = 0;

  final List<IconData> icons = [
    Icons.home_outlined,
    Icons.movie_outlined,
    Icons.photo_library_outlined,
    Icons.person_outline,
  ];

  final List<Widget> pages = [
    Center(child: Text("Trang chủ")),
    Center(child: Text("Phim")),
    Center(child: Text("Bộ sưu tập")),
    Center(child: Text("Tài khoản")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: icons,
        activeIndex: _index,
        onTap: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        activeColor: Colors.deepPurple,
        inactiveColor: Colors.grey,
        gapLocation: GapLocation.none, // 💥 Không có khe hở (tức là không cần FAB)
        notchSmoothness: NotchSmoothness.softEdge,
      ),
    );
  }
}
