class FlashDropEntity {
  const FlashDropEntity({
    required this.currentPrice,
    required this.remainingInventory,
    required this.tickEpochMs,
  });

  final double currentPrice;
  final int remainingInventory;
  final int tickEpochMs;

  FlashDropEntity toEntity() {
    return FlashDropEntity(
      currentPrice: currentPrice,
      remainingInventory: remainingInventory,
      tickEpochMs: tickEpochMs,
    );
  }
}
