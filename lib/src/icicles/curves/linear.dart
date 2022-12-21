part of 'curve.dart';

class LinearCurve extends Curve {
  const LinearCurve();

  @override
  double transform(double progress) {
    return progress;
  }
}
