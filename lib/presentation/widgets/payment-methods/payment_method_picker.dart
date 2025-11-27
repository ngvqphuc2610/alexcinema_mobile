import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../data/models/entity/payment_method_entity.dart';
import '../../bloc/common/bloc_status.dart';
import '../../bloc/payment_method/payment_method_cubit.dart';
import '../../bloc/payment_method/payment_method_state.dart';

class PaymentMethodPicker extends StatelessWidget {
  const PaymentMethodPicker({
    super.key,
    required this.onSelected,
    this.selectedCode,
    this.includeInactive = false,
    this.title,
  });

  final String? selectedCode;
  final bool includeInactive;
  final String? title;
  final ValueChanged<PaymentMethodEntity> onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<PaymentMethodCubit>()..fetch(includeInactive: includeInactive),
      child: BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
        builder: (context, state) {
          if (state.status.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status.isFailure) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                _ErrorState(
                  message: state.errorMessage ?? 'Không tải được phương thức thanh toán.',
                  onRetry: () => context.read<PaymentMethodCubit>().fetch(
                        includeInactive: includeInactive,
                      ),
                ),
              ],
            );
          }

          final items = state.items;
          if (items.isEmpty) {
            return Text(
              'Chưa có phương thức thanh toán khả dụng.',
              style: Theme.of(context).textTheme.bodyMedium,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    title!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ...items.map(
                (method) => _PaymentMethodTile(
                  method: method,
                  selected: method.code == selectedCode,
                  groupValue: selectedCode,
                  onTap: () => onSelected(method),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    required this.onTap,
    required this.selected,
    required this.groupValue,
  });

  final PaymentMethodEntity method;
  final VoidCallback onTap;
  final bool selected;
  final String? groupValue;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? Theme.of(context).colorScheme.primary : Colors.black12,
          width: selected ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              _PaymentIcon(url: method.iconUrl, code: method.code),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (method.description != null && method.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          method.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                      ),
                  ],
                ),
              ),
              Radio<String>(
                value: method.code,
                groupValue: groupValue,
                onChanged: (_) => onTap(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentIcon extends StatelessWidget {
  const _PaymentIcon({this.url, required this.code});

  final String? url;
  final String code;

  @override
  Widget build(BuildContext context) {
    final placeholder = CircleAvatar(
      backgroundColor: Colors.grey.shade200,
      child: Text(
        _shortCode(code),
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );

    if (url == null || url!.isEmpty) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        },
      ),
    );
  }
}

String _shortCode(String code) {
  if (code.isEmpty) return '?';
  final upper = code.toUpperCase();
  final length = min(upper.length, 2);
  return upper.substring(0, length);
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Thử lại'),
        ),
      ],
    );
  }
}
