import 'package:icicles_animation_dart/src/core/core.dart';

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

class DoubleTween implements Tween<double> {
  @override
  final double begin;

  @override
  final double end;

  const DoubleTween({required this.begin, required this.end});

  @override
  double transform(double progress) {
    if (progress == 0.0) {
      return begin;
    } else if (progress == 1.0) {
      return end;
    } else {
      return begin + (end - begin) * progress;
    }
  }

  @override
  String toString() => 'DoubleTween($begin → $end)';
}

class ColorTween implements Tween<Color> {
  @override
  final Color begin;

  @override
  final Color end;

  const ColorTween({required this.begin, required this.end});

  @override
  Color transform(double progress) {
    return Color.linearBlend(begin, end, progress);
  }

  @override
  String toString() => 'ColorTween($begin → $end)';
}
