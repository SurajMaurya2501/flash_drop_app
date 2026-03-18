import 'package:equatable/equatable.dart';
import 'package:flash_drop_app/features/flash_drop/domain/entities/flash_drop_entity.dart';
import 'package:flash_drop_app/features/flash_drop/domain/entities/historical_bid_point.dart';

enum FlashDropStatus { initial, loading, success, error }

enum PurchaseLifecycleStatus { idle, verifying, success }

class FlashDropState extends Equatable {
  final FlashDropEntity? flashDropEntity;
  final List<HistoricalBidPoint>? historyData;
  final List<HistoricalBidPoint> liveSeries;
  final String? errorMessage;
  final FlashDropStatus? status;
  final PurchaseLifecycleStatus purchaseStatus;

  const FlashDropState({
    required this.liveSeries,
    required this.flashDropEntity,
    required this.historyData,
    this.errorMessage,
    required this.status,
    required this.purchaseStatus,
  });

  factory FlashDropState.initial() {
    return const FlashDropState(
      purchaseStatus: PurchaseLifecycleStatus.idle,
      liveSeries: [],
      flashDropEntity: null,
      historyData: null,
      errorMessage: null,
      status: FlashDropStatus.initial,
    );
  }

  bool get canSecureItem {
    final quote = flashDropEntity;
    return quote != null &&
        quote.remainingInventory > 0 &&
        purchaseStatus == PurchaseLifecycleStatus.idle;
  }

  FlashDropState copyWith({
    FlashDropEntity? flashDropEntity,
    List<HistoricalBidPoint>? history,
    List<HistoricalBidPoint>? liveData,
    PurchaseLifecycleStatus? purchaseStatus,
    bool clearError = false,
    String? errorMessage,
    FlashDropStatus? status,
    bool clearStatus = false,
  }) {
    return FlashDropState(
      purchaseStatus: purchaseStatus ?? this.purchaseStatus,
      liveSeries: liveData ?? liveSeries,
      historyData: history ?? historyData,
      status: clearStatus ? null : status ?? this.status,
      flashDropEntity: flashDropEntity ?? this.flashDropEntity,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    flashDropEntity,
    historyData,
    errorMessage,
    status,
  ];
}
