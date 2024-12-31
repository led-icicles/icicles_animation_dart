import 'package:icicles_animation_dart/icicles_animation_dart.dart';
export 'tweens/tween.dart';
export 'curves/curve.dart';

/// An abstraction of icicles, which allows for the simple
/// creation of animations.
class Icicles {
  /// Current definition of animation.
  final Animation animation;

  final PixelsView strip;

  // final List<PixelsView> _pixels;
  final List<PixelsView> _radioPanels;
  List<PixelsView> get radioPanels => List.unmodifiable(_radioPanels);

  /// Returns the total number of pixels that are supported by this animation
  int get pixelsCount {
    return strip.length;
  }

  /// Returns the number of radio panels that are supported by this animation
  int get radioPanelsCount {
    return animation.header.radioPanelsCount;
  }

  /// Returns [strip] size.
  Size get size => strip.size;

  /// Constructs an abstraction of icicles,
  /// which allows for the simple creation of animations.
  Icicles(this.animation)
      : strip = PixelsView(
          Size(animation.header.xCount, animation.header.yCount),
          animation.currentView.frame.pixels,
        ),
        _radioPanels = List.generate(
          animation.currentView.radioPanels.length,
          (index) => PixelsView(
            Size(animation.header.radioPanelPixelCount, 1),
            animation.currentView.radioPanels[index].colors,
          ),
        );

  Icicles._internal(this.animation, this.strip, this._radioPanels);

  Icicles withMask(PixelsView stripMask, List<PixelsView> radioPanels) {
    return Icicles._internal(animation, strip.withMask(stripMask), [
      for (final (index, view) in _radioPanels.indexed)
        view.withMask(radioPanels[index])
    ]);
  }

  /// Converts two-dimensional x,y coordinates into
  /// a one-dimensional pixel index.
  ///
  /// This can be helpful for some animations.
  /// However, if you want to read the color of a pixel at the specified
  /// location, use the [getPixelColor] method instead.
  int getPixelIndex(int x, int y) {
    return strip.getPixelIndex(x, y);
  }

  /// Returns the current color of the pixel in the given [x], [y] coordinates.
  ///
  /// This method is equivalent to:
  /// ```
  /// final color = icicles.pixels[getPixelIndex(x, y)];
  /// ```
  Color getPixelColor(int x, int y) {
    return strip.getPixelColor(x, y);
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
    return strip.getPixelColorAtIndex(index);
  }

  /// Sets [color] under the specified [x], [y] coordinates.
  void setPixelColor(int x, int y, Color color) {
    return strip.setPixelAt(x, y, color);
  }

  /// Sets [color] under the specified [index].
  void setPixelColorAtIndex(int index, Color color) {
    return strip.setPixel(index, color);
  }

  /// Sets the [x] column to the specified [color].
  void setColumnColor(int x, Color color) {
    return strip.setColumnColor(x, color);
  }

  /// Sets the [y] row to the specified [color].
  void setRowColor(int y, Color color) {
    return strip.setRowColor(y, color);
  }

  /// Sets all pixels to the specified [color].
  void setAllPixelsColor(Color color) {
    return strip.setAllPixelsColor(color);
  }

  /// Replaces all pixels with the specified [pixels].
  void setPixels(List<Color> pixels) {
    return strip.setPixels(pixels);
  }

  /// Blends all [pixels] colors with the supplied [color]
  /// by the given [progress].
  ///
  /// Example:
  /// ```
  /// icicles.blendAllPixels(Colors.black, 0.5);
  /// ```
  void blendAllPixels(
    Color color,
    double progress, {
    bool blendRadioPanels = false,
  }) {
    for (var i = 0; i < strip.length; i++) {
      strip.setPixel(
        i,
        Color.linearBlend(
          getPixelColorAtIndex(i),
          color,
          progress,
        ),
      );
    }
    if (blendRadioPanels) {
      blendAllRadioPanels(color, progress);
    }
  }

  /// Blends all radio panels colors with the supplied [color]
  /// by the given [progress].
  void blendAllRadioPanels(Color color, double progress) {
    for (final radioPanelPixels in _radioPanels) {
      for (var i = 0; i < radioPanelPixels.length; i++) {
        radioPanelPixels.setPixel(
            i, radioPanelPixels.getPixelColorAtIndex(i).blend(color, progress));
      }
    }
  }

