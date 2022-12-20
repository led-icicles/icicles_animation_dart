import 'package:icicles_animation_dart/src/utils/curves/linear.dart';

import 'curves.dart';

abstract class Curve {
  const Curve();

  /// Returns the value of the curve at the [progress] point.
  double transform(double progress);
}

class Curves {
  const Curves._();

  /// Linear

  static const Curve linear = LinearCurve();

  /// Back

  static const Curve backIn = BackInCurve();
  static const Curve backOut = BackInOutCurve();
  static const Curve backInOut = BackInOutCurve();

  /// Bounce

  static const Curve bounceIn = BounceInCurve();
  static const Curve bounceOut = BounceOutCurve();
  static const Curve bounceInOut = BounceInOutCurve();

  /// Elastic

  static const Curve elasticIn = ElasticInCurve();
  static const Curve elasticOut = ElasticOutCurve();
  static const Curve elasticInOut = ElasticInOutCurve();
}
