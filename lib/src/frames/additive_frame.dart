import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:icicles_animation_dart/src/frames/additive_frame_rgb565.dart';

class AdditiveFrame extends Frame {
  @override
  FrameType get type => FrameType.additive;
  static const maxChangedPixelIndex = uint16MaxSize;
  final List<IndexedColor> changedPixels;

  AdditiveFrame({
    required super.duration,
    required List<IndexedColor> changedPixels,
  }) : changedPixels = List.unmodifiable(changedPixels) {
    if (changedPixels.length > AdditiveFrame.maxChangedPixelIndex) {
      throw ArgumentError(
          'Provided more changed pixels than maximum allowed. Check [AdditiveFrame.maxChangedPixelIndex].');
    }
  }

  static List<IndexedColor> getChangedPixelsFromFrames(
    VisualFrame prevFrame,
    VisualFrame nextFrame,
  ) {
    VisualFrame.assertVisualFramesCompatibility(prevFrame, nextFrame);

    final changedPixels = <IndexedColor>[];

    for (var index = 0; index < prevFrame.pixels.length; index++) {
      final prevPixel = prevFrame.pixels[index];
      final nextPixel = nextFrame.pixels[index];

      if (nextPixel != prevPixel) {
        final indexedColor = IndexedColor(index, nextPixel);
        changedPixels.add(indexedColor);
      }
    }

    return changedPixels;
  }

  VisualFrame mergeOnto(VisualFrame frame) {
    final pixels = List.of(frame.pixels);

    for (final changedPixel in changedPixels) {
      // transform to color, we do not want to keep indexed colors in the visual frame
      pixels[changedPixel.index] = changedPixel.toColor();
    }

    if (frame is VisualFrameRgb565) {
      return VisualFrameRgb565(duration: duration, pixels: pixels);
    } else {
      return VisualFrame(duration: duration, pixels: pixels);
    }
  }

  /// The provided [frame] is placed **over** the current frame.
  ///
  /// If the this frame is [AdditiveFrameRgb565] the returned frame
  /// will also be the [AdditiveFrameRgb565] - The returned frame will be
  /// same type as this.
  AdditiveFrame mergeWith(AdditiveFrame frame) {
    final pixels = <int, IndexedColor>{
      for (final color in changedPixels) color.index: color,
      for (final color in frame.changedPixels) color.index: color,
    }.values.toList();

    if (this is AdditiveFrameRgb565) {
      return AdditiveFrameRgb565(duration: duration, changedPixels: pixels);
    } else {
      return AdditiveFrame(duration: duration, changedPixels: pixels);
    }
  }

  factory AdditiveFrame.fromVisualFrames(
    VisualFrame prevFrame,
    VisualFrame nextFrame,
  ) {
    final changedPixels = AdditiveFrame.getChangedPixelsFromFrames(
      prevFrame,
      nextFrame,
    );

    return AdditiveFrame(
      duration: nextFrame.duration,
      changedPixels: changedPixels,
    );
  }

  // [(1 - uint8)type][(2 - uint16)duration][(2 - uint16)size][(x * 5)changedPixels]
  @override
  int get size {
    const typeSize = 1;
    const durationSize = 2;
    const sizeFieldSize = 2;
    // [(2 - uint16)pixel_index][(1 -uint8)red][(1 -uint8)green][(1 -uint8)blue]
    final changedPixelsSize = changedPixels.length * 5;
    return typeSize + durationSize + sizeFieldSize + changedPixelsSize;
  }

  @override
  Uint8List toBytes([Endian endian = Endian.little]) {
    final writer = Writer(size, endian)
      ..writeFrameType(type)
      ..writeDuration(duration)
      ..writeUint16(changedPixels.length);

    /// frame pixels
    for (var i = 0; i < changedPixels.length; i++) {
      writer.writeIndexedColor(changedPixels[i]);
    }

    return writer.bytes;
  }

  /// When [withType] is set to true, type will be also read from the [reader].
  factory AdditiveFrame.fromReader(
    Reader reader, {
    bool withType = true,
  }) {
    if (withType) {
      final frameType = reader.readFrameType();
      if (frameType != FrameType.additive) {
        throw ArgumentError('Invalid frame type : ${frameType.name}');
      }
    }

    final duration = reader.readDuration();
    final changedPixelsCount = reader.readUint16();

    final changedPixels = List<IndexedColor>.generate(
      changedPixelsCount,
      (_) => reader.readIndexedColor(),
    );

    return AdditiveFrame(duration: duration, changedPixels: changedPixels);
  }

  factory AdditiveFrame.fromBytes(
    Uint8List bytes, [
    Endian endian = Endian.little,
  ]) {
    return AdditiveFrame.fromReader(
      Reader(bytes, endian),
      withType: true,
    );
  }

  AdditiveFrame copy() => copyWith();

  @override
  AdditiveFrame copyWith({
    Duration? duration,
    List<IndexedColor>? changedPixels,
  }) =>
      AdditiveFrame(
        duration: duration ?? this.duration,
        changedPixels: changedPixels ?? this.changedPixels,
      );

  @override
  int get hashCode => Object.hash(
        type,
        duration,
        Object.hashAllUnordered(changedPixels),
      );

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is AdditiveFrame &&
        other.type == type &&
        other.duration == duration &&
        const UnorderedIterableEquality()
            .equals(changedPixels, other.changedPixels);
  }
}
