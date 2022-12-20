import 'curve.dart';

abstract class CubicCurve extends Curve {
  const CubicCurve();
}

class CubicInCurve extends CubicCurve {
  const CubicInCurve();

  @override
  double transform(double progress) {
    return progress * progress * progress;
  }
}

class CubicOutCurve extends CubicCurve {
  const CubicOutCurve();

  @override
  double transform(double progress) {
    return --progress * progress * progress + 1;
  }
}

class CubicInOutCurve extends CubicCurve {
  const CubicInOutCurve();

  @override
  double transform(double progress) {
    return ((progress *= 2) <= 1
            ? progress * progress * progress
            : (progress -= 2) * progress * progress + 2) /
        2;
  }
}
