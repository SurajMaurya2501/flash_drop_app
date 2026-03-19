import 'package:flash_drop_app/features/flash_drop/domain/entities/flash_drop_entity.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/blocs/flash_drop_bloc/flash_drop_bloc.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/blocs/flash_drop_bloc/flash_drop_event.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/blocs/flash_drop_bloc/flash_drop_state.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/widgets/hold_to_secure_button.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/widgets/inventory_pill.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/widgets/luxury_live_chart.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/widgets/luxury_price_ticker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainView extends StatelessWidget {
  const MainView({
    super.key,
    required this.currentPrice,
    required this.previousPrice,
    required this.activeQuote,
    required this.state,
  });

  final double? currentPrice;
  final double? previousPrice;
  final FlashDropEntity? activeQuote;
  final FlashDropState state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed(<Widget>[
              Text(
                'Prime Drop',
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Flash allotment closes when inventory reaches zero.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(color: const Color(0xFFC2CBD9)),
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  RepaintBoundary(
                    child: LuxuryPriceTicker(
                      price: currentPrice ?? 0.0,
                      previousPrice: previousPrice,
                    ),
                  ),
                  const Spacer(),
                  InventoryPill(
                    inventory: activeQuote?.remainingInventory ?? 0,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 300,
                child: LuxuryLiveChart(
                  historicalSeries: state.historyData ?? [],
                  liveSeries: state.liveSeries,
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'Limited release note',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: const Color(0xFFE2BF86),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Each secure action reserves one serialized piece while our inventory verifier confirms your slot in real time.',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  height: 1.45,
                  color: const Color(0xFFC4CDDD),
                ),
              ),
              const SizedBox(height: 28),
              HoldToSecureButton(
                purchaseStatus: state.purchaseStatus,
                enabled: state.canSecureItem,
                onHoldCompleted: () {
                  context.read<FlashDropBloc>().add(LuxuryPurchaseRequested());
                },
              ),
              const SizedBox(height: 18),
            ]),
          ),
        ),
      ],
    );
  }
}
