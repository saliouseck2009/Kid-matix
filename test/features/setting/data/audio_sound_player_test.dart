import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/game_feedback.dart';
import 'package:kid_matix/features/setting/data/datasources/audio_sound_player.dart';

const MethodChannel _playerChannel = MethodChannel('xyz.luan/audioplayers');
const MethodChannel _globalChannel = MethodChannel(
  'xyz.luan/audioplayers.global',
);
const EventChannel _globalEvents = EventChannel(
  'xyz.luan/audioplayers.global/events',
);

/// [AudioCache] that never touches the file system and records the sounds
/// asked for.
final class _RecordingAudioCache extends AudioCache {
  final List<String> loadedPaths = <String>[];

  @override
  Future<String> loadPath(String fileName) async {
    loadedPaths.add(fileName);
    return '/cache/$fileName';
  }
}

/// Fake audioplayers plugin: records the calls of the players, reports
/// every source as prepared and can make `stop` fail.
final class _FakeAudioPlugin {
  _FakeAudioPlugin(this._messenger);

  final TestDefaultBinaryMessenger _messenger;
  final List<MethodCall> calls = <MethodCall>[];
  final Map<String, MockStreamHandlerEventSink> _sinks =
      <String, MockStreamHandlerEventSink>{};
  bool failsOnStop = false;

  List<String> methodsCalled() {
    return <String>[for (final MethodCall call in calls) call.method];
  }

  void install() {
    _messenger.setMockMethodCallHandler(_globalChannel, (_) async => null);
    _messenger.setMockStreamHandler(
      _globalEvents,
      MockStreamHandler.inline(onListen: (_, _) {}),
    );
    _messenger.setMockMethodCallHandler(_playerChannel, _handle);
  }

  void uninstall() {
    _messenger.setMockMethodCallHandler(_globalChannel, null);
    _messenger.setMockStreamHandler(_globalEvents, null);
    _messenger.setMockMethodCallHandler(_playerChannel, null);
  }

  Future<Object?> _handle(MethodCall call) async {
    calls.add(call);
    final String playerId =
        (call.arguments as Map<Object?, Object?>)['playerId']! as String;
    switch (call.method) {
      case 'create':
        _messenger.setMockStreamHandler(
          EventChannel('xyz.luan/audioplayers/events/$playerId'),
          MockStreamHandler.inline(
            onListen: (_, MockStreamHandlerEventSink events) {
              _sinks[playerId] = events;
            },
          ),
        );
      case 'setSourceUrl':
        _sinks[playerId]?.success(<String, Object>{
          'event': 'audio.onPrepared',
          'value': true,
        });
      case 'stop' when failsOnStop:
        throw PlatformException(code: 'stop', message: 'no audio output');
    }
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAudioPlugin plugin;
  late _RecordingAudioCache cache;
  late AudioCache previousCache;

  setUp(() {
    plugin = _FakeAudioPlugin(
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger,
    )..install();
    previousCache = AudioCache.instance;
    cache = _RecordingAudioCache();
    AudioCache.instance = cache;
  });

  tearDown(() {
    plugin.uninstall();
    AudioCache.instance = previousCache;
  });

  test('plays the bundled sound of each moment of the game', () async {
    // Arrange
    final AudioSoundPlayer player = AudioSoundPlayer();
    const List<String> expectedPaths = <String>[
      'sounds/right.wav',
      'sounds/wrong.wav',
      'sounds/celebration.wav',
    ];
    // Act
    for (final GameFeedback inputFeedback in GameFeedback.values) {
      await player.play(inputFeedback);
    }
    // Assert
    expect(cache.loadedPaths, expectedPaths);
    expect(
      plugin.methodsCalled().where((String method) => method == 'resume'),
      hasLength(3),
    );
  });

  test('keeps one low-latency player per sound', () async {
    // Arrange
    final AudioSoundPlayer player = AudioSoundPlayer();
    // Act
    await player.play(GameFeedback.rightAnswer);
    await player.play(GameFeedback.rightAnswer);
    // Assert
    final List<String> actualMethods = plugin.methodsCalled();
    expect(actualMethods.where((String m) => m == 'create'), hasLength(1));
    expect(actualMethods.where((String m) => m == 'stop'), hasLength(2));
    expect(actualMethods, contains('setPlayerMode'));
  });

  test('logs a sound that cannot play instead of failing', () async {
    // Arrange
    plugin.failsOnStop = true;
    final AudioSoundPlayer player = AudioSoundPlayer();
    // Act
    final Future<void> actualPlay = player.play(GameFeedback.wrongAnswer);
    // Assert
    await expectLater(actualPlay, completes);
    expect(cache.loadedPaths, isEmpty);
  });
}
