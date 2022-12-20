import 'package:icicles_animation_dart/icicles_animation_dart.dart';

double _bounce(double t) {
  const b1 = 4 / 11,
      b2 = 6 / 11,
      b3 = 8 / 11,
      b4 = 3 / 4,
      b5 = 9 / 11,
      b6 = 10 / 11,
      b7 = 15 / 16,
      b8 = 21 / 22,
      b9 = 63 / 64,
      b0 = 1 / b1 / b1;

  return (t = t) < b1
      ? b0 * t * t
      : t < b3
          ? b0 * (t -= b2) * t + b4
          : t < b6
              ? b0 * (t -= b5) * t + b7
              : b0 * (t -= b8) * t + b9;
}

abstract class BounceCurve extends Curve {
  const BounceCurve();
}

class BounceInCurve extends BounceCurve {
  const BounceInCurve();

  @override
  double transform(double progress) {
    return 1 - _bounce(1 - progress);
  }
}

class BounceOutCurve extends BounceCurve {
  const BounceOutCurve();

  @override
  double transform(double progress) {
    return _bounce(progress);
  }
}

class BounceInOutCurve extends BounceCurve {
  const BounceInOutCurve();

  @override
  double transform(double progress) {
    return ((progress *= 2) <= 1
            ? 1 - _bounce(1 - progress)
            : _bounce(progress - 1) + 1) /
        2;
  }
}
