import 'dart:convert';
import 'dart:typed_data';

import 'package:icicles_animation_dart/src/utils/debug_log.dart';
import 'package:icicles_animation_dart/src/utils/size.dart';

const NEWEST_ANIMATION_VERSION = 1;
const MIN_ANIMATION_VERSION = 1;

abstract class AnimationHeaderData {
  String get name;
  int get xCount;
  int get yCount;
  int? get loopsCount;
  int? get versionNumber;
  int? get radioPanelsCount;
}

class AnimationHeader implements AnimationHeaderData {
  /// **uint16** max number: `65535` */
  @override
  final int versionNumber;

  /// utf-8 animation name */
  @override
  final String name;

  /// **uint8** max number: `255` */
  @override
  final int xCount;

  /// **uint8** max number: `255` */
  @override
  final int yCount;

  /// **uint16** max number: `65535`
  ///
  /// `0` - infinite (or device maximum loop iterations - if defined)
  ///
  /// `1` - is a default value
  @override
  final int loopsCount;

  /// **uint8** max number: `255`
  ///
  /// `0` - Animation does not support radio panels. All functionality will be disabled.
  ///     if panels are present, they will play inline animations.
  ///
  /// `1-255` - The radio panels will turn black at the start of the animation and wait for instructions.
  @override
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

  Uint8List _getEncodedAnimationNameV2() {
    var offset = 0;

    final bytes = Uint8List(size);
    final dataView = ByteData.view(bytes.buffer);

    dataView.setUint16(offset, versionNumber, endian);
    offset += UINT_16_SIZE_IN_BYTES;

    final encodedName = encoder.convert(name);
    bytes.setAll(offset, encodedName);
    offset += encodedName.length;

    bytes[offset++] = NULL_CHAR;
    dataView.setUint8(offset++, xCount);
    dataView.setUint8(offset++, yCount);
    dataView.setUint16(offset, loopsCount, endian);
    offset += UINT_16_SIZE_IN_BYTES;
    dataView.setUint8(offset++, radioPanelsCount);

    return bytes;
  }

  Uint8List toBytes() {
    return _getEncodedAnimationNameV2();
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
