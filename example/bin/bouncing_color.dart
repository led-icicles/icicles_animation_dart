import 'package:icicles_animation_dart/icicles_animation_dart.dart';

void main() async {
  final animation = Animation(
    'Bouncing color',
    xCount: 20,
    yCount: 30,
    radioPanelsCount: 2,
    loopsCount: 10,
    framerate: Framerate.fps45,
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

  void bounce(List<Color> colors) {
    Color radioPanelsColor = Colors.black;
    Color backgroundColor = Colors.black;
    for (final foregroundColor in colors) {
      for (double i = 0; i < 1; i += 0.015) {
        icicles.setAllPixelsColor(backgroundColor);
        final turnedOnCount = tween.transform(i);
        for (int y = 0; y < turnedOnCount; y++) {
          icicles.setRowColor(y, foregroundColor);
        }
        icicles.setAllRadioPanelsColor(
          Color.linearBlend(
            radioPanelsColor,
            backgroundColor,
            Curves.bounceOut.transform(i),
          ),
        );
        icicles.show(Framerate.fps45.minFrameDuration);
      }
      radioPanelsColor = backgroundColor;
      backgroundColor = foregroundColor;
    }
  }

  final colors = [
    Colors.black,
    Colors.orange,
    Colors.oceanBlue,
    Colors.magenta,
    Colors.green,
    Colors.lightBlue,
    Colors.violet,
    Colors.black,
    Colors.black
  ];

  bounce(colors);

  await animation.toFile('./generated/bouncing-color.anim');
}
