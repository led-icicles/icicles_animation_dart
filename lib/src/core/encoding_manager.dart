import 'dart:convert';
import 'dart:typed_data';

import 'package:icicles_animation_dart/src/animation/animation_view.dart';
import 'package:icicles_animation_dart/src/core/core.dart';
import 'package:icicles_animation_dart/src/frames/frame.dart';

abstract class EncodingManager {
  Endian get endian;
  Uint8List get bytes;
  int _pointer = 0;
  int get pointer {
    return _pointer;
  }

  int get size {
    return bytes.length;
  }

  bool get hasMoreData => pointer < bytes.length;

  void _assertSize(int index) {
    if (index >= size) {
      throw RangeError.index(index, bytes);
    }
  }

  void movePointer(int index) {
    _assertSize(index);
    _pointer = index;
  }
}

class Writer extends EncodingManager {
  @override
  final Endian endian;
  @override
  final Uint8List bytes;

  Writer(int size, this.endian) : bytes = Uint8List(size);

  void writeUint8(int value) {
    bytes[_pointer++] = value;
  }

  void writeUint16(int value) {
    if (endian == Endian.little) {
      bytes[_pointer++] = value & 255;
      bytes[_pointer++] = value >>> 8;
    } else {
      bytes[_pointer++] = value >>> 8;
      bytes[_pointer++] = value & 255;
    }
  }

  void writeBytes(List<int> encoded) {
    bytes.setAll(_pointer, encoded);
    _pointer += encoded.length;
  }

  void writeFrameType(FrameType type) {
    writeUint8(type.value);
  }

  void writeDuration(Duration duration) {
    writeUint16(duration.inMilliseconds);
  }

  /// If a [color] has an opacity, it is converted to its opaque
  /// representation by blending [color] with the black.
  ///
  /// Color occupies 24bits in the [bytes] array
  void writeColor(Color color) {
    final encodedColor =
        color.isOpaque ? Color.alphaBlend(color, Colors.black) : color;

    writeUint8(encodedColor.red);
    writeUint8(encodedColor.green);
    writeUint8(encodedColor.blue);
  }

  /// Write all colors
  void writeAllColors(Iterable<Color> colors) {
    for (final color in colors) {
      writeColor(color);
    }
  }

  /// Converts the color to rgb565 and writes it.
  void writeColor565(Color color) {
    writeUint16(color.toRgb565());
  }

  /// Encode all colors to rgb565 and write.
  void writeAllColors565(Iterable<Color> colors) {
    for (final color in colors) {
      writeColor565(color);
    }
  }

  /// Uses the [writeColor] method, but an additional color index is written
  void writeIndexedColor(IndexedColor color) {
    writeUint16(color.index);
    writeColor(color);
  }

  void writeIndexedColor565(IndexedColor color) {
    writeUint16(color.index);
    writeUint16(color.toRgb565());
  }

  void writeSerialMessageType(SerialMessageTypes type) {
    writeUint8(type.value);
  }

  void writeString(
    String value, [
    Converter<String, List<int>> encoder = const Utf8Encoder(),
  ]) {
    final encoded = encoder.convert(value);
    writeBytes(encoded);
    writeUint8(nullChar);
  }

  void writeEncodable(Encodable encodable) {
    final encoded = encodable.toBytes(endian);
    writeBytes(encoded);
  }

  void writeAllEncodable(Iterable<Encodable> encodables) {
    for (final encodable in encodables) {
      writeEncodable(encodable);
    }
  }
}

class Reader extends EncodingManager {
  @override
  final Endian endian;
  @override
  final Uint8List bytes;

  Reader(this.bytes, this.endian);

  int readUint8() {
    return bytes[_pointer++];
  }

  int readUint16() {
    if (endian == Endian.little) {
      return readUint8() + readUint8() * 256;
    } else {
      return readUint8() * 256 + readUint8();
    }
  }

  FrameType readFrameType() {
    return FrameType.fromValue(readUint8());
  }

  Duration readDuration() {
    return Duration(milliseconds: readUint16());
  }

  Color readColor() {
    return Color.fromRGB(readUint8(), readUint8(), readUint8());
  }

  Color readColor565() {
    final encoded = readUint16();
    final r5 = (encoded >> 11) & 0x1f;
    final g6 = (encoded >> 5) & 0x3f;
    final b5 = encoded & 0x1f;

    final r8 = (r5 * 527 + 23) >> 6;
    final g8 = (g6 * 259 + 33) >> 6;
    final b8 = (b5 * 527 + 23) >> 6;
    return Color.fromRGB(r8, g8, b8);
  }

  IndexedColor readIndexedColor() {
    return IndexedColor(readUint16(), readColor());
  }

  IndexedColor readIndexedColor565() {
    return IndexedColor(readUint16(), readColor565());
  }

  String readString([
    Converter<List<int>, String> decoder = const Utf8Decoder(),
  ]) {
    final endIndex = bytes.indexOf(nullChar, pointer);
    final encodedString = Uint8List.sublistView(bytes, pointer, endIndex);

    final decodedString = decoder.convert(encodedString);

    // Adding 1 additional character in order to skip the [NULL_CHAR].
    // It is important to add [encodedString] length as decoded can have a
    // different length.
    _pointer += encodedString.length + 1;
    return decodedString;
  }
}
