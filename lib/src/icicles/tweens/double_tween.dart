import 'tween.dart';

class DoubleTween implements Tween<double> {
  @override
  final double begin;

  @override
  final double end;

  const DoubleTween({required this.begin, required this.end});

  @override
  double transform(double progress) {
    if (progress == 0.0) {
      return begin;
    } else if (progress == 1.0) {
      return end;
    } else {
      return begin + (end - begin) * progress;
    }
  }

  @override
  String toString() => 'DoubleTween($begin → $end)';
}
