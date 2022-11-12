import 'dart:typed_data';

import 'frame.dart';

class DelayFrame extends Frame {
  @override
  FrameType type = FrameType.DelayFrame;

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
    var dataPointer = 0;

    final data = Uint8List(size);
    final dataView = ByteData.view(data.buffer);

    /// frame header
    dataView

      /// frame type
      ..setUint8(dataPointer++, type.value)

      /// frame duration
      ..setUint16(dataPointer++, duration.inMilliseconds, endian);

    return data;
  }

  factory DelayFrame.fromBytes(
    Uint8List list, [
    Endian endian = Endian.little,
  ]) {
    var offset = 0;
    if (list[offset] != FrameType.DelayFrame.value) {
      throw ArgumentError('Invalid frame type : ${list[offset]}');
    }

    final dataView = ByteData.view(list.buffer);
    final milliseconds = dataView.getUint16(++offset, endian);

    return DelayFrame(Duration(milliseconds: milliseconds));
  }
}
