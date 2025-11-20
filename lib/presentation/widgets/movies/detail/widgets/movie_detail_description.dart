import 'package:flutter/material.dart';

class MovieDetailDescription extends StatefulWidget {
  const MovieDetailDescription({
    super.key,
    required this.description,
  });

  final String? description;

  @override
  State<MovieDetailDescription> createState() => _MovieDetailDescriptionState();
}

class _MovieDetailDescriptionState extends State<MovieDetailDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedDescription =
        (widget.description == null || widget.description!.trim().isEmpty)
            ? 'Dang cap nhat...'
            : widget.description!.trim();
    final canExpand = resolvedDescription.length > 150;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mo ta phim',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: Text(
            resolvedDescription,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            maxLines: _isExpanded ? null : 3,
            overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
        if (canExpand)
          TextButton(
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
            child: Text(_isExpanded ? 'Thu gon' : 'Xem them'),
          ),
      ],
    );
  }
}
