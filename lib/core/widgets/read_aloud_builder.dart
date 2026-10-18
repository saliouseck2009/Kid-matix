import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/widgets/read_aloud_action.dart';

/// Draws a widget around the reading of a text; the action is `null`
/// while no voice can read it.
typedef ReadAloudBuilder = Widget Function(
  BuildContext context,
  ReadAloudAction? action,
);
