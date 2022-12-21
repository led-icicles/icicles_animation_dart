part of 'curve.dart';

abstract class ElacticCurve extends Curve {
  const ElacticCurve({this.period = 0.4});

  /// The duration of the oscillation.
  final double period;
}

class _ElasticInCurve extends ElacticCurve {
  /// Creates an elastic-in curve.
  const _ElasticInCurve({super.period});

  @override
  double transform(double t) {
    final s = period / 4.0;
    t = t - 1.0;
    return -math.pow(2.0, 10.0 * t) *
        math.sin((t - s) * (math.pi * 2.0) / period);
  }
}

class _ElasticOutCurve extends ElacticCurve {
  /// Creates an elastic-out curve.
  const _ElasticOutCurve({super.period});

  @override
  double transform(double t) {
    final s = period / 4.0;
    return math.pow(2.0, -10 * t) *
            math.sin((t - s) * (math.pi * 2.0) / period) +
        1.0;
  }
}

class _ElasticInOutCurve extends ElacticCurve {
  /// Creates an elastic-in-out curve.
  const _ElasticInOutCurve({super.period});

  @override
  double transform(double t) {
    final s = period / 4.0;
    t = 2.0 * t - 1.0;
    if (t < 0.0) {
      return -0.5 *
          math.pow(2.0, 10.0 * t) *
          math.sin((t - s) * (math.pi * 2.0) / period);
    } else {
      return math.pow(2.0, -10.0 * t) *
              math.sin((t - s) * (math.pi * 2.0) / period) *
              0.5 +
          1.0;
    }
  }
}
