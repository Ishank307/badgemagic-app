import 'dart:math';
import 'package:badgemagic/badge_animation/animation_abstract.dart';

/// An animation that simulates a graphic equalizer with bouncing vertical bars.
class EqualizerAnimation extends BadgeAnimation {
  // --- Animation Parameters ---
  /// The width of each vertical bar in pixels.
  static const int barWidth = 4;

  /// The width of the gap between each bar.
  static const int gapWidth = 1;

  /// The probability (0.0 to 1.0) that a bar will change its height on any given frame.
  /// Higher values make the animation more frantic.
  static const double changeChance = 0.7;

  /// The probability that instead of nudging, a bar completely resets to a random height.
  static const double resetChance = 0.2;

  final List<int> _barHeights = [];
  bool _initialized = false;
  final Random _rng = Random();

  void _initialize(int badgeHeight, int badgeWidth) {
    if (_initialized) return;
    _initialized = true;

    final int numberOfBars = (badgeWidth + gapWidth) ~/ (barWidth + gapWidth);
    for (int i = 0; i < numberOfBars; i++) {
      _barHeights.add(_rng.nextInt(badgeHeight) + 1);
    }
  }

  @override
  void processAnimation(
    int badgeHeight,
    int badgeWidth,
    int animationIndex,
    List<List<bool>> processGrid,
    List<List<bool>> canvas,
  ) {
    _initialize(badgeHeight, badgeWidth);

    for (int y = 0; y < badgeHeight; y++) {
      for (int x = 0; x < badgeWidth; x++) {
        canvas[y][x] = false;
      }
    }

    // keeing this part of code same
    final int numberOfBars = (badgeWidth + gapWidth) ~/ (barWidth + gapWidth);

    for (int i = 0; i < numberOfBars; i++) {
      // Randomly decide whether to change the height of this bar.
      if (_rng.nextDouble() < changeChance) {
        if (_rng.nextDouble() < resetChance) {
          // Occasionally jump to a completely random height
          _barHeights[i] = _rng.nextInt(badgeHeight) + 1;
        } else {
          // Otherwise just wobble by -1, 0, or +1
          int heightChange = _rng.nextInt(3) - 1;
          _barHeights[i] =
              (_barHeights[i] + heightChange).clamp(1, badgeHeight);
        }
      }
    }

    for (int i = 0; i < numberOfBars; i++) {
      int barHeight = _barHeights[i];

      int startX = i * (barWidth + gapWidth);

      for (int y = badgeHeight - 1; y >= badgeHeight - barHeight; y--) {
        for (int x = startX; x < startX + barWidth; x++) {
          if (y >= 0 && y < badgeHeight && x >= 0 && x < badgeWidth) {
            canvas[y][x] = true;
          }
        }
      }
    }
  }
}
