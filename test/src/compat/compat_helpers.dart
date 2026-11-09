import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:icicles_animation_dart/src/frames/additive_frame_rgb565.dart';

Duration ms(int value) => Duration(milliseconds: value);

class Scenario {
  final String name;

  /// Only color bytes may differ from the fixture.
  final bool hasTranslucentColors;
  final Animation Function() build;

  const Scenario(this.name, this.build, {this.hasTranslucentColors = false});
}

class WalkedFrame {
  final int type;
  final int offset;
  final int length;
  final int duration;

  WalkedFrame(this.type, this.offset, this.length, this.duration);

  @override
  String toString() => 'type=$type@$offset+$length:${duration}ms';
}

class WalkResult {
  final int headerSize;
  final List<WalkedFrame> frames;

  final List<bool> colorBytes;

  WalkResult(this.headerSize, this.frames, this.colorBytes);
}

/// Walks [bytes] by the binary layout; throws unless it ends exactly at EOF.
WalkResult walk(Uint8List bytes, {required int radioPanelPixelCount}) {
  final data = ByteData.sublistView(bytes);
  var p = 0;
  int u8() => bytes[p++];
  int u16() {
    final v = data.getUint16(p, Endian.little);
    p += 2;
    return v;
  }

  final version = u16();
  while (bytes[p] != 0) {
    p++;
  }
  p++;
  final xCount = u8();
  final yCount = u8();
  u16();
  u8();
  if (version >= 2) u8();
  final headerSize = p;
  final pixels = xCount * yCount;

  final colorBytes = List<bool>.filled(bytes.length, false);
  void markColors(int start, int count, int bytesPerColor) {
    for (var i = start; i < start + count * bytesPerColor; i++) {
      colorBytes[i] = true;
    }
  }

  final frames = <WalkedFrame>[];
  while (p < bytes.length) {
    final start = p;
    final type = u8();
    final duration = u16();
    switch (type) {
      case 1:
        break;
      case 2:
        markColors(p, pixels, 3);
        p += pixels * 3;
      case 12:
        markColors(p, pixels, 2);
        p += pixels * 2;
      case 3:
        final count = u16();
        for (var i = 0; i < count; i++) {
          p += 2;
          markColors(p, 1, 3);
          p += 3;
        }
      case 13:
        final count = u16();
        for (var i = 0; i < count; i++) {
          p += 2;
          markColors(p, 1, 2);
          p += 2;
        }
      case 100:
        p += 1;
        markColors(p, 1, 3);
        p += 3;
      case 101:
        p += 1;
        markColors(p, radioPanelPixelCount, 3);
        p += radioPanelPixelCount * 3;
      default:
        throw StateError('Unknown frame type $type at offset $start');
    }
    if (p > bytes.length) {
      throw StateError('Frame type $type at $start runs past the end of file');
    }
    frames.add(WalkedFrame(type, start, p - start, duration));
  }
  return WalkResult(headerSize, frames, colorBytes);
}

WalkResult walkAnimation(Animation animation, Uint8List bytes) => walk(
      bytes,
      radioPanelPixelCount: animation.header.radioPanelPixelCount,
    );

Color _opaque(Color c) => c.isOpaque ? c : Color.alphaBlend(c, Colors.black);

IndexedColor _opaqueIndexed(IndexedColor c) =>
    IndexedColor(c.index, _opaque(c.color));

/// Encodes [animation] with translucent colors pre-blended with black.
Uint8List encodePreBlended(Animation animation) {
  final builder = BytesBuilder()..add(animation.header.toBytes());
  for (final frame in animation.frames) {
    final Frame blended;
    if (frame is VisualFrameRgb565) {
      blended = VisualFrameRgb565(
        duration: frame.duration,
        pixels: frame.pixels.map(_opaque),
      );
    } else if (frame is VisualFrame) {
      blended = VisualFrame(
        duration: frame.duration,
        pixels: frame.pixels.map(_opaque),
      );
    } else if (frame is AdditiveFrameRgb565) {
      blended = AdditiveFrameRgb565(
        duration: frame.duration,
        changedPixels: frame.changedPixels.map(_opaqueIndexed).toList(),
      );
    } else if (frame is AdditiveFrame) {
      blended = AdditiveFrame(
        duration: frame.duration,
        changedPixels: frame.changedPixels.map(_opaqueIndexed).toList(),
      );
    } else if (frame is RadioColorFrame) {
      blended = frame.copyWith(color: _opaque(frame.color));
    } else if (frame is RadioVisualFrame) {
      blended = frame.copyWith(colors: frame.colors.map(_opaque).toList());
    } else {
      blended = frame;
    }
    builder.add(blended.toBytes());
  }
  return builder.toBytes();
}

