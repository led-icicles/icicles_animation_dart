import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:test/test.dart';

import '../compat/compat_helpers.dart';

List<AnimationView> firstPass(Animation animation) {
  final loops =
      animation.header.loopsCount == 0 ? 1 : animation.header.loopsCount;
  final all = animation.play().toList();
  final passLength = (all.length - 1) ~/ loops;
  return all
      .take(passLength)
      .where((view) => view.frame.duration > Duration.zero)
      .toList();
}

void main() {
  for (final scenario in scenarios) {
    test('${scenario.name}: indexes the first pass of play()', () {
      final animation = scenario.build();
      final index = animation.toIndex();

      expect(index.views, firstPass(animation));
      expect(index.duration, animation.duration);

      for (var i = 0; i < index.views.length; i++) {
        final start = index.startOf(i);
        final end = start + index.views[i].frame.duration;
        expect(index.viewAt(start), same(index.views[i]));
        expect(index.viewAt(end - const Duration(microseconds: 1)),
            same(index.views[i]));
        expect(index.indexAt(start), i);
      }
    });
  }

  test('ignores loops', () {
    final animation = Animation('x', xCount: 1, yCount: 1, loopsCount: 3)
      ..addFrame(VisualFrame(duration: ms(100), pixels: [Colors.red]))
      ..addFrame(VisualFrame(duration: ms(50), pixels: [Colors.blue]));
    final index = animation.toIndex();

    expect(index.views.length, 2);
    expect(index.duration, ms(150));
    expect(index.viewAt(ms(120)).frame.pixels, [Colors.blue]);
  });

  test('skips zero-duration views', () {
    final animation = Animation('x',
        xCount: 1, yCount: 1, optimize: false, framerate: Framerate.unlimited)
      ..addFrame(VisualFrame(duration: Duration.zero, pixels: [Colors.red]))
      ..addFrame(VisualFrame(duration: ms(10), pixels: [Colors.blue]));
    final index = animation.toIndex();

    expect(index.views.length, 1);
    expect(index.viewAt(Duration.zero).frame.pixels, [Colors.blue]);
  });

  test('throws RangeError outside [0, duration)', () {
    final index = (Animation('x', xCount: 1, yCount: 1)
          ..addFrame(VisualFrame(duration: ms(100), pixels: [Colors.red])))
        .toIndex();

    expect(() => index.viewAt(ms(100)), throwsRangeError);
    expect(
        () => index.viewAt(const Duration(microseconds: -1)), throwsRangeError);
  });

  test('empty animation', () {
    final index = Animation('x', xCount: 1, yCount: 1).toIndex();

    expect(index.views, isEmpty);
    expect(index.duration, Duration.zero);
    expect(() => index.viewAt(Duration.zero), throwsRangeError);
  });
}
