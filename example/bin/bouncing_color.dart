import 'package:icicles_animation_dart/icicles_animation_dart.dart';

void main() async {
  final animation = Animation(
    'Bouncing color',
    xCount: 20,
    yCount: 30,
    radioPanelsCount: 2,
    loopsCount: 10,
    framerate: Framerate.fps30,
    framerateBehavior: FramerateBehavior.drop,
    useRgb565: false,
    optimize: true,
  );

  final icicles = Icicles(animation);
  final tween = Tween.curve(
    curve: Curves.bounceOut,
    parent: Tween.number(
      begin: 0,
      end: icicles.yCount,
    ),
  );

  for (double i = 0; i < 1; i += 0.05) {
    icicles.setAllPixelsColor(Colors.black);
    final turnedOnCount = tween.transform(i);
    for (int y = 0; y < turnedOnCount; y++) {
      icicles.setRowColor(y, Colors.orange);
    }
    icicles.show(Duration(milliseconds: 60));
  }
  await animation.toFile('./generated/bouncing-color.anim');
}
