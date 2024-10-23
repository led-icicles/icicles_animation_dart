import 'package:icicles_animation_dart/icicles_animation_dart.dart';

void main() async {
  final animation = Animation(
    'Progress',
    xCount: 64,
    yCount: 8,
    radioPanelsCount: 2,
    radioPanelPixelCount: 60,
    loopsCount: 2,
    framerate: Framerate.fps60,
    framerateBehavior: FramerateBehavior.drop,
    useRgb565: false,
    optimize: true,
  );

  final icicles = Icicles(animation);
  final tween = Tween.curve(
    curve: Curves.linear,
    parent: Tween.number(
      begin: 0.0,
      end: 1.0,
    ),
  );

  void bounce(List<Color> colors) {
    Color backgroundColor = Colors.black;
    for (final foregroundColor in colors) {
      for (double i = 0; i < 1; i += 0.010) {
        icicles
          ..setAllPixelsColor(backgroundColor)
          ..setAllRadioPanelsColor(backgroundColor);
        final progress = tween.transform(i);
        final turnedOnCount =
            (progress * (animation.header.xCount / 2)).round();
        for (int x = 0; x < turnedOnCount; x++) {
          icicles
            ..setColumnColor(x, foregroundColor)
            ..setColumnColor(
                (animation.header.xCount - 1 - x), foregroundColor);
        }

        final radioTurnedOnCount =
            (progress * animation.header.radioPanelPixelCount).round();

        for (final (panelIndex, panel)
            in animation.currentView.radioPanels.indexed) {
          final fromLeft = panelIndex % 2 == 0;
          for (int i = 0; i < radioTurnedOnCount; i++) {
            icicles.setRadioPanelPixelColor(panel.index,
                fromLeft ? i : (panel.colors.length - 1 - i), foregroundColor);
          }
        }

        icicles.show(animation.framerate.minFrameDuration);
      }
      backgroundColor = foregroundColor;
    }
  }

  final colors = [
    Colors.orange,
    Colors.oceanBlue,
    Colors.magenta,
    Colors.green,
    Colors.lightBlue,
    Colors.violet,
    Colors.black,
  ];

  bounce(colors);

  await animation.toFile('./generated/progress.anim');
}
