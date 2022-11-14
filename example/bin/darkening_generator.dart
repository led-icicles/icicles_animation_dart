import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'dart:math' as math;

void main(List<String> arguments) async {
  const xCount = 20;
  const yCount = 30;
  final animation = Animation(
    "Darkening",
    optimize: true,
    versionNumber: 1,
    xCount: xCount,
    useRgb565: false,
    yCount: yCount,
    radioPanelsCount: 2,
    loopsCount: 2,
  );
  final icicles = Icicles(animation);

  void dimm(Color color) {
    for (var i = -math.pi * 0.5; i <= math.pi * 1.5; i += 0.05) {
      final val = (math.sin(i) + 1) * 0.5;
      final target = Color.linearBlend(Colors.black, color, val);
      icicles
        ..setAllPixelsColor(target)
        ..setRadioPanelColor(0, target)
        ..show(const Duration(milliseconds: 60));
    }
  }

  dimm(Colors.red);
  dimm(Colors.lightBlue);
  dimm(Colors.orange);
  dimm(Colors.violet);
  dimm(Colors.lawnGreen);
  dimm(Colors.magenta);
  dimm(Colors.yellow);
  dimm(Colors.blue);
  dimm(Colors.green);

  await animation.toFile('./compiled/darkening.anim');
}
