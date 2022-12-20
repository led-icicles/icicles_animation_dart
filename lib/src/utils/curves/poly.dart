import 'curve.dart';
import 'dart:math' as math;

abstract class PolyCurve extends Curve {
  final double exponent;

  const PolyCurve({this.exponent = 3.0});
}

class PolyInCurve extends PolyCurve {
  const PolyInCurve();

  @override
  double transform(double progress) {
    return math.pow(progress, exponent) as double;
  }
}

class PolyOutCurve extends PolyCurve {
  const PolyOutCurve();

  @override
  double transform(double progress) {
    return 1 - math.pow(1 - progress, exponent) as double;
  }
}

class PolyInOutCurve extends PolyCurve {
  const PolyInOutCurve();

  @override
  double transform(double progress) {
    return ((progress *= 2) <= 1
            ? math.pow(progress, exponent)
            : 2 - math.pow(2 - progress, exponent)) /
        2;
  }
}
