import 'dart:typed_data';

import 'package:icicles_animation_dart/src/utils/color.dart';

import '../utils/size.dart';
import 'frame.dart';

class RadioColorFrame extends Frame {
  static const maxPanelIndex = UINT_8_MAX_SIZE;
  @override
  FrameType get type => FrameType.RadioColorFrame;

  final int panelIndex;
  final Color color;

  bool get isBroadcast {
    return panelIndex == 0;
  }

  RadioColorFrame(
    super.duration,
    this.panelIndex,
    this.color,
  ) {
    if (panelIndex.isNegative || panelIndex > UINT_8_MAX_SIZE) {
      throw ArgumentError(
          'Not valid panel index provided. Panel index should be larger or equal 0 (for broadcast) and smaller than [RadioColorFrame.maxPanelIndex].');
    }
  }

  /// [(uint8)type][(uint16)duration][(uint8)panelIndex][(uint8)red][(uint8)green][(uint8)blue]
  @override
  int get size {
    const frameTypeSize = UINT_8_SIZE_IN_BYTES;
    const durationSize = UINT_16_SIZE_IN_BYTES;
    const panelIndexSize = UINT_8_SIZE_IN_BYTES;
    const redSize = UINT_8_SIZE_IN_BYTES;
    const greenSize = UINT_8_SIZE_IN_BYTES;
    const blueSize = UINT_8_SIZE_IN_BYTES;

    const size = (frameTypeSize +
        durationSize +
        panelIndexSize +
        redSize +
        greenSize +
        blueSize);

    return size;
  }

  /// Copy radio color frame instance
  RadioColorFrame copy() => RadioColorFrame(duration, panelIndex, color);

  RadioColorFrame copyWith({
    Duration? duration,
    int? panelIndex,
    Color? color,
  }) =>
      RadioColorFrame(
        duration ?? this.duration,
        panelIndex ?? this.panelIndex,
        color ?? this.color,
      );

  @override
  Uint8List toBytes([Endian endian = Endian.little]) {
    var dataPointer = 0;

    final bytes = Uint8List(size);
    final dataView = ByteData.view(bytes.buffer);

    /// frame type
    dataView.setUint8(dataPointer++, type.value);

    /// frame duration (little endian)
    dataView.setUint16(dataPointer, duration.inMilliseconds, endian);
    dataPointer += 2;
    // bytes[dataPointer++] = this.duration & 255;
    // bytes[dataPointer++] = this.duration >>> 8;
    /// panel index
    dataView.setUint8(dataPointer++, panelIndex);

    /// color
    dataView
      ..setUint8(dataPointer++, color.red)
      ..setUint8(dataPointer++, color.green)
      ..setUint8(dataPointer++, color.blue);

    return bytes;
  }

  @override
  factory RadioColorFrame.fromBytes(
    Uint8List bytes, [
    Endian endian = Endian.little,
  ]) {
    var offset = 0;

    final dataView = ByteData.view(bytes.buffer);
    final type = dataView.getUint8(offset++);

    if (type != FrameType.RadioColorFrame.value) {
      throw ArgumentError('Invalid frame type : $type');
    }

    final duration = Duration(milliseconds: dataView.getUint16(offset, endian));
    offset += 2;

    final panelIndex = dataView.getUint8(offset++);
    final color = Color.fromARGB(
      UINT_8_MAX_SIZE,
      dataView.getUint8(offset++),
      dataView.getUint8(offset++),
      dataView.getUint8(offset++),
    );

    return RadioColorFrame(duration, panelIndex, color);
  }
}
