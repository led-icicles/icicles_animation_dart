part of 'curve.dart';

abstract class BackCurve extends Curve {
  final double overshoot;

  const BackCurve({this.overshoot = 1.70158});
}

class _BackInCurve extends BackCurve {
  const _BackInCurve({super.overshoot});

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

class _BackInOutCurve extends BackCurve {
  const _BackInOutCurve({super.overshoot});

  @override
  double transform(double t) {
    return ((t *= 2) < 1
            ? t * t * ((overshoot + 1) * t - overshoot)
            : (t -= 2) * t * ((overshoot + 1) * t + overshoot) + 2) /
        2;
  }
}
