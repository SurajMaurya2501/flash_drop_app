import 'package:flash_drop_app/features/flash_drop/presentation/blocs/flash_drop_bloc/flash_drop_bloc.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/blocs/flash_drop_bloc/flash_drop_state.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/widgets/error_widget.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/widgets/loading_widget.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/widgets/main_view.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:flutter_bloc/flutter_bloc.dart';

class FlashDropMainScreen extends StatelessWidget {
  const FlashDropMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xFF0A0D12),
              Color(0xFF111A26),
              Color(0xFF090C12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<FlashDropBloc, FlashDropState>(
            builder: (context, state) {
              if (state.status == FlashDropStatus.loading) {
                return LoadingWidget();
              } else if (state.errorMessage != null) {
                return ErrorWidget(errorMessage: "Something went wrong");
              }

              final activeQuote = state.flashDropEntity;
              final fallbackPrice = (state.historyData ?? []).isNotEmpty
                  ? state.historyData?.last.price
                  : 0.0;
              final currentPrice = activeQuote?.currentPrice ?? fallbackPrice;
              final previousPrice = (state.liveSeries).length > 1
                  ? (state.liveSeries)[(state.liveSeries).length - 2].price
                  : fallbackPrice;

              return MainView(
                currentPrice: currentPrice,
                previousPrice: previousPrice,
                activeQuote: activeQuote,
                state: state,
              );
            },
          ),
        ),
      ),
    );
  }
}
