import 'back.dart';

abstract class Curve {
  const Curve();

  /// Returns the value of the curve at the [progress] point.
  double transform(double progress);
}

class Curves {
  const Curves._();

  /// Back

  static const Curve backInCurve = BackInCurve();
  static const Curve backOutCurve = BackInOutCurve();
  static const Curve backInOutCurve = BackInOutCurve();
}
