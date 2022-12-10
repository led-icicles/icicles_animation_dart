import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';

class DelayFrame extends Frame {
  @override
  final FrameType type = FrameType.DelayFrame;

  DelayFrame(super.duration);

  /// [(1)type][(2)duration]
  @override
  int get size {
    const headerSize = 1;
    const durationSize = 2;
    return headerSize + durationSize;
  }

  @override
  Uint8List toBytes([Endian endian = Endian.little]) {
    final writter = Writer(size, endian)
      ..writeFrameType(type)
      ..writeDuration(duration);

    return writter.bytes;
  }

  /// When [withType] is set to true, type will be also read from the [reader].
  factory DelayFrame.fromReader(
    Reader reader, {
    bool withType = true,
  }) {
    if (withType) {
      final frameType = reader.readFrameType();
      if (frameType != FrameType.DelayFrame) {
        throw ArgumentError('Invalid frame type : ${frameType.name}');
      }
    }
    return DelayFrame(reader.readDuration());
  }

  factory DelayFrame.fromBytes(
    Uint8List bytes, [
    Endian endian = Endian.little,
  ]) {
    return DelayFrame.fromReader(
      Reader(bytes, endian),
      withType: true,
    );
  }

  @override
  DelayFrame copyWith({
    Duration? duration,
  }) =>
      DelayFrame(duration ?? this.duration);
}
