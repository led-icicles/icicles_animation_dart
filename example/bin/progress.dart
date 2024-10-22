import 'package:icicles_animation_dart/icicles_animation_dart.dart';

void main() async {
  final animation = Animation(
    'Progress',
    xCount: 20,
    yCount: 30,
    radioPanelsCount: 2,
    radioPanelPixelCount: 60,
    loopsCount: 10,
    framerate: Framerate.fps24,
    framerateBehavior: FramerateBehavior.drop,
    useRgb565: false,
    optimize: true,
  );

  final icicles = Icicles(animation);
  // final tween = Tween.curve(
  //   curve: Curves.bounceOut,
  //   parent: Tween.number(
  //     begin: 0.0,
  //     end: 1.0,
  //   ),
  // );

  void bounce(List<Color> colors) {
    Color backgroundColor = Colors.black;
    for (final foregroundColor in colors) {
      for (double i = 0; i < 1; i += 0.015) {
        icicles
          ..setAllPixelsColor(backgroundColor)
          ..setAllRadioPanelsColor(backgroundColor);
        final progress = i;
        final turnedOnCount = (progress * animation.header.yCount).round();
        for (int y = 0; y < turnedOnCount; y++) {
          icicles.setRowColor(y, foregroundColor);
        }

        final radioTurnedOnCount =
            (progress * animation.header.radioPanelPixelCount).round();

        for (final panel in animation.currentView.radioPanels) {
          for (int i = 0; i < radioTurnedOnCount; i++) {
            print("P: ${panel.index} I: $i");
            icicles.setRadioPanelPixelColor(panel.index, i, foregroundColor);
          }
        }

        icicles.show(animation.framerate.minFrameDuration);
      }
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

  await animation.toFile('./generated/progress.anim');
}
