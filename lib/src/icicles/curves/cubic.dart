part of 'curve.dart';

abstract class CubicCurve extends Curve {
  const CubicCurve();
}

class _CubicInCurve extends CubicCurve {
  const _CubicInCurve();

  @override
  double transform(double progress) {
    return progress * progress * progress;
  }
}

class _CubicOutCurve extends CubicCurve {
  const _CubicOutCurve();

  @override
  double transform(double progress) {
    return --progress * progress * progress + 1;
  }
}

class _CubicInOutCurve extends CubicCurve {
  const _CubicInOutCurve();

  @override
  double transform(double progress) {
    return ((progress *= 2) <= 1
            ? progress * progress * progress
            : (progress -= 2) * progress * progress + 2) /
        2;
  }
}
