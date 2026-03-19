import 'package:flutter/material.dart';

class LuxuryPriceTicker extends StatelessWidget {
  const LuxuryPriceTicker({
    required this.price,
    required this.previousPrice,
    super.key,
  });

  final double price;
  final double? previousPrice;

  @override
  Widget build(BuildContext context) {
    final trendUp = previousPrice == null ? true : price >= previousPrice!;
    final trendColor = trendUp
        ? const Color(0xFF5AF2B8)
        : const Color(0xFFFF7A7A);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: previousPrice ?? price, end: price),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, animatedPrice, _) {
        return Text(
          '\$${animatedPrice.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
            color: trendColor,
            fontWeight: FontWeight.w700,
          ),
        );
      },
    );
  }
}
