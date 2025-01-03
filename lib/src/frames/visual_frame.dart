import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:icicles_animation_dart/icicles_animation_dart.dart';

/// This frame does not support opacity when converted to bytes
class VisualFrame extends Frame {
  @override
  FrameType get type => FrameType.visual;
  final List<Color> pixels;

  void _assertValidPixelIndex(int index) {
    if (index >= pixels.length || index < 0) {
      throw RangeError.index(
        index,
        pixels,
        'pixels',
        'Invalid pixel index provided ($index). Valid range is from "0" to "${pixels.length - 1}"',
      );
    }
  }

  /// Uses [header] configuration to transform the 2D [x], [y] coordinates into
  /// 1D pixel index which is used internally by this [VisualFrame].
  ///
  /// Throws the [RangeError] if the provided
  /// [x], [y] coordinates are out of range.
  int getPixelIndex(AnimationHeader header, int x, int y) {
    final index = x * header.yCount + y;
    _assertValidPixelIndex(index);
    return index;
  }

  List<Color> getColumn(AnimationHeader header, int x) =>
      List<Color>.generate(header.yCount, (y) => pixels[x * header.yCount + y]);

  List<Color> getRow(AnimationHeader header, int y) =>
      List<Color>.generate(header.xCount, (x) => pixels[x * header.yCount + y]);

  VisualFrame({
    required super.duration,
    required Iterable<Color> pixels,
  }) : pixels = List.unmodifiable(pixels);

  factory VisualFrame.filled(
    Duration duration,
    int pixels,
    Color color,
  ) {
    return VisualFrame(
      duration: duration,
      pixels: List.filled(pixels, color),
    );
  }

  /// Verify wether two visual frames are compatible.
  static void assertVisualFramesCompatibility(
    Frame prevFrame,
    Frame nextFrame,
  ) {
    if (prevFrame is! VisualFrame || nextFrame is! VisualFrame) {
      throw ArgumentError('Bad frame type.');
    } else if (prevFrame.size != nextFrame.size) {
      throw ArgumentError('Frames cannot have different sizes.');
    }
  }

  /// Copies visual frame.
  ///
  /// This is an alias for [copyWith] method without arguments.
  VisualFrame copy() => copyWith();

  /// Copy visual frame instance
  ///
  /// It reuses the [pixels] list as it is immutable.
  @override
  VisualFrame copyWith({
    Duration? duration,
    List<Color>? pixels,
  }) =>
      VisualFrame(
        duration: duration ?? this.duration,
        pixels: pixels ?? this.pixels,
      );

  /// [(1)type][(2)duration][(ledsCount*3)pixels]
  @override
  int get size {
    const typeSize = 1;
    const durationSize = 2;
    final colorsSize = pixels.length * 3;
    return typeSize + durationSize + colorsSize;
  }

  /// Blend [from] frame with [to] frame using [progress].
  ///
  /// The new frame will have the duration of [to] or [duration] if specified.
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

    return VisualFrame(duration: duration ?? to.duration, pixels: pixels);
  }

  @override
  Uint8List toBytes([Endian endian = Endian.little]) {
    final writer = Writer(size, endian)
      ..writeFrameType(type)
      ..writeDuration(duration)
      ..writeAllColors(pixels);

    return writer.bytes;
  }

  /// When [withType] is set to true, type will be also read from the [reader].
  factory VisualFrame.fromReader(
    Reader reader,
    int pixelsCount, {
    bool withType = true,
  }) {
    if (withType) {
      final frameType = reader.readFrameType();
      if (frameType != FrameType.visual) {
        throw ArgumentError('Invalid frame type : ${frameType.name}');
      }
    }

    final duration = reader.readDuration();

    final pixels = List<Color>.filled(pixelsCount, Colors.black);

    /// frame pixels
    for (var i = 0; i < pixels.length; i++) {
      pixels[i] = reader.readColor();
    }
    return VisualFrame(duration: duration, pixels: pixels);
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

  @override
  int get hashCode => Object.hash(
        type,
        duration,
        Object.hashAll(pixels),
      );

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is VisualFrame &&
        other.type == type &&
        other.duration == duration &&
        const ListEquality().equals(pixels, other.pixels);
  }
}
