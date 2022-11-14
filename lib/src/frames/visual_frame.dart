import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';

/// This frame does not support opacity when converted to bytes
class VisualFrame extends Frame {
  @override
  FrameType get type => FrameType.VisualFrame;
  final List<Color> pixels;

  void _isValidIndex(int index) {
    if (index >= pixels.length || index < 0) {
      throw RangeError.index(
        index,
        pixels,
        'pixels',
        'Invalid pixel index provided ($index). Valid range is from "0" to "${pixels.length - 1}"',
      );
    }
  }

  int getPixelIndex(AnimationHeader header, int x, int y) {
    final index = x * header.yCount + y;
    _isValidIndex(index);
    return index;
  }

  List<Color> getColumn(AnimationHeader header, int x) =>
      List<Color>.generate(header.yCount, (y) => pixels[x * header.yCount + y]);

  List<Color> getRow(AnimationHeader header, int y) =>
      List<Color>.generate(header.xCount, (x) => pixels[x * header.yCount + y]);

  VisualFrame(
    super.duration,
    List<Color> pixels,
  ) : pixels = List.unmodifiable(pixels);

  factory VisualFrame.filled(
    Duration duration,
    int pixels,
    Color color,
  ) {
    return VisualFrame(
      duration,
      List.filled(pixels, color),
    );
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
        Color.linearBlend(from.pixels[i], to.pixels[i], progress)
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

  /// When [withType] is set to true, type will be also read from the [reader].
  factory VisualFrame.fromReader(
    Reader reader,
    int pixelsCount, {
    bool withType = true,
  }) {
    if (withType) {
      final frameType = reader.readFrameType();
      if (frameType != FrameType.VisualFrame) {
        throw ArgumentError('Invalid frame type : ${frameType.name}');
      }
    }

    final duration = reader.readDuration();

    final pixels = List<Color>.filled(pixelsCount, Colors.black);

    /// frame pixels
    for (var i = 0; i < pixels.length; i++) {
      pixels[i] = reader.readColor();
    }
    return VisualFrame(duration, pixels);
  }

  factory VisualFrame.fromBytes(
    Uint8List bytes,
    int pixelsCount, [
    Endian endian = Endian.little,
  ]) {
    return VisualFrame.fromReader(
      Reader(bytes, endian),
      pixelsCount,
      withType: true,
    );
  }
}
