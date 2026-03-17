import 'package:flash_drop_app/features/flash_drop/domain/entities/flash_drop_entity.dart';

sealed class FlashDropEvent {}

class FetchHistoryData extends FlashDropEvent {}

class FetchLiveData extends FlashDropEvent {
  final FlashDropEntity flashDropEntity;

  FetchLiveData({required this.flashDropEntity});
}
