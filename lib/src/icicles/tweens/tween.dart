import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:icicles_animation_dart/src/icicles/tweens/curve_tween.dart';

part 'color_tween.dart';
part 'number_tween.dart';

abstract class Tween<T> {
  const Tween._();

  /// Interpolation between two numbers.
  static NumberTween number({
    required num begin,
    required num end,
  }) =>
      NumberTween(begin: begin, end: end);

  /// Interpolation between two colors.
  static ColorTween color({
    required Color begin,
    required Color end,
  }) =>
      ColorTween(begin: begin, end: end);

  /// Interpolates [parent] tween using [curve].
  ///
  /// Example:
  /// ```
  /// final curveTween = Tween.curve(
  ///   parent: Tween.number(begin: 0.0, end: 100.0),
  ///   curve: Curves.sinIn,
  /// );
  /// ```
  static CurveTween<T> curve<T>({
    required Curve curve,
    required Tween<T> parent,
  }) =>
      CurveTween<T>(parent: parent, curve: curve);

  /// The value at the beginning of the animation.
  T get begin;

  /// The value at the end of the animation.
  T get end;

  /// Returns the interpolated value for the current [progress].
  T transform(double progress);
}
