# icicles_animation_dart

## Getting started

The purpose of this library is to simplify the animation creation process by providing a high-level, abstract interface for creating animation generators.

By generator, we mean an application whose purpose is to create a file with a binary record of raw animation frames.

The code for a simple generator that displays alternating blue and red colors 10 times looks as follows:

```dart
// Import the icicles_animation_dart package
import 'package:icicles_animation_dart/icicles_animation_dart.dart';


void main() async {
/// Define the animation
  final animation = Animation(
    // Animation name (UTF8) - may contain Polish characters
    'Police',
    // Number of icicles
    xCount: 20,
    // LEDs per icicle
    yCount: 30,
    // Radio panels count
    radioPanelsCount: 2,
    // How many times the animation will be played
    loopsCount: 10,
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
```

To generate, just run the dart file
```
dart run police.dart
```

### TIP: 
You can also provide command line arguments to specify the output file path or some animation variables, such as accent color, animation duration, loops, etc.

---

## This library is more than 100 times faster than the JavaScript implementation.

### Decoding performance (test/data/darkening.anim file)

```
Decoded 2184 frames with size of 1900.77KB in 23ms
Decoded 2184 frames with size of 1900.77KB in 13ms
Decoded 2184 frames with size of 1900.77KB in 29ms
Decoded 2184 frames with size of 1900.77KB in 7ms
Decoded 2184 frames with size of 1900.77KB in 7ms
Decoded 2184 frames with size of 1900.77KB in 7ms
Decoded 2184 frames with size of 1900.77KB in 7ms
```
