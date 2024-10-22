import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';

class RadioColorFrame extends RadioFrame {
  @override
  FrameType get type => FrameType.radioColor;

  final Color color;

  RadioColorFrame({
    required super.duration,
    required super.index,
    required this.color,
  });

  /// [(uint8)type][(uint16)duration][(uint8)panelIndex][(uint8)red][(uint8)green][(uint8)blue]
  @override
  int get size {
    const frameTypeSize = uint8SizeInBytes;
    const durationSize = uint16SizeInBytes;
    const panelIndexSize = uint8SizeInBytes;
    const redSize = uint8SizeInBytes;
    const greenSize = uint8SizeInBytes;
    const blueSize = uint8SizeInBytes;

    final size = (frameTypeSize +
        durationSize +
        panelIndexSize +
        redSize +
        greenSize +
        blueSize);

    return size;
  }

  /// Copy radio color frame instance
  RadioColorFrame copy() =>
      RadioColorFrame(duration: duration, index: index, color: color);

  @override
  RadioColorFrame copyWith({
    Duration? duration,
    int? index,
    Color? color,
  }) =>
      RadioColorFrame(
        duration: duration ?? this.duration,
        index: index ?? this.index,
        color: color ?? this.color,
      );

  @override
  Uint8List toBytes([Endian endian = Endian.little]) {
    final writer = Writer(size, endian)
      ..writeFrameType(type)
      ..writeDuration(duration)
      ..writeUint8(index)
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
      duration: reader.readDuration(),
      index: reader.readUint8(),
      color: reader.readColor(),
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
  int get hashCode => Object.hash(type, duration, index, color);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is RadioColorFrame &&
        other.type == type &&
        other.duration == duration &&
        other.index == index &&
        other.color == color;
  }
}