final scenarios = <Scenario>[
  Scenario('police', _police),
  Scenario('progress', _progress),
  Scenario('bouncing_color', _bouncingColor),
  Scenario('v1_radio', _v1Radio),
  Scenario('no_optimize', _noOptimize),
  Scenario('masks', _masks),
  Scenario('loops0_utf8_curves', _loops0Utf8Curves),
  Scenario('rgb565_distinct_frames', _rgb565DistinctFrames),
  Scenario('direct_frames', _directFrames),
  Scenario('opacity_tween', _opacityTween, hasTranslucentColors: true),
  Scenario('opacity_with_opacity', _opacityWithOpacity,
      hasTranslucentColors: true),
  Scenario('opacity_rgb565', _opacityRgb565, hasTranslucentColors: true),
];

Animation _police() {
  final animation = Animation(
    'Police',
    xCount: 20,
    yCount: 30,
    radioPanelsCount: 2,
    loopsCount: 10,
    framerate: Framerate.fps30,
    framerateBehavior: FramerateBehavior.error,
  );
  final icicles = Icicles(animation);
  icicles.setAllPixelsColor(Color.fromRGB(255, 0, 0));
  icicles.setRadioPanelColor(0, Colors.red);
  icicles.show(const Duration(seconds: 2));
  icicles
    ..setAllPixelsColor(Colors.blue)
    ..setRadioPanelColor(0, Colors.blue)
    ..show(const Duration(seconds: 2));
  return animation;
}

Animation _progress() {
  final animation = Animation(
    'Progress',
    xCount: 64,
    yCount: 8,
    radioPanelsCount: 2,
    radioPanelPixelCount: 60,
    loopsCount: 2,
    framerate: Framerate.fps60,
    framerateBehavior: FramerateBehavior.drop,
  );
  final icicles = Icicles(animation);
  final tween = Tween.curve(
    curve: Curves.linear,
    parent: Tween.number(begin: 0.0, end: 1.0),
  );
  var backgroundColor = Colors.black;
  for (final foregroundColor in [
    Colors.orange,
    Colors.oceanBlue,
    Colors.magenta,
    Colors.green,
    Colors.lightBlue,
    Colors.violet,
    Colors.black,
  ]) {
    for (double i = 0; i < 1; i += 0.010) {
      icicles
        ..setAllPixelsColor(backgroundColor)
        ..setAllRadioPanelsColor(backgroundColor);
      final progress = tween.transform(i);
      final turnedOnCount = (progress * (animation.header.xCount / 2)).round();
      for (int x = 0; x < turnedOnCount; x++) {
        icicles
          ..setColumnColor(x, foregroundColor)
          ..setColumnColor(animation.header.xCount - 1 - x, foregroundColor);
      }
      final radioTurnedOnCount =
          (progress * animation.header.radioPanelPixelCount).round();
      for (final (panelIndex, panel)
          in animation.currentView.radioPanels.indexed) {
        final fromLeft = panelIndex % 2 == 0;
        for (int i = 0; i < radioTurnedOnCount; i++) {
          icicles.setRadioPanelPixelColor(panelIndex,
              fromLeft ? i : (panel.colors.length - 1 - i), foregroundColor);
        }
      }
      icicles.show(animation.framerate.minFrameDuration);
    }
    backgroundColor = foregroundColor;
  }
  return animation;
}

