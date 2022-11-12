import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';

/// This frame does not support opacity when converted to bytes
class VisualFrame extends Frame {
  @override
  FrameType get type => FrameType.VisualFrame;
  final List<Color> pixels;

  VisualFrame(
    super.duration,
    this.pixels,
  );

  factory VisualFrame.filled(
    Duration duration,
    int pixels,
    Color color,
  ) {
    return VisualFrame(
        duration, List.unmodifiable((List.filled(pixels, color))));
  }

  /// Verify wether two visual frames are compatibility
  static void assertVisualFramesCompatibility(
      Frame prevFrame, Frame nextFrame) {
    if (!(prevFrame is VisualFrame) || !(nextFrame is VisualFrame)) {
      throw ArgumentError('Bad frame type.');
    } else if (prevFrame.size != nextFrame.size) {
      throw ArgumentError('Frames cannot have different sizes.');
    }
  }

  /// Copy visual frame instance
  ///
  /// This is slightly faster than the copyWith method as it
  /// is reusing the [pixels] argument from the parent.
  VisualFrame copy() => VisualFrame(duration, pixels);

  VisualFrame copyWith({
    Duration? duration,
    List<Color>? pixels,
  }) =>
      VisualFrame(
        duration ?? this.duration,
        pixels ?? List.unmodifiable(this.pixels),
      );

  /// [(1)type][(2)duration][(ledsCount*3)pixels]
  @override
  int get size {
    const typeSize = 1;
    const durationSize = 2;
    final colorsSize = pixels.length * 3;
    return typeSize + durationSize + colorsSize;
  }

  static VisualFrame linearBlend(
    VisualFrame from,
    VisualFrame to,
    double progress, {
    Duration? duration,
  }) {
    VisualFrame.assertVisualFramesCompatibility(from, to);

    final pixels = [
      for (var i = 0; i < from.pixels.length; i++)
        Color.lerp(from.pixels[i], to.pixels[i], progress)
    ];

    return VisualFrame(duration ?? to.duration, pixels);
  }

  @override
  Uint8List toBytes([Endian endian = Endian.little]) {
    final writter = Writer(size, endian)
      ..writeFrameType(type)
      ..writeDuration(duration);

    /// frame pixels
    for (var i = 0; i < pixels.length; i++) {
      writter.writeColor(pixels[i]);
    }

    return writter.bytes;
  }

  factory VisualFrame.fromBytes(
    Uint8List bytes,
    int pixelsCount, [
    Endian endian = Endian.little,
  ]) {
    var offset = 0;
    if (bytes[offset] != FrameType.VisualFrame.value) {
      throw ArgumentError('Invalid frame type : ${bytes[offset]}');
    }

    final dataView = ByteData.view(bytes.buffer);
    final milliseconds = dataView.getUint16(++offset, endian);
    offset += 2;
    final pixels = List.filled(pixelsCount, Colors.black);

    /// frame pixels
    for (var i = 0; i < pixels.length; i++) {
      pixels[i] = Color.fromARGB(
        UINT_8_MAX_SIZE,
        bytes[offset++],
        bytes[offset++],
        bytes[offset++],
      );
    }

    return VisualFrame(Duration(milliseconds: milliseconds), pixels);
  }
}
