part of 'curve.dart';

const _halfPi = math.pi / 2;

abstract class SinCurve extends Curve {
  const SinCurve();
}

class _SinInCurve extends SinCurve {
  const _SinInCurve();

  @override
  double transform(double progress) {
    return (progress == 1) ? 1 : 1 - math.cos(progress * _halfPi);
  }
}

class _SinOutCurve extends SinCurve {
  const _SinOutCurve();

  @override
  double transform(double progress) {
    return math.sin(progress * _halfPi);
  }
}

class _SinInOutCurve extends SinCurve {
  const _SinInOutCurve();

  @override
  double transform(double progress) {
    return (1 - math.cos(math.pi * progress)) / 2;
  }
}
