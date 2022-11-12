import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';

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

  factory AdditiveFrame.fromBytes(
    Uint8List bytes, [
    Endian endian = Endian.little,
  ]) {
    var offset = 0;

    final dataView = ByteData.view(bytes.buffer);
    final type = dataView.getUint8(offset++);
    if (type != FrameType.AdditiveFrame.value) {
      throw ArgumentError('Invalid frame type: $type');
    }
    final duration = Duration(milliseconds: dataView.getUint16(offset, endian));
    offset += 2;
    final changedPixelsCount = dataView.getUint16(offset, endian);
    offset += 2;

    final changedPixels = List<IndexedColor>.filled(
      changedPixelsCount,
      IndexedColor.zero,
    );
    for (var i = 0; i < changedPixels.length; i++) {
      final index = dataView.getUint16(offset, endian);
      offset += 2;
      changedPixels[i] = IndexedColor(
        index,
        Color.fromARGB(
          UINT_8_MAX_SIZE,
          dataView.getUint8(offset++),
          dataView.getUint8(offset++),
          dataView.getUint8(offset++),
        ),
      );
    }

    return AdditiveFrame(duration, changedPixels);
  }
}
