import 'curves.dart';

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

  /// Bounce

  static const Curve bounceInCurve = BounceInCurve();
  static const Curve bounceOutCurve = BounceOutCurve();
  static const Curve bounceInOutCurve = BounceInOutCurve();

  /// Elastic

  static const Curve elasticInCurve = ElasticInCurve();
  static const Curve elasticOutCurve = ElasticOutCurve();
  static const Curve elasticInOutCurve = ElasticInOutCurve();
}
