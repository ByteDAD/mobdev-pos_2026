import 'package:flutter/widgets.dart';

import 'pos_store.dart';

class PosScope extends InheritedNotifier<PosStore> {
  const PosScope({
    super.key,
    required PosStore store,
    required Widget child,
  }) : super(notifier: store, child: child);

  static PosStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PosScope>(); // state access
    assert(scope != null, 'PosScope not found in widget tree');
    return scope!.notifier!;
  }
}
