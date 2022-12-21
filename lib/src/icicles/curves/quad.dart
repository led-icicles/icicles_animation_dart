part of 'curve.dart';

abstract class QuadCurve extends Curve {
  const QuadCurve();
}

class _QuadInCurve extends QuadCurve {
  const _QuadInCurve();

  @override
  double transform(double progress) {
    return progress * progress;
  }
}

class _QuadOutCurve extends QuadCurve {
  const _QuadOutCurve();

  @override
  double transform(double progress) {
    return progress * (2 - progress);
  }
}

class _QuadInOutCurve extends QuadCurve {
  const _QuadInOutCurve();

  @override
  double transform(double progress) {
    return ((progress *= 2) <= 1
            ? progress * progress
            : --progress * (2 - progress) + 1) /
        2;
  }
}
