import 'curve.dart';
import 'dart:math' as math;

abstract class CircleCurve extends Curve {
  const CircleCurve();
}

class CircleInCurve extends CircleCurve {
  const CircleInCurve();

  @override
  double transform(double progress) {
    return 1 - math.sqrt(1 - progress * progress);
  }
}

class CircleOutCurve extends CircleCurve {
  const CircleOutCurve();

  @override
  double transform(double progress) {
    return math.sqrt(1 - --progress * progress);
  }
}

class CircleInOutCurve extends CircleCurve {
  const CircleInOutCurve();

  @override
  double transform(double progress) {
    return ((progress *= 2) <= 1
            ? 1 - math.sqrt(1 - progress * progress)
            : math.sqrt(1 - (progress -= 2) * progress) + 1) /
        2;
  }
}
