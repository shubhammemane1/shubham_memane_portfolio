// lib/core/state/mouse_notifier.dart
import 'package:flutter/widgets.dart';

/// Normalized mouse position relative to viewport center.
/// dx and dy are in range -1.0 to 1.0.
typedef MouseNotifier = ValueNotifier<Offset>;
