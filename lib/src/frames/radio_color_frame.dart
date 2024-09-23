import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';

class RadioColorFrame extends Frame {
  static const maxPanelIndex = uint8MaxSize;
  static const broadcastChannelIndex = 0;

  @override
  FrameType get type => FrameType.radioColor;

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
    if (panelIndex.isNegative || panelIndex > uint8MaxSize) {
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
    const frameTypeSize = uint8SizeInBytes;
    const durationSize = uint16SizeInBytes;
    const panelIndexSize = uint8SizeInBytes;
    const redSize = uint8SizeInBytes;
    const greenSize = uint8SizeInBytes;
    const blueSize = uint8SizeInBytes;

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

  @override
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
    final writer = Writer(size, endian)
      ..writeFrameType(type)
      ..writeDuration(duration)
      ..writeUint8(panelIndex)
      ..writeColor(color);

    return writer.bytes;
  }

  /// When [withType] is set to true, type will be also read from the [reader].
  factory RadioColorFrame.fromReader(
    Reader reader, {
    bool withType = true,
  }) {
    if (withType) {
      final frameType = reader.readFrameType();
      if (frameType != FrameType.radioColor) {
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

  @override
  int get hashCode => Object.hash(type, duration, panelIndex, color);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is RadioColorFrame &&
        other.type == type &&
        other.duration == duration &&
        other.panelIndex == panelIndex &&
        other.color == color;
  }
}
