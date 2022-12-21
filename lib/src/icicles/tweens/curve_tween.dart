import 'package:icicles_animation_dart/icicles_animation_dart.dart';

class CurveTween<T> implements Tween<T> {
  final Tween<T> parent;
  final Curve curve;

  const CurveTween({
    required this.curve,
    required this.parent,
  });
  @override
  T transform(double progress) {
    return parent.transform(curve.transform(progress));
  }

  @override
  T get begin => parent.begin;

  @override
  T get end => parent.end;
}
