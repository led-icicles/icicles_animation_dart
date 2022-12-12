import 'package:icicles_animation_dart/icicles_animation_dart.dart';

void main() async {
  /// Define the animation
  final animation = Animation(
    // Animation name (UTF8) - can contains the polish characters
    'Police',
    // Number of icicles
    xCount: 20,
    // LEDs per icicle
    yCount: 30,
    // Radio panels count
    radioPanelsCount: 2,
    // How many times the animation will be played
    loopsCount: 10,
    // The maxium animation framerate
    framerate: Framerate.fps30,
    // Describes what happens if a frame is added with a higher framerate
    // than supported
    framerateBehavior: FramerateBehavior.error,
    // Smaller file sizes, but not supported by controllers!
    useRgb565: false,
    // It removes redundant frames and uses the most size-efficient frames
    // possible.
    optimize: true,
  );

  final icicles = Icicles(animation);

  /// Instead of the RGB color constructor, we can also
  /// use the Colors.red constant defined by this library.
  icicles.setAllPixelsColor(Color.fromRGB(255, 0, 0));

  /// Sets the radio panels color to red.
  ///
  /// LED of the panel with index 0 - stands for the broadcast
  /// channel, thanks to that all available radio panels
  /// will become red
  icicles.setRadioPanelColor(0, Colors.red);

  /// Display the current icicles state for 2 seconds
  icicles.show(Duration(seconds: 2));

  /// The same steps for the blue color
  icicles
    ..setAllPixelsColor(Colors.blue)
    ..setRadioPanelColor(0, Colors.blue)
    ..show(Duration(seconds: 2));

  /// Thats all. Now we can save our animation
  /// under the provided path.
  ///
  /// The `.anim` extension is not required,
  /// but is required by most controllers.
  await animation.toFile('./generated/police.anim');
}
