import 'package:meta/meta.dart';

/// A draw of questions fixed by a seed, such as the one a challenge code
/// carries: the frozen generator of [version] turns it into the same
/// questions on every phone.
@immutable
final class SeededDraw {
  /// Creates the draw of [seed] for the generator [version].
  const SeededDraw({required this.seed, required this.version});

  /// Seed of the draw.
  final int seed;

  /// Version of the frozen generator that turns the seed into questions.
  final int version;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SeededDraw && other.seed == seed && other.version == version;
  }

  @override
  int get hashCode => Object.hash(seed, version);
}
