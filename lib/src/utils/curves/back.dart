import 'package:icicles_animation_dart/icicles_animation_dart.dart';

abstract class BackCurve extends Curve {
  final double overshoot;

  const BackCurve({this.overshoot = 1.70158});
}

class BackInCurve extends BackCurve {
  const BackInCurve({super.overshoot});

  @override
  double transform(double t) {
    return (t = t) * t * (overshoot * (t - 1) + t);
  }
}

class BackOutCurve extends BackCurve {
  const BackOutCurve({super.overshoot});

  @override
  double transform(double t) {
    return --t * t * ((t + 1) * overshoot + t) + 1;
  }
}

class BackInOutCurve extends BackCurve {
  const BackInOutCurve({super.overshoot});

  @override
  double transform(double t) {
    return ((t *= 2) < 1
            ? t * t * ((overshoot + 1) * t - overshoot)
            : (t -= 2) * t * ((overshoot + 1) * t + overshoot) + 2) /
        2;
  }
}
