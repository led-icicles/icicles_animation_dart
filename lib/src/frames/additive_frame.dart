import 'dart:typed_data';

import 'package:icicles_animation_dart/src/utils/color.dart';
import 'package:icicles_animation_dart/src/utils/size.dart';

import 'frame.dart';
import 'visual_frame.dart';

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
      VisualFrame prevFrame, VisualFrame nextFrame) {
    VisualFrame.assertVisualFramesCompatibility(prevFrame, nextFrame);

    final changedPixels = <IndexedColor>[];

    for (var index = 0; index < prevFrame.pixels.length; index++) {
      final prevPixel = prevFrame.pixels[index];
      final nextPixel = nextFrame.pixels[index];

      if (nextPixel != prevPixel) {
        final indexedColor = IndexedColor(index, nextPixel.value);
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

    return VisualFrame(duration, pixels);
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
    var dataPointer = 0;

    final data = Uint8List(size);

    /// frame header
    data[dataPointer++] = type.value;

    /// frame duration (little endian)
    data[dataPointer++] = duration.inMilliseconds & 255;
    data[dataPointer++] = duration.inMilliseconds >>> 8;

    /// frame size (little endian)
    final changedPixelsCount = changedPixels.length;
    data[dataPointer++] = changedPixelsCount & 255;
    data[dataPointer++] = changedPixelsCount >>> 8;

    /// frame pixels
    for (var i = 0; i < changedPixels.length; i++) {
      final changedPixel = changedPixels[i];
      final index = changedPixel.index;

      /// pixel index (little endian)
      data[dataPointer++] = index & 255;
      data[dataPointer++] = index >>> 8;

      final color = changedPixel;

      data[dataPointer++] = color.red;
      data[dataPointer++] = color.green;
      data[dataPointer++] = color.blue;
    }

    return data;
  }
}
