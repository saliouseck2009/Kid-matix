import 'package:kid_matix/features/speech/data/datasources/offline_voice.dart';

/// Chooses the voice that reads each language of the app.
///
/// Only a voice installed on the phone that needs no network counts, so a
/// reading never sends the text of a question anywhere. The engine of the
/// phone is not left to choose: it may prefer a voice that works online.
abstract final class OfflineVoices {
  /// Locales tried, in this order, for each language of the app. A voice
  /// of another locale of the same language comes after them.
  static const Map<String, List<String>> locales = <String, List<String>>{
    'fr': <String>['fr-FR', 'fr-CA', 'fr-BE', 'fr-CH'],
    'en': <String>['en-US', 'en-GB', 'en-AU', 'en-IN'],
    'es': <String>['es-ES', 'es-US', 'es-MX'],
  };

  // The better the quality, the earlier the voice, among the same locale.
  static const List<String> _qualities = <String>[
    'very high',
    'high',
    'normal',
    'low',
    'very low',
  ];

  // Feature the engine sets on a voice whose data is not downloaded.
  static const String _notInstalled = 'notInstalled';

  /// The best installed voice without a network among [voices] (the list
  /// `getVoices` of the Android plugin returns) for [languageCode], or
  /// `null` when there is none.
  static OfflineVoice? pick({
    required Object? voices,
    required String languageCode,
  }) {
    final List<Map<Object?, Object?>> usable = <Map<Object?, Object?>>[
      if (voices is List<Object?>)
        for (final Object? voice in voices)
          if (voice is Map<Object?, Object?> && _isOffline(voice)) voice,
    ];
    final List<String> wanted = locales[languageCode] ?? const <String>[];
    for (final String locale in wanted) {
      final OfflineVoice? voice = _best(usable, (String found) {
        return _normalize(found) == locale;
      });
      if (voice != null) return voice;
    }
    return _best(usable, (String found) {
      return _normalize(found).startsWith('$languageCode-');
    });
  }

  static OfflineVoice? _best(
    List<Map<Object?, Object?>> voices,
    bool Function(String locale) matches,
  ) {
    final List<Map<Object?, Object?>> found = <Map<Object?, Object?>>[
      for (final Map<Object?, Object?> voice in voices)
        if (matches('${voice['locale']}')) voice,
    ]..sort(_byQuality);
    if (found.isEmpty) return null;
    return OfflineVoice(
      locale: _normalize('${found.first['locale']}'),
      name: '${found.first['name']}',
    );
  }

  static bool _isOffline(Map<Object?, Object?> voice) {
    if (voice['name'] == null || voice['locale'] == null) return false;
    final bool needsNetwork = '${voice['network_required']}' != '0';
    final bool isMissing = '${voice['features']}'
        .split('\t')
        .contains(_notInstalled);
    return !needsNetwork && !isMissing;
  }

  static int _byQuality(Map<Object?, Object?> a, Map<Object?, Object?> b) {
    return _rank(a).compareTo(_rank(b));
  }

  static int _rank(Map<Object?, Object?> voice) {
    final int index = _qualities.indexOf('${voice['quality']}');
    return index < 0 ? _qualities.length : index;
  }

  // `fr_FR` and `fr-FR` name the same locale.
  static String _normalize(String locale) => locale.replaceAll('_', '-');
}
