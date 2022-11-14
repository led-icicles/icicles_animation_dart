import 'dart:convert';
import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:icicles_animation_dart/src/utils/encodable.dart';

const NEWEST_ANIMATION_VERSION = 1;
const MIN_ANIMATION_VERSION = 1;

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
    this.versionNumber = NEWEST_ANIMATION_VERSION, // version
    required this.name,
    this.loopsCount = 1, //loops
    this.radioPanelsCount = 0,
  }) {
    if (xCount > UINT_8_MAX_SIZE) {
      throw ArgumentError('Only 255 leds in X axis are supported.');
    }
    if (yCount > UINT_8_MAX_SIZE) {
      throw ArgumentError('Only 255 leds in Y axis are supported.');
    }
    if (xCount <= 0) {
      throw ArgumentError('At least 1 led is required for X axis.');
    }
    if (yCount <= 0) {
      throw ArgumentError('At least 1 led is required for Y axis.');
    }

    if (radioPanelsCount > UINT_8_MAX_SIZE || radioPanelsCount < 0) {
      throw ArgumentError(
          'Value of radioPanelsCount must be between 0 and 255.');
    }

    if ((versionNumber < MIN_ANIMATION_VERSION ||
        versionNumber > NEWEST_ANIMATION_VERSION)) {
      throw ArgumentError('Unsupported version provided. '
          'Supported versions are in between: '
          '"$MIN_ANIMATION_VERSION" and "$NEWEST_ANIMATION_VERSION".');
    }

    if ((loopsCount < 0 || loopsCount > UINT_16_MAX_SIZE)) {
      throw ArgumentError('Unsupported loops count provided. '
          'Currently supported loops count is between "0" (for infinite/device maximum loops) and $UINT_16_MAX_SIZE.');
    }
  }

  int get ledsCount {
    return xCount * yCount;
  }

  int get size {
    /// NULL CHAR IS USED AS THE SEPARATOR

    const versionSize = UINT_16_SIZE_IN_BYTES;
    final animationNameSize =
        utf8.encode(name).length + NULL_CHAR_SIZE_IN_BYTES;
    const xCountSize = UINT_8_SIZE_IN_BYTES;
    const yCountSize = UINT_8_SIZE_IN_BYTES;
    const loopsSize = UINT_16_SIZE_IN_BYTES;
    const radioPanelsCountSize = UINT_8_SIZE_IN_BYTES;

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

  static Converter<String, List<int>> get encoder => utf8.encoder;
  static Converter<List<int>, String> get decoder => utf8.decoder;

  @override
  Uint8List toBytes([Endian endian = Endian.little]) {
    final writter = Writer(size, endian)
      ..writeUint16(versionNumber)
      ..writeString(name)
      ..writeUint8(NULL_CHAR)
      ..writeUint8(xCount)
      ..writeUint8(yCount)
      ..writeUint16(loopsCount)
      ..writeUint8(radioPanelsCount);

    return writter.bytes;
  }

  factory AnimationHeader.fromBytes(Uint8List bytes) {
    var offset = 0;

    final dataView = ByteData.view(bytes.buffer);
    final versionNumber = dataView.getUint16(
      offset,
      endian,
    );
    offset += UINT_16_SIZE_IN_BYTES;
    final nameEndIndex = bytes.indexOf(NULL_CHAR, offset);
    final nameBytes = bytes.getRange(offset, nameEndIndex).toList();
    final name = decoder.convert(nameBytes);

    offset = nameEndIndex + NULL_CHAR_SIZE_IN_BYTES;
    final xCount = dataView.getUint8(offset++);
    final yCount = dataView.getUint8(offset++);
    final loopsCount = dataView.getUint16(offset, endian);
    offset += UINT_16_SIZE_IN_BYTES;
    final radioPanelsCount = dataView.getUint8(offset++);

    return AnimationHeader(
      xCount: xCount,
      yCount: yCount,
      name: name,
      loopsCount: loopsCount,
      versionNumber: versionNumber,
      radioPanelsCount: radioPanelsCount,
    );
  }
}
