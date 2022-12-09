import 'dart:html';
import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';

class RadioColorFrame extends Frame {
  static const maxPanelIndex = UINT_8_MAX_SIZE;
  static const broadcastChannelIndex = 0;

  @override
  FrameType get type => FrameType.RadioColorFrame;

  /// Panel index.
  /// `0` - Stands for the broadcast (all panels). This is also described by the
  /// [RadioColorFrame.broadcastChannelIndex] constant. Take a look at the
  /// [isBroadcast] getter.
  ///
  /// Panel index cannot be larger than [RadioColorFrame.maxPanelIndex].
  final int panelIndex;
  final Color color;

  bool get isBroadcast {
    return panelIndex == broadcastChannelIndex;
  }

  RadioColorFrame(
    super.duration,
    this.panelIndex,
    this.color,
  ) {
    if (panelIndex.isNegative || panelIndex > UINT_8_MAX_SIZE) {
      throw ArgumentError(
        'Not valid panel index provided. '
        'Panel index should be larger or equal 0 (for broadcast) '
        'and smaller than [RadioColorFrame.maxPanelIndex].',
      );
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
    final writter = Writer(size, endian)
      ..writeFrameType(type)
      ..writeDuration(duration)
      ..writeUint8(panelIndex)
      ..writeColor(color);

    return writter.bytes;
  }

  /// When [withType] is set to true, type will be also read from the [reader].
  factory RadioColorFrame.fromReader(
    Reader reader, {
    bool withType = true,
  }) {
    if (withType) {
      final frameType = reader.readFrameType();
      if (frameType != FrameType.RadioColorFrame) {
        throw ArgumentError('Invalid frame type : ${frameType.name}');
      }
    }

    return RadioColorFrame(
      reader.readDuration(),
      reader.readUint8(),
      reader.readColor(),
    );
  }

  factory RadioColorFrame.fromBytes(
    Uint8List bytes, [
    Endian endian = Endian.little,
  ]) {
    return RadioColorFrame.fromReader(
      Reader(bytes, endian),
      withType: true,
    );
  }
}
