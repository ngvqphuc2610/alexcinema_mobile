import 'package:flutter/material.dart';

enum SeatType { single, doubleSeat }

class TicketTypeOption {
  TicketTypeOption({
    required this.name,
    required this.price,
    this.description,
    this.quantity = 0,
    this.seatType = SeatType.single,
  });

  final String name;
  final double price;
  final String? description;
  int quantity;
  final SeatType seatType;
}

class TicketTypeSelector extends StatefulWidget {
  const TicketTypeSelector({
    super.key,
    required this.options,
    required this.onChanged,
  });

  final List<TicketTypeOption> options;
  final ValueChanged<List<TicketTypeOption>> onChanged;

  @override
  State<TicketTypeSelector> createState() => _TicketTypeSelectorState();
}

class _TicketTypeSelectorState extends State<TicketTypeSelector> {
  late List<TicketTypeOption> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.options.map((e) => TicketTypeOption(
          name: e.name,
          price: e.price,
          description: e.description,
          quantity: e.quantity,
          seatType: e.seatType,
        )).toList();
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      final updated = _items[index].quantity + delta;
      _items[index].quantity = updated < 0 ? 0 : updated;
    });
    widget.onChanged(_items);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _items.asMap().entries.map((entry) {
        final idx = entry.key;
        final option = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.deepPurple.shade200, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(option.price),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (option.description != null && option.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          option.description!,
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  _CircleButton(
                    icon: Icons.remove,
                    onPressed: option.quantity == 0
                        ? null
                        : () => _updateQuantity(idx, -1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${option.quantity}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  _CircleButton(
                    icon: Icons.add,
                    onPressed: () => _updateQuantity(idx, 1),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatCurrency(double price) {
    final formatted = price.toStringAsFixed(0);
    return '$formatted đ';
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepPurple),
          color: onPressed == null ? Colors.grey.shade200 : Colors.white,
        ),
        child: Icon(
          icon,
          size: 18,
          color: onPressed == null ? Colors.grey : Colors.deepPurple,
        ),
      ),
    );
  }
}
