import 'dart:convert';
import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';

const newestAnimationVersion = 1;
const minAnimationVersion = 1;

class AnimationHeader implements Encodable {
  /// **uint16** max number: `65535` */
  final int versionNumber;

  /// utf-8 animation name */
  final String name;

  /// **uint8** max number: `255` */
  final int xCount;

  /// **uint8** max number: `255` */
  final int yCount;

  /// **uint16** max number: `65535`
  ///
  /// `0` - infinite (or device maximum loop iterations - if defined)
  ///
  /// `1` - is a default value
  final int loopsCount;

  /// **uint8** max number: `255`
  ///
  /// `0` - Animation does not support radio panels. All functionality will be disabled.
  ///     if panels are present, they will play inline animations.
  ///
  /// `1-255` - The radio panels will turn black at the start of the animation and wait for instructions.
  final int radioPanelsCount;

  int get pixelsCount {
    return xCount * yCount;
  }

  AnimationHeader({
    required this.xCount,
    required this.yCount,
    this.versionNumber = newestAnimationVersion, // version
    required this.name,
    this.loopsCount = 1, //loops
    this.radioPanelsCount = 0,
  }) {
    if (xCount > uint8MaxSize) {
      throw ArgumentError('Only 255 leds in X axis are supported.');
    }
    if (yCount > uint8MaxSize) {
      throw ArgumentError('Only 255 leds in Y axis are supported.');
    }
    if (xCount <= 0) {
      throw ArgumentError('At least 1 led is required for X axis.');
    }
    if (yCount <= 0) {
      throw ArgumentError('At least 1 led is required for Y axis.');
    }

    if (radioPanelsCount > uint8MaxSize || radioPanelsCount < 0) {
      throw ArgumentError('Value of radioPanelsCount must be between 0 and 255.');
    }

    if ((versionNumber < minAnimationVersion || versionNumber > newestAnimationVersion)) {
      throw ArgumentError('Unsupported version provided. '
          'Supported versions are in between: '
          '"$minAnimationVersion" and "$newestAnimationVersion".');
    }

    if ((loopsCount < 0 || loopsCount > uint16MaxSize)) {
      throw ArgumentError('Unsupported loops count provided. '
          'Currently supported loops count is between "0" (for infinite/device maximum loops) and $uint16MaxSize.');
    }
  }

  int get size {
    /// NULL CHAR IS USED AS THE SEPARATOR

    const versionSize = uint16SizeInBytes;
    final animationNameSize = utf8.encode(name).length + nullCharSizeInBytes;
    const xCountSize = uint8SizeInBytes;
    const yCountSize = uint8SizeInBytes;
    const loopsSize = uint16SizeInBytes;
    const radioPanelsCountSize = uint8SizeInBytes;

    return [
      versionSize,
      animationNameSize,
      xCountSize,
      yCountSize,
      loopsSize,
      radioPanelsCountSize,
    ].fold<int>(0, (a, b) => a + b);
  }

  /// encode type
  static Endian get endian => Endian.little;

  @override
  Uint8List toBytes([Endian endian = Endian.little]) {
    final writter = Writer(size, endian)
      ..writeUint16(versionNumber)
      ..writeString(name)
      ..writeUint8(xCount)
      ..writeUint8(yCount)
      ..writeUint16(loopsCount)
      ..writeUint8(radioPanelsCount);

    return writter.bytes;
  }

  /// When [withType] is set to true, type will be also read from the [reader].
  factory AnimationHeader.fromReader(Reader reader) {
    // Arguments are ordered and represents order of the encoded elements in memory
    return AnimationHeader(
      versionNumber: reader.readUint16(),
      name: reader.readString(),
      xCount: reader.readUint8(),
      yCount: reader.readUint8(),
      loopsCount: reader.readUint16(),
      radioPanelsCount: reader.readUint8(),
    );
  }

  factory AnimationHeader.fromBytes(
    Uint8List bytes, [
    Endian endian = Endian.little,
  ]) {
    return AnimationHeader.fromReader(Reader(bytes, endian));
  }
}
