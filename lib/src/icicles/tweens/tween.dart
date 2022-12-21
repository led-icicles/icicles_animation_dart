import 'package:icicles_animation_dart/src/core/core.dart';

import 'color_tween.dart';
import 'double_tween.dart';

abstract class Tween<T> {
  /// Interpolation between two double numbers.
  static DoubleTween number({
    required double begin,
    required double end,
  }) =>
      DoubleTween(begin: begin, end: end);

  /// Interpolation between two colors.
  static ColorTween color({
    required Color begin,
    required Color end,
  }) =>
      ColorTween(begin: begin, end: end);

  /// The value at the beginning of the animation.
  T get begin;

  /// The value at the end of the animation.
  T get end;

  /// Returns the interpolated value for the current [progress].
  T transform(double progress);
}