Animation _bouncingColor() {
  final animation = Animation(
    'Bouncing color',
    xCount: 20,
    yCount: 30,
    radioPanelsCount: 2,
    loopsCount: 10,
    framerate: Framerate.fps45,
    framerateBehavior: FramerateBehavior.drop,
  );
  final icicles = Icicles(animation);
  final tween = Tween.curve(
    curve: Curves.bounceOut,
    parent: Tween.number(begin: 0, end: icicles.size.height),
  );
  var radioPanelsColor = Colors.black;
  var backgroundColor = Colors.black;
  for (final foregroundColor in [
    Colors.black,
    Colors.orange,
    Colors.oceanBlue,
    Colors.magenta,
    Colors.green,
    Colors.lightBlue,
    Colors.violet,
    Colors.black,
    Colors.black,
  ]) {
    for (double i = 0; i < 1; i += 0.015) {
      icicles.setAllPixelsColor(backgroundColor);
      final turnedOnCount = tween.transform(i);
      for (int y = 0; y < turnedOnCount; y++) {
        icicles.setRowColor(y, foregroundColor);
      }
      icicles.setAllRadioPanelsColor(
        Color.linearBlend(
          radioPanelsColor,
          backgroundColor,
          Curves.bounceOut.transform(i),
        ),
      );
      icicles.show(Framerate.fps45.minFrameDuration);
    }
    radioPanelsColor = backgroundColor;
    backgroundColor = foregroundColor;
  }
  return animation;
}

Animation _v1Radio() {
  final animation = Animation(
    'Darkening v1',
    xCount: 10,
    yCount: 6,
    version: AnimationVersion.v1,
    radioPanelsCount: 2,
    loopsCount: 2,
    framerate: Framerate.fps30,
  );
  final icicles = Icicles(animation);
  for (var step = 0; step < 40; step++) {
    final progress = step / 39;
    icicles
      ..setAllPixelsColor(Colors.white.darken(progress))
      ..setPixelColor(step % 10, step % 6, Colors.red)
      ..setRadioPanelColor(0, Colors.green.darken(progress))
      ..setRadioPanelColor(1, Colors.blue.lighten(progress))
      ..show(ms(40));
  }
  for (var i = 0; i < 3; i++) {
    icicles.show(ms(500));
  }
  return animation;
}

Animation _noOptimize() {
  final animation = Animation(
    'Raw frames',
    xCount: 4,
    yCount: 3,
    optimize: false,
    radioPanelsCount: 2,
    radioPanelPixelCount: 3,
  );
  animation
    ..addFrame(DelayFrame(duration: ms(100)))
    ..addFrame(VisualFrame.filled(ms(50), 12, Colors.orange))
    ..addFrame(AdditiveFrame(duration: ms(60), changedPixels: [
      IndexedColor(0, Colors.red),
      IndexedColor(11, Colors.blue),
    ]))
    ..addFrame(
        RadioColorFrame(duration: Duration.zero, index: 0, color: Colors.green))
    ..addFrame(RadioVisualFrame(
        duration: ms(30),
        index: 2,
        colors: [Colors.red, Colors.green, Colors.blue]))
    ..addFrame(VisualFrame.filled(ms(50), 12, Colors.orange))
    ..addFrame(DelayFrame(duration: ms(100)));
  return animation;
}

Animation _masks() {
  final animation = Animation(
    'Masks',
    xCount: 8,
    yCount: 5,
    radioPanelsCount: 2,
    radioPanelPixelCount: 4,
    framerate: Framerate.fps30,
  );
  final icicles = Icicles(animation);
  final stripMask = PixelsView.empty(icicles.size);
  for (var x = 0; x < 8; x += 2) {
    stripMask.setColumnColor(x, Colors.white);
  }
  final panelMask = PixelsView.empty(const Size(4, 1))
    ..setPixel(1, Colors.white)
    ..setPixel(3, Colors.white);
  final masked = icicles.withMask(stripMask, [panelMask, panelMask]);
  for (var step = 0; step < 20; step++) {
    masked
      ..setAllPixelsColor(Color.fromRGB(step * 12, 0, 255 - step * 12))
      ..setAllRadioPanelsColor(Colors.yellow.darken(step / 19));
    icicles.show(ms(40));
  }
  return animation;
}

