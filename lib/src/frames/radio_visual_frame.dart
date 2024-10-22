import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:icicles_animation_dart/icicles_animation_dart.dart';

class RadioVisualFrame extends RadioFrame {
  @override
  FrameType get type => FrameType.radioVisualFrame;

  final List<Color> colors;

  RadioVisualFrame(
    super.duration,
    super.panelIndex,
    this.colors,
  );

  /// [(uint8)type][(uint16)duration][(uint8)panelIndex][(uint8)red][(uint8)green][(uint8)blue]
  @override
  int get size {
    const frameTypeSize = uint8SizeInBytes;
    const durationSize = uint16SizeInBytes;
    const panelIndexSize = uint8SizeInBytes;

    final colorsSize = uint8SizeInBytes * 3 * colors.length;

    final size = (frameTypeSize + durationSize + panelIndexSize + colorsSize);

    return size;
  }

  /// Return true when all colors stored inside the [RadioVisualFrame]
  /// are identical.
  bool checkAllColorsIdentical() {
    final firstColor = colors.first;
    return colors.every((color) => color == firstColor);
  }

  /// Copy radio color frame instance
  RadioVisualFrame copy() => RadioVisualFrame(duration, panelIndex, colors);

  @override
  RadioVisualFrame copyWith({
    Duration? duration,
    int? panelIndex,
    List<Color>? colors,
  }) =>
      RadioVisualFrame(
        duration ?? this.duration,
        panelIndex ?? this.panelIndex,
        colors ?? this.colors,
      );

  @override
  Uint8List toBytes([Endian endian = Endian.little]) {
    final writer = Writer(size, endian)
      ..writeFrameType(type)
      ..writeDuration(duration)
      ..writeUint8(panelIndex)
      ..writeAllColors(colors);

    return writer.bytes;
  }

  /// When [withType] is set to true, type will be also read from the [reader].
  factory RadioVisualFrame.fromReader(
    Reader reader,
    int colorsCount, {
    bool withType = true,
  }) {
    if (withType) {
      final frameType = reader.readFrameType();
      if (frameType != FrameType.radioVisualFrame) {
        throw ArgumentError('Invalid frame type : ${frameType.name}');
      }
    }

    return RadioVisualFrame(
      reader.readDuration(),
      reader.readUint8(),
      reader.readColors(colorsCount),
    );
  }

  factory RadioVisualFrame.fromBytes(
    Uint8List bytes,
    int colorsCount, [
    Endian endian = Endian.little,
  ]) {
    return RadioVisualFrame.fromReader(
      Reader(bytes, endian),
      colorsCount,
      withType: true,
    );
  }

  @override
  int get hashCode => Object.hash(
        type,
        duration,
        panelIndex,
        Object.hashAll(colors),
      );

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is RadioVisualFrame &&
        other.type == type &&
        other.duration == duration &&
        other.panelIndex == panelIndex &&
        const ListEquality().equals(colors, other.colors);
  }
}
