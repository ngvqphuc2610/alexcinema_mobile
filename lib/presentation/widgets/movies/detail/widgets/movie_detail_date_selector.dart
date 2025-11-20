import 'package:flutter/material.dart';

import 'movie_empty_message.dart';

class MovieDetailDateSelector extends StatelessWidget {
  const MovieDetailDateSelector({
    super.key,
    required this.isLoading,
    required this.dates,
    required this.selectedDate,
    required this.dateLabelBuilder,
    required this.onDateSelected,
  });

  final bool isLoading;
  final List<DateTime> dates;
  final DateTime? selectedDate;
  final String Function(DateTime) dateLabelBuilder;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chon ngay chieu',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const _DateSkeletonRow()
        else if (dates.isEmpty)
          const MovieEmptyMessage(
            message: 'Chua co lich chieu cho phim nay',
            icon: Icons.local_activity_outlined,
          )
        else
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final date = dates[index];
                final isSelected = selectedDate != null &&
                    _isSameDate(date, selectedDate!);
                return _DateOption(
                  label: dateLabelBuilder(date),
                  dateText: _dateText(date),
                  isSelected: isSelected,
                  onTap: () => onDateSelected(date),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: dates.length,
            ),
          ),
      ],
    );
  }

  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dateText(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }
}

class _DateOption extends StatelessWidget {
  const _DateOption({
    required this.label,
    required this.dateText,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String dateText;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedColor = Colors.amber.shade400;
    final inactiveColor = Colors.deepPurple.shade700;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : inactiveColor,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black87 : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              dateText,
              style: TextStyle(
                color: isSelected ? Colors.black87 : Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSkeletonRow extends StatelessWidget {
  const _DateSkeletonRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, __) => Container(
          width: 78,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: 4,
      ),
    );
  }
}
