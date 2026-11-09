import 'dart:io';
import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:icicles_animation_dart/src/frames/additive_frame_rgb565.dart';
import 'package:test/test.dart';

import 'compat_helpers.dart';

Animation singleFrame(int loopsCount) =>
    Animation('x', xCount: 1, yCount: 1, loopsCount: loopsCount)
      ..addFrame(VisualFrame(duration: ms(100), pixels: [Colors.red]));

Animation mixedFrames({required bool useRgb565}) {
  final animation = Animation('x', xCount: 4, yCount: 3, useRgb565: useRgb565);
  Icicles(animation)
    ..setAllPixelsColor(Colors.red)
    ..show(ms(100))
    ..show(ms(100))
    ..setPixelColorAtIndex(5, Colors.blue)
    ..show(ms(100))
    ..setAllPixelsColor(Colors.green)
    ..show(ms(100));
  return animation;
}

List<int> types(Animation animation, Uint8List bytes) =>
    walkAnimation(animation, bytes).frames.map((f) => f.type).toList();

List<int> durations(Animation animation, Uint8List bytes) =>
    walkAnimation(animation, bytes).frames.map((f) => f.duration).toList();

void main() {
  group('play', () {
    test('infinite animation plays once by default', () {
      expect(singleFrame(0).play().length, 2);
    });

    test('infinite animation respects the loops limit', () {
      expect(singleFrame(0).play(infiniteLoopsLimit: 3).length, 4);
    });

    test('loops limit does not affect a finite animation', () {
      expect(singleFrame(2).play(infiniteLoopsLimit: 5).length, 3);
    });

    test('loops limit must be positive', () {
      expect(() => singleFrame(0).play(infiniteLoopsLimit: 0),
          throwsArgumentError);
    });
  });

  group('color format', () {
    for (final useRgb565 in [false, true]) {
      test('round trip keeps bytes (useRgb565=$useRgb565)', () {
        final bytes = mixedFrames(useRgb565: useRgb565).toBytes();
        final decoded = Animation.fromBytes(bytes);
        expect(decoded.useRgb565, useRgb565);
        expect(decoded.toBytes(), orderedEquals(bytes));
      });
    }

    test('mixed file is decoded as rgb565 only', () {
      final header = AnimationHeader(name: 'x', xCount: 2, yCount: 1);
      final bytes = (BytesBuilder()
            ..add(header.toBytes())
            ..add(VisualFrame.filled(ms(100), 2, Colors.red).toBytes())
            ..add(AdditiveFrameRgb565(
                duration: ms(100),
                changedPixels: [IndexedColor(1, Colors.blue)]).toBytes()))
          .toBytes();
      final decoded = Animation.fromBytes(bytes);
      expect(decoded.useRgb565, isTrue);
      expect(types(decoded, decoded.toBytes()), [12, 13]);
    });

    test('format can be chosen when encoding', () async {
      final rgb888 = mixedFrames(useRgb565: false);
      final rgb565 = mixedFrames(useRgb565: true);
      final as565 = rgb888.toBytes(Endian.little, true);
      final as888 = rgb565.toBytes(Endian.little, false);

      expect(types(rgb888, rgb888.toBytes()), [2, 3, 2]);
      expect(types(rgb888, as565), [12, 13, 12]);
      expect(durations(rgb888, as565), durations(rgb888, rgb888.toBytes()));
      expect(types(rgb565, as888), [2, 3, 2]);
      expect(as565, orderedEquals(rgb565.toBytes()));

      final tmp = await Directory.systemTemp.createTemp('icicles_format');
      try {
        final file = await rgb888.toFile('${tmp.path}/a.anim', useRgb565: true);
        expect(await file.readAsBytes(), orderedEquals(as565));
      } finally {
        await tmp.delete(recursive: true);
      }
    });

    test('toAdditiveFrame returns an rgb888 frame', () {
      final frame = AdditiveFrameRgb565(
          duration: ms(100), changedPixels: [IndexedColor(1, Colors.blue)]);
      expect(frame.toAdditiveFrame().runtimeType, AdditiveFrame);
      expect(frame.toAdditiveFrame().type, FrameType.additive);
    });
  });

  group('coordinates', () {
    test('out of range coordinates are rejected', () {
      final pixels = PixelsView.filled(const Size(3, 3), Colors.black);
      expect(pixels.getPixelIndex(2, 1), 7);
      for (final (x, y) in [(0, 3), (3, 0), (-1, 0), (0, -1)]) {
        expect(() => pixels.getPixelIndex(x, y), throwsRangeError,
            reason: '($x, $y)');
      }
      expect(() => pixels.getRow(3), throwsRangeError);
      expect(() => pixels.getColumn(3), throwsRangeError);
      final header = AnimationHeader(name: 'x', xCount: 3, yCount: 3);
      final frame = VisualFrame.filled(ms(100), 9, Colors.black);
      expect(() => frame.getPixelIndex(header, 0, 3), throwsRangeError);
      expect(() => frame.getRow(header, 3), throwsRangeError);
    });

    test('rejected row or column leaves pixels untouched', () {
      final icicles = Icicles(Animation('x', xCount: 3, yCount: 3));
      expect(() => icicles.setRowColor(3, Colors.red), throwsRangeError);
      expect(() => icicles.setColumnColor(3, Colors.red), throwsRangeError);
      expect(() => icicles.setPixelColor(0, 3, Colors.red), throwsRangeError);
      expect(icicles.strip, everyElement(Colors.black));
    });
  });

  test('IndexedColor.blend blends its own color', () {
    final blended = IndexedColor(7, Colors.black).blend(Colors.white, 0.5);
    expect(blended, isA<IndexedColor>());
    expect((blended as IndexedColor).index, 7);
    expect(blended.value, Colors.black.blend(Colors.white, 0.5).value);
  });

  test('CurveTween is exported', () {
    final CurveTween<num> tween = Tween.curve(
      curve: Curves.linear,
      parent: Tween.number(begin: 0, end: 10),
    );
    expect(tween.transform(0.5), 5);
  });

  test('NumberTween.toString', () {
    expect(Tween.number(begin: 0, end: 1).toString(), 'NumberTween(0 → 1)');
  });

  test('drop mode keeps duration above Frame.maxDuration', () {
    final animation = Animation('x',
        xCount: 1, yCount: 1, framerateBehavior: FramerateBehavior.drop)
      ..addFrame(VisualFrame(duration: ms(100), pixels: [Colors.red]))
      ..addFrame(VisualFrame(duration: ms(10), pixels: [Colors.green]))
      ..addFrame(
          VisualFrame(duration: Frame.maxDuration, pixels: [Colors.blue]));
    expect(animation.duration, ms(100) + ms(10) + Frame.maxDuration);
    expect(animation.frames.last, isA<DelayFrame>());
  });

  test('frames snapshot is cached until the animation changes', () {
    final animation = singleFrame(1);
    final snapshot = animation.frames;
    expect(identical(animation.frames, snapshot), isTrue);
    animation.addFrame(VisualFrame(duration: ms(100), pixels: [Colors.blue]));
    expect(animation.frames, hasLength(2));
    expect(snapshot, hasLength(1));
    animation.clear();
    expect(animation.frames, isEmpty);
  });
}
