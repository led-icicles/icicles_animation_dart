import 'curve.dart';

abstract class QuadCurve extends Curve {
  const QuadCurve();
}

class QuadInCurve extends QuadCurve {
  const QuadInCurve();

  @override
  double transform(double progress) {
    return progress * progress;
  }
}

class QuadOutCurve extends QuadCurve {
  const QuadOutCurve();

  @override
  double transform(double progress) {
    return progress * (2 - progress);
  }
}

class QuadInOutCurve extends QuadCurve {
  const QuadInOutCurve();

  @override
  double transform(double progress) {
    return ((progress *= 2) <= 1
            ? progress * progress
            : --progress * (2 - progress) + 1) /
        2;
  }
}
