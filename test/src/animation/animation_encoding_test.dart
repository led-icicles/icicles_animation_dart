import 'package:collection/collection.dart';
import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:test/test.dart';

void main() {
  test('Animation - decode darkening file generated by js library', () async {
    final animation = Animation(
      'My Anim',
      xCount: 1,
      yCount: 1,
      radioPanelsCount: 2,
      radioPanelPixelCount: 2,
    );

    final icicles = Icicles(animation);
    expect(animation.frames, hasLength(0));

    icicles
      ..setRadioPanelPixelColor(0, 0, Colors.red)
      ..show(Duration(seconds: 1));

    expect(animation.frames, [
      equals(RadioVisualFrame(
        duration: Duration(seconds: 1),
        index: 1,
        colors: [Colors.red, Colors.black],
      ))
    ]);

    icicles
      ..setRadioPanelPixelColor(0, 0, Colors.red)
      ..setRadioPanelPixelColor(1, 1, Colors.green)
      ..setAllPixelsColor(Colors.blue)
      ..show(Duration(seconds: 2));

    expect(animation.frames, [
      equals(RadioVisualFrame(
        duration: Duration(seconds: 1),
        index: 1,
        colors: [Colors.red, Colors.black],
      )),
      equals(RadioVisualFrame(
        duration: Duration.zero,
        index: 2,
        colors: [Colors.black, Colors.green],
      )),
      predicate(
        (f) =>
            f is VisualFrame &&
            f.duration == Duration(seconds: 2) &&
            ListEquality().equals(
              f.pixels,
              [Colors.blue],
            ),
      ),
    ]);

    // final readBytes = await File(animationFilePath).readAsBytes();
    // final encodedBytes = animation.toBytes();

    // expect(readBytes, orderedEquals(encodedBytes));
  });
}
