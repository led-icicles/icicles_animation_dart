part of 'tween.dart';

class ColorTween implements Tween<Color> {
  @override
  final Color begin;

  @override
  final Color end;

  const ColorTween({required this.begin, required this.end});

  @override
  Color transform(double progress) {
    return Color.linearBlend(begin, end, progress);
  }

  @override
  String toString() => 'ColorTween($begin → $end)';
}
