import 'package:track_your_stop/routing/router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:track_your_stop/utils/logger.dart';
import 'package:track_your_stop/shared/provider/app_bar_selection_provider.dart';

class BottomAppNavigationBar extends ConsumerWidget {
  BottomAppNavigationBar({
    Key? key,
  }) : super(key: key);

  final logger = getLogger("BottomAppBar");

  final pageMap = {
    0: const DepartureRoute(),
    1: const NewsRoute(),
    2: const SettingsRoute()
  };

  void _onIndexChange(BuildContext context, WidgetRef ref, int currentIndex,
      int selectedIndex) {
    if (currentIndex != selectedIndex) {
      ref.read(appBarSelectionProvider.notifier).state = selectedIndex;
      final router = AutoRouter.of(context);
      router.push(pageMap[selectedIndex] ?? const DepartureRoute());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(appBarSelectionProvider);
    logger.d("Current Index: $currentIndex");
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.train),
          label: AppLocalizations.of(context)!.bottomBarDepartures,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.newspaper),
          label: AppLocalizations.of(context)!.bottomBarNews,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: AppLocalizations.of(context)!.bottomBarSettings,
        ),
      ],
      currentIndex: currentIndex,
      onTap: (selectedIndex) =>
          _onIndexChange(context, ref, currentIndex, selectedIndex),
    );
  }
}
