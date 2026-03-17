import 'package:equatable/equatable.dart';
import 'package:flash_drop_app/features/flash_drop/domain/entities/flash_drop_entity.dart';
import 'package:flash_drop_app/features/flash_drop/domain/entities/historical_bid_point.dart';

enum FlashDropStatus { initial, loading, success, error }

class FlashDropState extends Equatable {
  final FlashDropEntity? flashDropEntity;
  final List<HistoricalBidPoint>? historyData;
  final List<HistoricalBidPoint> liveSeries;
  final String? errorMessage;
  final FlashDropStatus? status;

  const FlashDropState({
    required this.liveSeries,
    required this.flashDropEntity,
    required this.historyData,
    this.errorMessage,
    required this.status,
  });

  factory FlashDropState.initial() {
    return const FlashDropState(
      liveSeries: [],
      flashDropEntity: null,
      historyData: null,
      errorMessage: null,
      status: FlashDropStatus.initial,
    );
  }

  FlashDropState copyWith({
    FlashDropEntity? flashDropEntity,
    List<HistoricalBidPoint>? history,
    List<HistoricalBidPoint>? liveData,

    bool clearError = false,
    String? errorMessage,
    FlashDropStatus? status,
    bool clearStatus = false,
  }) {
    return FlashDropState(
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
