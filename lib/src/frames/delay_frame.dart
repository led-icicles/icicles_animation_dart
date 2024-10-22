import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';

class DelayFrame extends Frame {
  @override
  final FrameType type = FrameType.delay;

  DelayFrame({
    required super.duration,
  });

  DelayFrame.fromFrame(Frame frame) : super(duration: frame.duration);

  /// [(1)type][(2)duration]
  @override
  int get size {
    const headerSize = 1;
    const durationSize = 2;
    return headerSize + durationSize;
  }

  @override
  Uint8List toBytes([Endian endian = Endian.little]) {
    final writer = Writer(size, endian)
      ..writeFrameType(type)
      ..writeDuration(duration);

    return writer.bytes;
  }

  /// When [withType] is set to true, type will be also read from the [reader].
  factory DelayFrame.fromReader(
    Reader reader, {
    bool withType = true,
  }) {
    if (withType) {
      final frameType = reader.readFrameType();
      if (frameType != FrameType.delay) {
        throw ArgumentError('Invalid frame type : ${frameType.name}');
      }
    }
    return DelayFrame(duration: reader.readDuration());
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
      DelayFrame(duration: duration ?? this.duration);

  @override
  int get hashCode => Object.hash(type, duration);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is DelayFrame &&
        other.type == type &&
        other.duration == duration;
  }
}
