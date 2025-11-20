import 'package:flutter/material.dart';

import 'card_news.dart';

class NewsGrid extends StatelessWidget {
  const NewsGrid({
    super.key,
    required this.items,
    required this.emptyMessage,
  });

  final List<NewsCardData> items;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_rounded,
                  size: 56,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) => NewsCard(data: items[index]),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount: items.length,
    );
  }
}
