import 'curve.dart';
import 'dart:math' as math;

/// tpmt is two power minus ten times t scaled to [0,1]
double _tpmt(double x) {
  return (math.pow(2, -10 * x) - 0.0009765625) * 1.0009775171065494;
}

abstract class ExpCurve extends Curve {
  const ExpCurve();
}

class ExpInCurve extends ExpCurve {
  const ExpInCurve();

  @override
  double transform(double progress) {
    return _tpmt(1 - progress);
  }
}

class ExpOutCurve extends ExpCurve {
  const ExpOutCurve();

  @override
  double transform(double progress) {
    return 1 - _tpmt(progress);
  }
}

class ExpInOutCurve extends ExpCurve {
  const ExpInOutCurve();

  @override
  double transform(double progress) {
    return ((progress *= 2) <= 1
            ? _tpmt(1 - progress)
            : 2 - _tpmt(progress - 1)) /
        2;
  }
}