  /// Lighten all [pixels] colors by [progress] amount (`1.0` = white)
  void lightenAllPixels(double progress, {bool lightenRadioPanels = false}) {
    for (var i = 0; i < strip.length; i++) {
      setPixelColorAtIndex(i, getPixelColorAtIndex(i).lighten(progress));
    }
    if (lightenRadioPanels) {
      lightenAllRadioPanels(progress);
    }
  }

  /// Lighten all [pixels] colors by [progress] amount (`1.0` = white)
  void lightenAllRadioPanels(double progress) {
    for (final radioPanelPixels in _radioPanels) {
      for (var i = 0; i < radioPanelPixels.length; i++) {
        radioPanelPixels.setPixel(
            i, radioPanelPixels.getPixelColorAtIndex(i).lighten(progress));
      }
    }
  }

  /// Darken all [pixels] colors by [progress] amount (`1.0` = black)
  void darkenAllPixels(double progress, {bool darkenRadioPanels = false}) {
    for (var i = 0; i < strip.length; i++) {
      setPixelColorAtIndex(i, getPixelColorAtIndex(i).darken(progress));
    }
    if (darkenRadioPanels) {
      darkenAllRadioPanels(progress);
    }
  }

  /// Darken all radio panel colors by [progress] amount (`1.0` = black)
  void darkenAllRadioPanels(double progress) {
    for (final radioPanelPixels in _radioPanels) {
      for (var i = 0; i < radioPanelPixels.length; i++) {
        radioPanelPixels.setPixel(
            i, radioPanelPixels.getPixelColorAtIndex(i).darken(progress));
      }
    }
  }

  /// Converts the current pixel state to [VisualFrame].
  ///
  /// This method is used internally by the [show] method
  /// to add a new frame to the [animation].
  VisualFrame toFrame(Duration duration) {
    return VisualFrame(duration: duration, pixels: strip.toList());
  }

  /// Sets the color of the radio panel specified by the [panelIndex].
  ///
  /// Panel indexes start from `0`.
  ///
  /// To display it use the [show] method.
  void setRadioPanelPixelColor(
    int panelIndex,
    int pixelIndex,
    Color color,
  ) {
    RangeError.checkValidIndex(panelIndex, _radioPanels, 'radioPanels');
    final pixels = _radioPanels[panelIndex];
    RangeError.checkValidIndex(pixelIndex, pixels, 'radioPanelPixels');
    pixels.setPixel(pixelIndex, color);
  }

  /// Sets the color of the radio panel specified by the [panelIndex].
  ///
  /// Panel indexes starts from `0`.
  ///
  /// To display it use the [show] method.
  void setRadioPanelColor(
    int panelIndex,
    Color color,
  ) {
    final pixels = _radioPanels[panelIndex];
    pixels.setAllPixelsColor(color);
  }

  /// Sets the colors of all available radio panels.
  ///
  /// To display it use the [show] method.
  void setAllRadioPanelsColor(Color color) {
    for (final radioPanelPixels in _radioPanels) {
      radioPanelPixels.setAllPixelsColor(color);
    }
  }

  /// Sets the colors of all available radio panels.
  ///
  /// To display it use the [show] method.
  void setAllRadioPanelsColors(List<Color> colors) {
    if (_radioPanels.isEmpty) {
      throw StateError("This animation do not support radio panels.");
    }
    if (_radioPanels.first.length != colors.length) {
      throw ArgumentError(
        'Invalid colors list length: Provided ${colors.length} colors, '
            'but the expected length is ${_radioPanels.first.length}.',
        'colors',
      );
    }
    for (int i = 0; i < _radioPanels.length; i++) {
      _radioPanels[i].setPixels(colors);
    }
  }

  /// Displays the current icicles state for a provided [duration]
  ///
  /// It creates and adds a frame to the [animation] class.
  void show(Duration duration) {
    for (int i = 0; i < _radioPanels.length; i++) {
      animation.addFrame(RadioVisualFrame(
        duration: Duration.zero,
        index: i + 1,
        colors: _radioPanels[i].toList(),
      ));
    }
    animation.addFrame(toFrame(duration));
  }
}
