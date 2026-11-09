import 'dart:io';
import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:test/test.dart';

import 'compat_helpers.dart';

List<int> rgb(Color c) => (Writer(3, Endian.little)..writeColor(c)).bytes;
List<int> rgb565(Color c) => (Writer(2, Endian.little)..writeColor565(c)).bytes;
List<int> rgb565Of(int value) => [value & 255, value >> 8];

Set<int> frameTypes(Animation animation) =>
    walkAnimation(animation, animation.toBytes())
        .frames
        .map((f) => f.type)
        .toSet();

void main() {
  group('opacity encoding', () {
    test('opaque colors are written unchanged', () {
      for (var v = 0; v < 256; v += 15) {
        final color = Color.fromRGB(v, 255 - v, (v * 7) % 256);
        expect(rgb(color), [color.red, color.green, color.blue]);
        expect(rgb565(color), rgb565Of(color.toRgb565()));
      }
    });

    test('translucent colors are blended with black', () {
      final half = Colors.white.withOpacity(0.5);
      expect(rgb(half), [128, 128, 128]);
      expect(rgb(Colors.red.withOpacity(0.5)), [128, 0, 0]);
      expect(rgb(const Color(0x00ff0000)), [0, 0, 0]);
      expect(rgb(Colors.transparent), [0, 0, 0]);
      expect(rgb565(half), rgb565Of(Color.fromRGB(128, 128, 128).toRgb565()));
    });

    test('indexed colors use the same blending', () {
      final color = IndexedColor(7, Colors.red.withOpacity(0.5));
      expect((Writer(5, Endian.little)..writeIndexedColor(color)).bytes,
          [7, 0, 128, 0, 0]);
      expect((Writer(4, Endian.little)..writeIndexedColor565(color)).bytes,
          [7, 0, ...rgb565Of(Color.fromRGB(128, 0, 0).toRgb565())]);
    });
  });

  group('frame duration', () {
    test('negative duration is rejected', () {
      expect(() => DelayFrame(duration: ms(-5)), throwsArgumentError);
    });

    test('zero and max durations are accepted', () {
      expect(DelayFrame(duration: Duration.zero).duration, Duration.zero);
      expect(
          DelayFrame(duration: Frame.maxDuration).duration, Frame.maxDuration);
    });
  });

  test('animation name with NUL is rejected', () {
    expect(() => AnimationHeader(name: 'a\u0000b', xCount: 1, yCount: 1),
        throwsArgumentError);
    expect(
        () => Animation('a\u0000b', xCount: 1, yCount: 1), throwsArgumentError);
  });

  group('rejected radio visual frame is not stored', () {
    for (final optimize in [true, false]) {
      test('optimize=$optimize', () {
        final animation = Animation('x',
            xCount: 1,
            yCount: 1,
            radioPanelsCount: 1,
            radioPanelPixelCount: 2,
            optimize: optimize);
        animation
            .addFrame(VisualFrame(duration: ms(100), pixels: [Colors.red]));
        expect(
          () => animation.addFrame(RadioVisualFrame(
              duration: ms(100),
              index: 1,
              colors: [Colors.red, Colors.blue, Colors.green])),
          throwsArgumentError,
        );
        expect(animation.frameCount, 1);
        expect(Animation.fromBytes(animation.toBytes()).frameCount, 1);
      });
    }

    test('replacing the last zero-duration radio frame', () {
      final animation = Animation('x',
          xCount: 1, yCount: 1, radioPanelsCount: 1, radioPanelPixelCount: 2);
      animation.addFrame(RadioColorFrame(
          duration: Duration.zero, index: 1, color: Colors.red));
      final before = animation.frames.single;
      expect(
        () => animation.addFrame(RadioVisualFrame(
            duration: Duration.zero,
            index: 1,
            colors: [Colors.red, Colors.blue, Colors.green])),
        throwsArgumentError,
      );
      expect(animation.frames.single, before);
    });
  });

  group('clear', () {
    test('restarts optimization from a black view', () {
      final animation = Animation('x', xCount: 1, yCount: 1);
      animation.addFrame(VisualFrame(duration: ms(100), pixels: [Colors.red]));
      animation.clear();
      animation
        ..addFrame(DelayFrame(duration: ms(100)))
        ..addFrame(VisualFrame(duration: ms(100), pixels: [Colors.red]));
      expect(
        animation.frames.whereType<VisualFrame>().single.pixels,
        [Colors.red],
      );
      expect(animation.play().first.frame.pixels, [Colors.black]);
      expect(animation.play().elementAt(1).frame.pixels, [Colors.red]);
    });

    test('resets radio panels', () {
      final animation =
          Animation('x', xCount: 1, yCount: 1, radioPanelsCount: 2);
      animation.addFrame(
          RadioColorFrame(duration: ms(100), index: 0, color: Colors.red));
      animation.clear();
      expect(
        animation.currentView.radioPanels.expand((p) => p.colors),
        everyElement(Colors.black),
      );
    });
  });

  group('rgb565', () {
    Animation rgb565Animation({int radioPanelsCount = 0}) => Animation('x',
        xCount: 2,
        yCount: 2,
        useRgb565: true,
        radioPanelsCount: radioPanelsCount);

    test('pause followed by a change', () {
      final animation = rgb565Animation();
      final icicles = Icicles(animation)
        ..setAllPixelsColor(Colors.red)
        ..show(ms(100))
        ..show(ms(100))
        ..setAllPixelsColor(Colors.blue)
        ..show(ms(100));
      expect(icicles.animation.duration, ms(300));
      expect(frameTypes(animation), {12});
    });

    test('delay frame first', () {
      final animation = rgb565Animation()
        ..addFrame(DelayFrame(duration: ms(100)))
        ..addFrame(VisualFrame.filled(ms(100), 4, Colors.red));
      expect(frameTypes(animation), {1, 12});
    });

    test('radio panels with Icicles.show', () {
      final animation = rgb565Animation(radioPanelsCount: 1);
      Icicles(animation)
        ..setAllPixelsColor(Colors.red)
        ..setRadioPanelColor(0, Colors.blue)
        ..show(ms(100));
      expect(frameTypes(animation), {100, 12});
    });

    test('toBytes matches toFile after a pause', () async {
      final animation = rgb565Animation()
        ..addFrame(VisualFrame.filled(ms(100), 4, Colors.red))
        ..addFrame(DelayFrame(duration: ms(100)));
      final tmp = await Directory.systemTemp.createTemp('icicles_rgb565');
      try {
        final file = await animation.toFile('${tmp.path}/a.anim');
        expect(await file.readAsBytes(), orderedEquals(animation.toBytes()));
      } finally {
        await tmp.delete(recursive: true);
      }
    });
  });

  group('v1 radio visual frames', () {
    test('identical colors are stored as radio color frames', () {
      final animation = Animation('x',
          xCount: 1,
          yCount: 1,
          radioPanelsCount: 1,
          version: AnimationVersion.v1,
          optimize: false);
      Icicles(animation)
        ..setRadioPanelColor(0, Colors.red)
        ..show(ms(100));
      expect(frameTypes(animation), {100, 2});
      expect(Animation.fromBytes(animation.toBytes()).frameCount,
          animation.frameCount);
    });

    test('different colors keep the previous behavior', () {
      final animation = Animation('x',
          xCount: 1,
          yCount: 1,
          radioPanelsCount: 1,
          radioPanelPixelCount: 2,
          version: AnimationVersion.v1,
          optimize: false);
      animation.addFrame(RadioVisualFrame(
          duration: ms(100), index: 1, colors: [Colors.red, Colors.blue]));
      expect(animation.frames.single, isA<RadioVisualFrame>());
    });
  });
}
