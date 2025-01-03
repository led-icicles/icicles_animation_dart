import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';

class AdditiveFrameRgb565 extends AdditiveFrame {
  @override
  final FrameType type = FrameType.additiveRgb565;

  // [(1 - uint8)type][(2 - uint16)duration][(2 - uint16)size][(x * 5)changedPixels]
  @override
  int get size {
    const typeSize = 1;
    const durationSize = 2;
    const sizeFieldSize = 2;
    final changedPixelsSize = changedPixels.length * 4;
    return typeSize + durationSize + sizeFieldSize + changedPixelsSize;
  }

  AdditiveFrameRgb565({
    required super.duration,
    required super.changedPixels,
  });

  factory AdditiveFrameRgb565.fromAdditiveFrame(AdditiveFrame frame) {
    return AdditiveFrameRgb565(
      duration: frame.duration,
      changedPixels: frame.changedPixels,
    );
  }

  AdditiveFrame toAdditiveFrame() => AdditiveFrameRgb565(
        duration: duration,
        changedPixels: changedPixels,
      );

  @override
  Uint8List toBytes([Endian endian = Endian.little]) {
    final writer = Writer(size, endian)
      ..writeFrameType(type)
      ..writeDuration(duration)
      ..writeUint16(changedPixels.length);

    /// frame pixels
    for (var i = 0; i < changedPixels.length; i++) {
      writer.writeIndexedColor565(changedPixels[i]);
    }

    return writer.bytes;
  }

  /// When [withType] is set to true, type will be also read from the [reader].
  factory AdditiveFrameRgb565.fromReader(
    Reader reader, {
    bool withType = true,
  }) {
    if (withType) {
      final frameType = reader.readFrameType();
      if (frameType != FrameType.additiveRgb565) {
        throw ArgumentError('Invalid frame type : ${frameType.name}');
      }
    }

    final duration = reader.readDuration();
    final changedPixelsCount = reader.readUint16();

    final changedPixels = List<IndexedColor>.generate(
      changedPixelsCount,
      (_) => reader.readIndexedColor565(),
    );

    return AdditiveFrameRgb565(
      duration: duration,
      changedPixels: changedPixels,
    );
  }

  factory AdditiveFrameRgb565.fromBytes(
    Uint8List bytes, [
    Endian endian = Endian.little,
  ]) {
    return AdditiveFrameRgb565.fromReader(
      Reader(bytes, endian),
      withType: true,
    );
  }

  @override
  AdditiveFrameRgb565 copyWith({
    Duration? duration,
    List<IndexedColor>? changedPixels,
  }) =>
      AdditiveFrameRgb565(
        duration: duration ?? this.duration,
        changedPixels: changedPixels ?? this.changedPixels,
      );
}
