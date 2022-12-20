import 'curve.dart';
import 'dart:math' as math;

const _halfPi = math.pi / 2;

abstract class SinCurve extends Curve {
  const SinCurve();
}

class SinInCurve extends SinCurve {
  const SinInCurve();

  @override
  double transform(double progress) {
    return (progress == 1) ? 1 : 1 - math.cos(progress * _halfPi);
  }
}

class SinOutCurve extends SinCurve {
  const SinOutCurve();

  @override
  double transform(double progress) {
    return math.sin(progress * _halfPi);
  }
}

class SinInOutCurve extends SinCurve {
  const SinInOutCurve();

  @override
  double transform(double progress) {
    return (1 - math.cos(math.pi * progress)) / 2;
  }
}
