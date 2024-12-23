part of 'curve.dart';

abstract class CircleCurve extends Curve {
  const CircleCurve();
}

class _CircleInCurve extends CircleCurve {
  const _CircleInCurve();

  @override
  double transform(double progress) {
    return 1 - math.sqrt(1 - progress * progress);
  }
}

class _CircleOutCurve extends CircleCurve {
  const _CircleOutCurve();

  @override
  double transform(double progress) {
    return math.sqrt(1 - --progress * progress);
  }
}

class _CircleInOutCurve extends CircleCurve {
  const _CircleInOutCurve();

  @override
  double transform(double progress) {
    return ((progress *= 2) <= 1
            ? 1 - math.sqrt(1 - progress * progress)
            : math.sqrt(1 - (progress -= 2) * progress) + 1) /
        2;
  }
}
