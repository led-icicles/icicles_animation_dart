import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';

class VisualFrameRgb565 extends VisualFrame {
  @override
  FrameType get type => FrameType.visualRgb565;

  /// [(1)type][(2)duration][(ledsCount*2)pixels]
  @override
  int get size {
    const typeSize = 1;
    const durationSize = 2;
    final colorsSize = pixels.length * 2;
    return typeSize + durationSize + colorsSize;
  }

  VisualFrameRgb565({
    required super.duration,
    required super.pixels,
  });

  factory VisualFrameRgb565.fromVisualFrame(VisualFrame frame) {
    return VisualFrameRgb565(duration: frame.duration, pixels: frame.pixels);
  }

  /// Converts frame from the rgb565 to the rgb888
  VisualFrame toVisualFrame() =>
      VisualFrame(duration: duration, pixels: pixels);

  @override
  Uint8List toBytes([Endian endian = Endian.little]) {
    final writer = Writer(size, endian)
      ..writeFrameType(type)
      ..writeDuration(duration)
      ..writeAllColors565(pixels);

    return writer.bytes;
  }

  /// When [withType] is set to true, type will be also read from the [reader].
  factory VisualFrameRgb565.fromReader(
    Reader reader,
    int pixelsCount, {
    bool withType = true,
  }) {
    if (withType) {
      final frameType = reader.readFrameType();
      if (frameType != FrameType.visualRgb565) {
        throw ArgumentError('Invalid frame type : ${frameType.name}');
      }
    }

    final duration = reader.readDuration();

    final pixels = List<Color>.filled(pixelsCount, Colors.black);

    /// frame pixels
    for (var i = 0; i < pixels.length; i++) {
      pixels[i] = reader.readColor565();
    }
    return VisualFrameRgb565(duration: duration, pixels: pixels);
  }

  factory VisualFrameRgb565.fromBytes(
    Uint8List bytes,
    int pixelsCount, [
    Endian endian = Endian.little,
  ]) {
    return VisualFrameRgb565.fromReader(
      Reader(bytes, endian),
      pixelsCount,
      withType: true,
    );
  }
}
