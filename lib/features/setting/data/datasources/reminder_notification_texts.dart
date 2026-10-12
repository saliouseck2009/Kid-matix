import 'package:meta/meta.dart';

/// The words of the reminder notification, resolved from the app's
/// localizations at the composition root.
@immutable
final class ReminderNotificationTexts {
  /// Creates the texts.
  const ReminderNotificationTexts({
    required this.title,
    required this.body,
    required this.channelName,
    required this.channelDescription,
  });

  /// Title of the notification.
  final String title;

  /// Message of the notification.
  final String body;

  /// Name of the Android channel, shown in the phone's settings.
  final String channelName;

  /// Description of the Android channel, shown in the phone's settings.
  final String channelDescription;
}
