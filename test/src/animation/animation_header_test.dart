import 'dart:io';

import 'package:icicles_animation_dart/src/animation/animation_header.dart';
import 'package:test/test.dart';

void main() {
  test('AnimationHeader - v1 - Encode and decode', () async {
    final name = 'Example: żółć';
    final version = AnimationVersion.v1;
    const xCount = 20;
    const yCount = 30;
    const radioPanelsCount = 2;
    const loopsCount = 2;

    final header = AnimationHeader(
      name: name,
      version: version,
      xCount: xCount,
      yCount: yCount,
      radioPanelsCount: radioPanelsCount,
      loopsCount: loopsCount,
    );

    final encoded = header.toBytes();

    final decodedHeader = AnimationHeader.fromBytes(encoded);
    expect(decodedHeader.name, equals(name));
    expect(decodedHeader.version, equals(version));
    expect(decodedHeader.xCount, equals(xCount));
    expect(decodedHeader.yCount, equals(yCount));
    expect(decodedHeader.radioPanelsCount, equals(radioPanelsCount));
    expect(decodedHeader.loopsCount, equals(loopsCount));
  });

  test('AnimationHeader - v2 - Encode and decode', () async {
    final name = 'Example: żółć';
    final version = AnimationVersion.v2;
    const xCount = 20;
    const yCount = 30;
    const radioPanelsCount = 2;
    const loopsCount = 2;

    final header = AnimationHeader(
      name: name,
      version: version,
      xCount: xCount,
      yCount: yCount,
      radioPanelsCount: radioPanelsCount,
      loopsCount: loopsCount,
    );

    final encoded = header.toBytes();

    final decodedHeader = AnimationHeader.fromBytes(encoded);
    expect(decodedHeader.name, equals(name));
    expect(decodedHeader.version, equals(version));
    expect(decodedHeader.xCount, equals(xCount));
    expect(decodedHeader.yCount, equals(yCount));
    expect(decodedHeader.radioPanelsCount, equals(radioPanelsCount));
    expect(decodedHeader.loopsCount, equals(loopsCount));
  });

  test('AnimationHeader - icicle_animation_js file compatibility', () async {
    final animation = File('test/data/darkening.anim');
    final bytes = await animation.readAsBytes();

    final decodedHeader = AnimationHeader.fromBytes(bytes);
    expect(decodedHeader.name, equals('Darkening'));
    expect(decodedHeader.version, equals(AnimationVersion.v1));
    expect(decodedHeader.xCount, equals(20));
    expect(decodedHeader.yCount, equals(30));
    expect(decodedHeader.radioPanelsCount, equals(2));
    expect(decodedHeader.loopsCount, equals(2));
  });
}
