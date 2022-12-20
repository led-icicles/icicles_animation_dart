import 'curve.dart';
import 'dart:math' as math;

abstract class ElacticCurve extends Curve {
  const ElacticCurve({this.period = 0.4});

  /// The duration of the oscillation.
  final double period;
}

class ElasticInCurve extends ElacticCurve {
  /// Creates an elastic-in curve.
  const ElasticInCurve({super.period});

  @override
  double transform(double t) {
    final s = period / 4.0;
    t = t - 1.0;
    return -math.pow(2.0, 10.0 * t) *
        math.sin((t - s) * (math.pi * 2.0) / period);
  }
}

class ElasticOutCurve extends ElacticCurve {
  /// Creates an elastic-out curve.
  const ElasticOutCurve({super.period});

  @override
  double transform(double t) {
    final s = period / 4.0;
    return math.pow(2.0, -10 * t) *
            math.sin((t - s) * (math.pi * 2.0) / period) +
        1.0;
  }
}

class ElasticInOutCurve extends ElacticCurve {
  /// Creates an elastic-in-out curve.
  const ElasticInOutCurve({super.period});

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
