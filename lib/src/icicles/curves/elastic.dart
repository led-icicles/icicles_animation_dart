part of 'curve.dart';

abstract class ElasticCurve extends Curve {
  const ElasticCurve({this.period = 0.4});

  /// The duration of the oscillation.
  final double period;

  const factory ElasticCurve.elasticIn({double period}) = _ElasticInCurve;
  const factory ElasticCurve.elasticOut({double period}) = _ElasticOutCurve;
  const factory ElasticCurve.elasticInOut({double period}) = _ElasticInOutCurve;
}

class _ElasticInCurve extends ElasticCurve {
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

class _ElasticOutCurve extends ElasticCurve {
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

class _ElasticInOutCurve extends ElasticCurve {
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
