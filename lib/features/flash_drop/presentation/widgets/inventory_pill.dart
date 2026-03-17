import 'package:flutter/material.dart';

class InventoryPill extends StatelessWidget {
  const InventoryPill({super.key, required this.inventory});

  final int inventory;

  @override
  Widget build(BuildContext context) {
    final depleted = inventory <= 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: depleted ? const Color(0x33C14E4E) : const Color(0x2231D09B),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: depleted ? const Color(0x66EC7D7D) : const Color(0x6687F1CF),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            depleted ? 'SOLD OUT' : '$inventory LEFT',
            key: ValueKey<String>('inventory-$inventory'),
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: depleted
                  ? const Color(0xFFFFACAC)
                  : const Color(0xFF9BF5D8),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
