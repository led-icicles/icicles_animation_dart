import 'package:icicles_animation_dart/icicles_animation_dart.dart';

class Icicles {
  final Animation animation;

  final List<Color> _pixels;
  List<Color> get pixels {
    return List.unmodifiable(_pixels);
  }

  int get xCount {
    return animation.header.xCount;
  }

  int get yCount {
    return animation.header.yCount;
  }

  Icicles(this.animation)
      : _pixels = List.of(animation.currentView.frame.pixels);

  void _isValidIndex(int index) {
    if (index >= _pixels.length || index < 0) {
      throw RangeError.index(index, _pixels, 'pixels',
          'Invalid pixel index provided ($index). Valid range is from "0" to "${_pixels.length - 1}"');
    }
  }

  int getPixelIndex(int x, int y) {
    final index = x * yCount + y;
    _isValidIndex(index);
    return index;
  }

  Color getPixelColor(int x, int y) {
    final index = getPixelIndex(x, y);
    return _pixels[index];
  }

  Color getPixelColorAtIndex(int index) {
    _isValidIndex(index);

    return _pixels[index];
  }

  void setPixelColor(int x, int y, Color color) {
    final index = getPixelIndex(x, y);
    _pixels[index] = color;
  }

  void setColumnColor(int x, Color color) {
    final index = getPixelIndex(x, 0);
    for (var i = index; i < index + yCount; i++) {
      _pixels[i] = color;
    }
  }

  void setRowColor(int y, Color color) {
    for (var x = 0; x < xCount; x += yCount) {
      // const index = this.getPixelIndex(x, y);
      _pixels[x] = color;
    }
  }

  void setPixelColorAtIndex(int index, Color color) {
    _isValidIndex(index);

    _pixels[index] = color;
  }

  void setAllPixelsColor(Color color) {
    for (var i = 0; i < _pixels.length; i++) {
      _pixels[i] = color;
    }
  }

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

  VisualFrame toFrame(Duration duration) {
    return VisualFrame(duration, _pixels);
  }

  /// When setting `duration` to any value other than 0ms, the panel color will be displayed
  /// immediately and the next frame will be delayed by the specified time.
  ///
  /// Skipping the `duration` will cause the radio panel colors to be displayed
  /// together with the `show` method invocation.
  void setRadioPanelColor(
    int panelIndex,
    Color color, [
    Duration duration = Duration.zero,
  ]) {
    animation.addFrame(RadioColorFrame(duration, panelIndex, color));
  }

  /// Displays the current icicles state for a provided [duration]
  ///
  /// It creates and adds a frame to the [animation] class.
  void show(Duration duration) {
    animation.addFrame(toFrame(duration));
  }
}
