import 'dart:typed_data';

abstract class Encodable {
  Uint8List toBytes([Endian endian = Endian.little]);
}
