import 'dart:typed_data';

import 'package:icicles_animation_dart/src/animation/animation_view.dart';
import 'package:icicles_animation_dart/src/frames/frame.dart';

import 'color.dart';

class Writer {
  final Endian endian;
  final Uint8List bytes;

  int _pointer = 0;
  int get pointer {
    return _pointer;
  }

  int get size {
    return bytes.length;
  }

  Writer(int size, this.endian) : bytes = Uint8List(size);

  void _assertSize(int index) {
    if (index >= size) {
      throw RangeError.index(index, bytes);
    }
  }

  void movePointer(int index) {
    _assertSize(index);
    _pointer = index;
  }

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

  void writeFrameType(FrameType type) {
    writeUint8(type.value);
  }

  void writeDuration(Duration duration) {
    writeUint16(duration.inMilliseconds);
  }

  void writeColor(Color color) {
    writeUint8(color.red);
    writeUint8(color.green);
    writeUint8(color.blue);
  }

  void writeColor565(Color color) {
    writeUint16(color.toRgb565());
  }

  void writeIndexedColor(IndexedColor color) {
    writeUint16(color.index);
    writeUint8(color.red);
    writeUint8(color.green);
    writeUint8(color.blue);
  }

  void writeIndexedColor565(IndexedColor color) {
    writeUint16(color.index);
    writeUint16(color.toRgb565());
  }

  void writeSerialMessageType(SerialMessageTypes type) {
    writeUint8(type.value);
  }
}
