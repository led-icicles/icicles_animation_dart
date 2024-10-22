import 'dart:convert';
import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';

enum AnimationVersion {
  v1(1),
  v2(2, supportsRadioVisualFrames: true),
  unsupported(-1);

  static const min = AnimationVersion.v1;
  static const max = AnimationVersion.v2;

  final int value;
  final bool supportsRadioVisualFrames;
  const AnimationVersion(this.value, {this.supportsRadioVisualFrames = false});

  factory AnimationVersion.fromValue(int value) {
    return AnimationVersion.values.firstWhere(
      (av) => av.value == value,
      orElse: () => AnimationVersion.unsupported,
    );
  }
}

class AnimationHeader implements Encodable {
  /// **Range**: `0` to `65535` (uint16 max value).
  final AnimationVersion version;

  /// utf-8 animation name */
  final String name;

  /// **Range**: `0` to `255` (uint8 max value).
  final int xCount;

  /// **Range**: `0` to `255` (uint8 max value).
  final int yCount;

  /// `0` - infinite (or device maximum loop iterations - if defined)
  ///
  /// `1` - is a default value
  ///
  /// **Range**: `0` to `65535` (uint16 max value).
  final int loopsCount;

  /// `0` - Animation does not support radio panels. All functionality will be disabled.
  ///     if panels are present, they will play inline animations.
  ///
  /// `1-255` - The radio panels will turn black at the start of the animation and wait for instructions.
  ///
  /// **Range**: `0` to `255` (uint8 max value).
  final int radioPanelsCount;

  /// The number of pixels in the panel, indicating how many colors it
  /// can display simultaneously.
  ///
  /// This value must be greater than `0`, as a panel cannot have zero pixels.
  ///
  /// **Range**: `1` to `255` (uint8 max value).
  final int radioPanelPixelCount;

  int get pixelsCount {
    return xCount * yCount;
  }

  AnimationHeader({
    required this.xCount,
    required this.yCount,
    this.version = AnimationVersion.v2, // version
    required this.name,
    this.loopsCount = 1, //loops
    this.radioPanelsCount = 0,
    this.radioPanelPixelCount = 1,
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
      throw ArgumentError(
          'Value of radioPanelsCount must be between 0 and 255.');
    }

    if (version == AnimationVersion.unsupported) {
      throw ArgumentError('Unsupported version provided. '
          'Supported versions are in between: '
          '"${AnimationVersion.min.name}" and "${AnimationVersion.max.name}".');
    }

    if ((loopsCount < 0 || loopsCount > uint16MaxSize)) {
      throw ArgumentError('Unsupported loops count provided. '
          'Currently supported loops count is between "0" (for infinite/device maximum loops) and $uint16MaxSize.');
    }

    if (radioPanelPixelCount == 0) {
      throw ArgumentError.value(
        radioPanelPixelCount,
        'radioPanelPixelCount',
        'At least 1 pixel is required for radio panel.',
      );
    }

    if (radioPanelPixelCount > uint8MaxSize || radioPanelPixelCount < 0) {
      throw ArgumentError(
        'Value must be between 0 and 255, provided: $radioPanelPixelCount',
        'radioPanelPixelCount',
      );
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
    const radioPanelPixelsCountSize = uint8SizeInBytes;

    return versionSize +
        animationNameSize +
        xCountSize +
        yCountSize +
        loopsSize +
        radioPanelsCountSize +
        (version.supportsRadioVisualFrames ? radioPanelPixelsCountSize : 0);
  }

  /// encode type
  static Endian get endian => Endian.little;

  @override
  Uint8List toBytes([Endian endian = Endian.little]) {
    final writer = Writer(size, endian)
      ..writeUint16(version.value)
      ..writeString(name)
      ..writeUint8(xCount)
      ..writeUint8(yCount)
      ..writeUint16(loopsCount)
      ..writeUint8(radioPanelsCount);

    if (version.supportsRadioVisualFrames) {
      writer.writeUint8(radioPanelPixelCount);
    }

    return writer.bytes;
  }

  /// When [withType] is set to true, type will be also read from the [reader].
  factory AnimationHeader.fromReader(Reader reader) {
    // Arguments are ordered and represents order of the encoded elements in memory
    final versionNumber = AnimationVersion.fromValue(reader.readUint16());
    return AnimationHeader(
      version: versionNumber,
      name: reader.readString(),
      xCount: reader.readUint8(),
      yCount: reader.readUint8(),
      loopsCount: reader.readUint16(),
      radioPanelsCount: reader.readUint8(),
      radioPanelPixelCount:
          versionNumber.supportsRadioVisualFrames ? reader.readUint8() : 1,
    );
  }

  factory AnimationHeader.fromBytes(
    Uint8List bytes, [
    Endian endian = Endian.little,
  ]) {
    return AnimationHeader.fromReader(Reader(bytes, endian));
  }
}
