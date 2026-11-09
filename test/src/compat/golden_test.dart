import 'dart:io';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:test/test.dart';

import 'compat_helpers.dart';

/// Fixtures: `UPDATE_GOLDEN=1 dart test test/src/compat/golden_test.dart`.
void main() {
  final update = Platform.environment['UPDATE_GOLDEN'] == '1';

  group('golden', () {
    for (final scenario in scenarios) {
      test(scenario.name, () async {
        final animation = scenario.build();
        final bytes = animation.toBytes();

        final tmp = await Directory.systemTemp.createTemp('icicles_golden');
        try {
          final file =
              await animation.toFile('${tmp.path}/${scenario.name}.anim');
          expect(await file.readAsBytes(), orderedEquals(bytes),
              reason: 'toFile() must write the same bytes as toBytes()');
        } finally {
          await tmp.delete(recursive: true);
        }

        final fixture = File('test/data/golden/${scenario.name}.anim');
        if (update) {
          await fixture.create(recursive: true);
          await fixture.writeAsBytes(bytes);
          return;
        }

        final golden = await fixture.readAsBytes();
        final goldenWalk = walkAnimation(animation, golden);
        final currentWalk = walkAnimation(animation, bytes);

        expect(
          currentWalk.frames.map((f) => f.toString()),
          orderedEquals(goldenWalk.frames.map((f) => f.toString())),
          reason: 'frame structure must not change',
        );
        expect(bytes.length, golden.length);

        if (!scenario.hasTranslucentColors) {
          expect(bytes, orderedEquals(golden));
          return;
        }

        final changedNonColorBytes = [
          for (var i = 0; i < bytes.length; i++)
            if (!goldenWalk.colorBytes[i] && bytes[i] != golden[i]) i
        ];
        expect(changedNonColorBytes, isEmpty,
            reason: 'only color bytes may change');
        expect(bytes, orderedEquals(encodePreBlended(animation)),
            reason: 'translucent colors must be encoded blended with black');
      });
    }
  });

  test('darkening.anim: decode + encode is byte-identical and walks to EOF',
      () async {
    final original = await File('test/data/darkening.anim').readAsBytes();
    final animation = Animation.fromBytes(original);
    expect(animation.toBytes(), orderedEquals(original));
    final walked = walkAnimation(animation, original);
    expect(walked.frames.length, animation.frameCount);
  });
}
