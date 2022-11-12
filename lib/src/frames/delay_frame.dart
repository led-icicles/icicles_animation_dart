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

  factory DelayFrame.fromBytes(
    Uint8List bytes, [
    Endian endian = Endian.little,
  ]) {
    var offset = 0;

    final dataView = ByteData.view(bytes.buffer);

    final type = dataView.getUint8(offset++);

    if (type != FrameType.DelayFrame.value) {
      throw ArgumentError('Invalid frame type: $type');
    }

    final milliseconds = dataView.getUint16(offset, endian);

    return DelayFrame(Duration(milliseconds: milliseconds));
  }
}
