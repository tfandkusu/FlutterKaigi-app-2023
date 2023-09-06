import 'package:conference_2023/l10n/localization.dart';
import 'package:conference_2023/ui/screen/root_drawer.dart';
import 'package:conference_2023/ui/screen/root_navigation_bar.dart';
import 'package:conference_2023/ui/screen/root_navigation_rail.dart';
import 'package:conference_2023/ui/screen/root_tab.dart';
import 'package:conference_2023/util/extension/build_context_ext.dart';
import 'package:conference_2023/util/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ここが最も親の画面
class RootScreen extends ConsumerWidget {
  const RootScreen({
    super.key,
    required this.navigator,
  });

  /// コンテンツ本体
  final Widget navigator;

  /// 現在の選択タブを取得
  RootTab _getCurrentTab(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return RootTab.values.reversed.firstWhere(
      (element) => location.startsWith(element.path),
      orElse: () => RootTab.home,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = ref.watch(localizationProvider);

    // 画面サイズは3種類ある (compact, medium, expanded)
    final screenSize = context.screenSize;
    final currentTab = _getCurrentTab(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTab.title(localization)),
      ),
      drawer: switch (screenSize) {
        ScreenSize.compact => RootDrawer(
            currentTab: currentTab,
          ),
        _ => null,
      },
      body: switch (screenSize) {
        ScreenSize.compact => navigator,
        ScreenSize.medium => Row(
            children: [
              LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: RootNavigationRail(
                        currentTab: currentTab,
                        extended: false,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: navigator,
              ),
            ],
          ),

        /// TODO: wait for [https://github.com/flutter/flutter/issues/123113]
        ScreenSize.expanded => Row(
            children: [
              LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: RootNavigationRail(
                        currentTab: currentTab,
                        extended: true,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: navigator,
              ),
            ],
          ),
      },
      bottomNavigationBar: switch (screenSize) {
        ScreenSize.compact => RootNavigationBar(
            currentTab: currentTab,
          ),
        _ => null,
      },
    );
  }
}
