import 'package:flash_drop_app/features/flash_drop/data/repositories/flash_drop_repository.dart';
import 'package:flash_drop_app/features/flash_drop/domain/entities/flash_drop_entity.dart';
import 'package:flash_drop_app/features/flash_drop/domain/entities/historical_bid_point.dart';

class FlashDropUsecases {
  final _flashRepository = FlashDropRepository();

  Future<List<HistoricalBidPoint>> getFlashDropHistoricalData() {
    return _flashRepository.getHistoricalData();
  }

  Stream<FlashDropEntity> getFlashDropStreamData() {
    return _flashRepository.streamLiveFlashDropData();
  }
}
