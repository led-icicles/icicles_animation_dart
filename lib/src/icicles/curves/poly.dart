part of 'curve.dart';

abstract class PolyCurve extends Curve {
  final double exponent;

  const PolyCurve({this.exponent = 3.0});
}

class _PolyInCurve extends PolyCurve {
  const _PolyInCurve();

  @override
  double transform(double progress) {
    return math.pow(progress, exponent) as double;
  }
}

class _PolyOutCurve extends PolyCurve {
  const _PolyOutCurve();

  @override
  double transform(double progress) {
    return 1 - math.pow(1 - progress, exponent) as double;
  }
}

class _PolyInOutCurve extends PolyCurve {
  const _PolyInOutCurve();

  @override
  double transform(double progress) {
    return ((progress *= 2) <= 1
            ? math.pow(progress, exponent)
            : 2 - math.pow(2 - progress, exponent)) /
        2;
  }
}