Animation _loops0Utf8Curves() {
  final animation = Animation(
    'Zażółć gęślą jaźń 🎄',
    xCount: 6,
    yCount: 4,
    loopsCount: 0,
    framerate: Framerate.fps24,
  );
  final icicles = Icicles(animation);
  for (final curve in [
    Curves.elasticOut,
    Curves.backInOut,
    Curves.expIn,
    Curves.sinInOut,
  ]) {
    final tween = Tween.curve(
      curve: curve,
      parent: Tween.color(begin: Colors.violet, end: Colors.lawnGreen),
    );
    for (var i = 0; i <= 20; i++) {
      final color = tween.transform(i / 20);
      for (var x = 0; x < 6; x++) {
        icicles.setColumnColor(x, x.isEven ? color : color.darken(0.5));
      }
      icicles.show(ms(42));
    }
  }
  return animation;
}

Animation _rgb565DistinctFrames() {
  final animation = Animation(
    'Rgb565',
    xCount: 5,
    yCount: 4,
    useRgb565: true,
    framerate: Framerate.fps30,
  );
  final icicles = Icicles(animation);
  for (var i = 0; i < 30; i++) {
    for (var p = 0; p < 20; p++) {
      icicles.setPixelColorAtIndex(
        p,
        Color.fromRGB((i * 8 + p) % 256, (i * 5) % 256, 255 - i * 8),
      );
    }
    icicles.show(ms(40));
  }
  return animation;
}

Animation _directFrames() {
  final animation = Animation(
    'Direct frames',
    xCount: 6,
    yCount: 2,
    radioPanelsCount: 3,
    radioPanelPixelCount: 3,
  );
  animation
    ..addFrame(VisualFrame.filled(ms(100), 12, Colors.black))
    ..addFrame(AdditiveFrame(
        duration: ms(30), changedPixels: [IndexedColor(2, Colors.red)]))
    ..addFrame(DelayFrame(duration: ms(40000)))
    ..addFrame(DelayFrame(duration: ms(40000)))
    ..addFrame(RadioVisualFrame(
        duration: ms(25),
        index: 0,
        colors: [Colors.red, Colors.green, Colors.blue]))
    ..addFrame(
        RadioColorFrame(duration: Duration.zero, index: 2, color: Colors.white))
    ..addFrame(RadioVisualFrame(
        duration: Duration.zero,
        index: 2,
        colors: [Colors.white, Colors.white, Colors.white]))
    ..addFrame(VisualFrame.filled(ms(50), 12, Colors.magenta))
    ..addFrame(VisualFrame.filled(ms(50), 12, Colors.magenta));
  return animation;
}

Animation _opacityTween() {
  final animation = Animation(
    'Fade out',
    xCount: 5,
    yCount: 3,
    radioPanelsCount: 2,
    radioPanelPixelCount: 2,
    framerate: Framerate.fps30,
  );
  final icicles = Icicles(animation);
  final tween = Tween.color(begin: Colors.orange, end: Colors.transparent);
  for (var i = 0; i <= 25; i++) {
    final color = tween.transform(i / 25);
    icicles
      ..setAllPixelsColor(color)
      ..setPixelColorAtIndex(0, Colors.white)
      ..setAllRadioPanelsColor(color)
      ..show(ms(40));
  }
  return animation;
}

Animation _opacityWithOpacity() {
  final animation = Animation(
    'Opacity',
    xCount: 4,
    yCount: 4,
    radioPanelsCount: 1,
    radioPanelPixelCount: 3,
    framerate: Framerate.fps30,
  );
  final icicles = Icicles(animation);
  for (var i = 0; i < 12; i++) {
    icicles
      ..setPixelColorAtIndex(i, Colors.red.withOpacity(i / 11))
      ..setPixelColorAtIndex(15 - i % 4, const Color(0x00ff0000))
      ..setRadioPanelPixelColor(
          0, i % 3, Colors.blue.withOpacity(0.25 + (i % 3) * 0.25))
      ..show(ms(40));
  }
  return animation;
}

Animation _opacityRgb565() {
  final animation = Animation(
    'Opacity rgb565',
    xCount: 5,
    yCount: 2,
    useRgb565: true,
    framerate: Framerate.fps30,
  );
  final icicles = Icicles(animation);
  for (var i = 0; i < 20; i++) {
    for (var p = 0; p < 10; p++) {
      icicles.setPixelColorAtIndex(
        p,
        Color.fromRGB(255 - i * 10, p * 20, i * 10).withOpacity((p + 1) / 10),
      );
    }
    icicles.show(ms(40));
  }
  return animation;
}
