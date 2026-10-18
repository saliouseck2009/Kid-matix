import 'package:flutter/widgets.dart';

/// What the player can do about the reading of a text: whether the voice
/// is reading it now, and the action that starts or stops the reading.
typedef ReadAloudAction = ({bool isSpeaking, VoidCallback toggle});
