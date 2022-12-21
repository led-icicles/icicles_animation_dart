part of 'curve.dart';

/// tpmt is two power minus ten times t scaled to [0,1]
double _tpmt(double x) {
  return (math.pow(2, -10 * x) - 0.0009765625) * 1.0009775171065494;
}

abstract class ExpCurve extends Curve {
  const ExpCurve();
}

class _ExpInCurve extends ExpCurve {
  const _ExpInCurve();

  @override
  double transform(double progress) {
    return _tpmt(1 - progress);
  }
}

class _ExpOutCurve extends ExpCurve {
  const _ExpOutCurve();

  @override
  double transform(double progress) {
    return 1 - _tpmt(progress);
  }
}

class _ExpInOutCurve extends ExpCurve {
  const _ExpInOutCurve();

  @override
  double transform(double progress) {
    return ((progress *= 2) <= 1
            ? _tpmt(1 - progress)
            : 2 - _tpmt(progress - 1)) /
        2;
  }
}
