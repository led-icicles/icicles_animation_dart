part of 'tween.dart';

class NumberTween implements Tween<num> {
  @override
  final num begin;

  @override
  final num end;

  const NumberTween({required this.begin, required this.end});

  @override
  num transform(double progress) {
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
