import 'package:icicles_animation_dart/icicles_animation_dart.dart';
export 'tweens/tween.dart';
export 'curves/curve.dart';

/// An abstraction of icicles, which allows for the simple
/// creation of animations.
class Icicles {
  /// Current definition of animation.
  final Animation animation;

  final List<Color> _pixels;

  /// Returns the current animation pixels.
  ///
  /// The returned list cannot be modified.
  List<Color> get pixels {
    return List.unmodifiable(_pixels);
  }

  /// Returns the total number of pixels that are supported by this animation
  int get pixelsCount {
    return _pixels.length;
  }

  /// Returns the number of radio panels that are supported by this animation
  int get radioPanelsCount {
    return animation.header.radioPanelsCount;
  }

  /// Returns the number of columns (icicles)
  int get xCount {
    return animation.header.xCount;
  }

  /// Returns the number of rows (pixels per icicle)
  int get yCount {
    return animation.header.yCount;
  }

  /// Constructs an abstraction of icicles,
  /// which allows for the simple creation of animations.
  Icicles(this.animation)
      : _pixels = List.of(animation.currentView.frame.pixels);

  void _isValidIndex(int index) {
    if (index >= _pixels.length || index < 0) {
      throw RangeError.index(index, _pixels, 'pixels',
          'Invalid pixel index provided ($index). Valid range is from "0" to "${_pixels.length - 1}"');
    }
  }

  /// Converts two-dimensional x,y coordinates into
  /// a one-dimensional pixel index.
  ///
  /// This can be helpful for some animations.
  /// However, if you want to read the color of a pixel at the specified
  /// location, use the [getPixelColor] method instead.
  int getPixelIndex(int x, int y) {
    final index = x * yCount + y;
    _isValidIndex(index);
    return index;
  }

  /// Returns the current color of the pixel in the given [x], [y] coordinates.
  ///
  /// This method is equivalent to:
  /// ```
  /// final color = icicles.pixels[getPixelIndex(x, y)];
  /// ```
  Color getPixelColor(int x, int y) {
    final index = getPixelIndex(x, y);
    return _pixels[index];
  }

  /// Returns the current color of the pixel in the given [index].
  ///
  /// This method is similar to the [getPixelColor] method,
  /// but uses one-dimensional indexes.
  ///
  /// This method is equivalent to:
  /// ```
  /// final color = icicles.pixels[index];
  /// ```
  Color getPixelColorAtIndex(int index) {
    _isValidIndex(index);

    return _pixels[index];
  }

  /// Sets [color] under the specified [x], [y] coordinates.
  void setPixelColor(int x, int y, Color color) {
    final index = getPixelIndex(x, y);
    _pixels[index] = color;
  }

  /// Sets [color] under the specified [index].
  void setPixelColorAtIndex(int index, Color color) {
    _isValidIndex(index);
    _pixels[index] = color;
  }

  /// Sets the [x] column to the specified [color].
  void setColumnColor(int x, Color color) {
    final index = getPixelIndex(x, 0);
    for (var i = index; i < index + yCount; i++) {
      _pixels[i] = color;
    }
  }

  /// Sets the [y] row to the specified [color].
  void setRowColor(int y, Color color) {
    final index = getPixelIndex(0, y);
    for (var i = index, x = 0; x < xCount; i += yCount, x++) {
      _pixels[i] = color;
    }
  }

  /// Sets all pixels to the specified [color].
  void setAllPixelsColor(Color color) {
    for (var i = 0; i < _pixels.length; i++) {
      _pixels[i] = color;
    }
  }

  /// Replaces all pixels with the specified [pixels].
  void setPixels(List<Color> pixels) {
    if (_pixels.length != pixels.length) {
      throw ArgumentError.value(
          pixels,
          'pixels',
          'Unsupported pixels length: "${pixels.length}". '
              'Size of "${_pixels.length}" is allowed.');
    }
    for (var i = 0; i < _pixels.length; i++) {
      _pixels[i] = pixels[i];
    }
  }

  /// Converts the current pixel state to [VisualFrame].
  ///
  /// This method is used internally by the [show] method
  /// to add a new frame to the [animation].
  VisualFrame toFrame(Duration duration) {
    return VisualFrame(duration, _pixels);
  }

  /// Sets the color of the radio panel specified by the [panelIndex].
  ///
  /// When setting `duration` to any value other than 0ms, the panel color will be displayed
  /// immediately and the next frame will be delayed by the specified time.
  ///
  /// Skipping the `duration` will cause the radio panel colors to be displayed
  /// together with the `show` method invocation.
  ///
  /// Panel indexes start from 1, setting [panelIndex] to `0` will update
  /// all available radio panels.
  void setRadioPanelColor(
    int panelIndex,
    Color color, [
    Duration duration = Duration.zero,
  ]) {
    animation.addFrame(RadioColorFrame(duration, panelIndex, color));
  }

  /// Sets the colors of all available radio panels.
  ///
  /// When setting `duration` to any value other than 0ms, the panel color will be displayed
  /// immediately and the next frame will be delayed by the specified time.
  ///
  /// Skipping the `duration` will cause the radio panel colors to be displayed
  /// together with the `show` method invocation.
  void setAllRadioPanelsColor(
    Color color, [
    Duration duration = Duration.zero,
  ]) {
    animation.addFrame(RadioColorFrame(duration, 0, color));
  }

  /// Displays the current icicles state for a provided [duration]
  ///
  /// It creates and adds a frame to the [animation] class.
  void show(Duration duration) {
    animation.addFrame(toFrame(duration));
  }
}
