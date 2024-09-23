import 'dart:math' as math;

part 'circle.dart';
part 'cubic.dart';
part 'exp.dart';
part 'linear.dart';
part 'back.dart';
part 'bounce.dart';
part 'elastic.dart';
part 'poly.dart';
part 'quad.dart';
part 'sin.dart';

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

  static const Curve backIn = _BackInCurve();
  static const Curve backOut = _BackOutCurve();
  static const Curve backInOut = _BackInOutCurve();

  /// Bounce

  static const Curve bounceIn = _BounceInCurve();
  static const Curve bounceOut = _BounceOutCurve();
  static const Curve bounceInOut = _BounceInOutCurve();

  /// Elastic

  static const Curve elasticIn = _ElasticInCurve();
  static const Curve elasticOut = _ElasticOutCurve();
  static const Curve elasticInOut = _ElasticInOutCurve();

  /// Sin

  static const Curve sinIn = _SinInCurve();
  static const Curve sinOut = _SinOutCurve();
  static const Curve sinInOut = _SinInOutCurve();

  /// Cubic

  static const Curve cubicIn = _CubicInCurve();
  static const Curve cubicOut = _CubicOutCurve();
  static const Curve cubicInOut = _CubicInOutCurve();

  /// Exp

  static const Curve expIn = _ExpInCurve();
  static const Curve expOut = _ExpOutCurve();
  static const Curve expInOut = _ExpInOutCurve();

  /// Poly

  static const Curve polyIn = _PolyInCurve();
  static const Curve polyOut = _PolyOutCurve();
  static const Curve polyInOut = _PolyInOutCurve();

  /// Circle

  static const Curve circleIn = _CircleInCurve();
  static const Curve circleOut = _CircleOutCurve();
  static const Curve circleInOut = _CircleInOutCurve();

  /// Quad

  static const Curve quadIn = _QuadInCurve();
  static const Curve quadOut = _QuadOutCurve();
  static const Curve quadInOut = _QuadInOutCurve();
}
