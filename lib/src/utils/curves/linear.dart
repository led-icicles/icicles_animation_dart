import 'package:icicles_animation_dart/icicles_animation_dart.dart';

class LinearCurve extends Curve {
  const LinearCurve();

  @override
  double transform(double progress) {
    return progress;
  }
}
