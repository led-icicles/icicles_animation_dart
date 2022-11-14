import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';

class VisualFrameRgb565 extends VisualFrame {
  @override
  FrameType get type => FrameType.VisualFrameRgb565;

  /// [(1)type][(2)duration][(ledsCount*2)pixels]
  @override
  int get size {
    const typeSize = 1;
    const durationSize = 2;
    final colorsSize = pixels.length * 2;
    return typeSize + durationSize + colorsSize;
  }

  VisualFrameRgb565(super.duration, super.pixels);

  factory VisualFrameRgb565.fromVisualFrame(VisualFrame frame) {
    return VisualFrameRgb565(frame.duration, frame.pixels);
  }

  @override
  Uint8List toBytes([Endian endian = Endian.little]) {
    final writter = Writer(size, endian)
      ..writeFrameType(type)
      ..writeDuration(duration);

    /// frame pixels
    for (var i = 0; i < pixels.length; i++) {
      writter.writeColor565(pixels[i]);
    }

    return writter.bytes;
  }

  /// When [withType] is set to true, type will be also read from the [reader].
  factory VisualFrameRgb565.fromReader(
    Reader reader,
    int pixelsCount, {
    bool withType = true,
  }) {
    if (withType) {
      final frameType = reader.readFrameType();
      if (frameType != FrameType.VisualFrameRgb565) {
        throw ArgumentError('Invalid frame type : ${frameType.name}');
      }
    }

    final duration = reader.readDuration();

    final pixels = List<Color>.filled(pixelsCount, Colors.black);

    /// frame pixels
    for (var i = 0; i < pixels.length; i++) {
      pixels[i] = reader.readColor565();
    }
    return VisualFrameRgb565(duration, pixels);
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
