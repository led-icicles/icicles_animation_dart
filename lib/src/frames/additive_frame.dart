import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:icicles_animation_dart/src/frames/additive_frame_rgb565.dart';

class AdditiveFrame extends Frame {
  @override
  FrameType get type => FrameType.AdditiveFrame;
  static const maxChangedPixelIndex = UINT_16_MAX_SIZE;
  final List<IndexedColor> changedPixels;

  AdditiveFrame(
    super.duration,
    this.changedPixels,
  ) {
    if (changedPixels.length > AdditiveFrame.maxChangedPixelIndex) {
      throw ArgumentError(
          'Provided more chnaged pixels than maximum allowed. Check [AdditiveFrame.maxChangedPixelIndex].');
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
      return VisualFrameRgb565(duration, pixels);
    } else {
      return VisualFrame(duration, pixels);
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
      return AdditiveFrameRgb565(duration, pixels);
    } else {
      return AdditiveFrame(duration, pixels);
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

    return AdditiveFrame(nextFrame.duration, changedPixels);
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
    final writter = Writer(size, endian)
      ..writeFrameType(type)
      ..writeDuration(duration)
      ..writeUint16(changedPixels.length);

    /// frame pixels
    for (var i = 0; i < changedPixels.length; i++) {
      writter.writeIndexedColor(changedPixels[i]);
    }

    return writter.bytes;
  }

  /// When [withType] is set to true, type will be also read from the [reader].
  factory AdditiveFrame.fromReader(
    Reader reader, {
    bool withType = true,
  }) {
    if (withType) {
      final frameType = reader.readFrameType();
      if (frameType != FrameType.AdditiveFrame) {
        throw ArgumentError('Invalid frame type : ${frameType.name}');
      }
    }

    final duration = reader.readDuration();
    final changedPixelsCount = reader.readUint16();

    final changedPixels = List<IndexedColor>.generate(
      changedPixelsCount,
      (_) => reader.readIndexedColor(),
    );

    return AdditiveFrame(duration, changedPixels);
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

  @override
  AdditiveFrame copyWith({
    Duration? duration,
    List<IndexedColor>? changedPixels,
  }) =>
      AdditiveFrame(
        duration ?? this.duration,
        changedPixels ?? this.changedPixels,
      );

  @override
  List<Object?> get props => [type, duration, changedPixels];
}
