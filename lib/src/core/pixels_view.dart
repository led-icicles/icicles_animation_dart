import 'package:collection/collection.dart';
import 'package:icicles_animation_dart/icicles_animation_dart.dart';

class PixelsView {
  final Size size;
  final List<Color> _pixels;
  List<Color> get pixels => List.unmodifiable(_pixels);

  PixelsView(this.size, List<Color> pixels)
      : assert(pixels.length == size.width * size.height),
        _pixels = List.of(pixels);

  PixelsView.filled(this.size, [Color fill = Colors.black])
      : _pixels = List.filled(size.width * size.height, fill);

  int get length => _pixels.length;

  void _isValidIndex(int index) {
    if (index >= _pixels.length || index < 0) {
      throw RangeError.index(index, _pixels, 'pixels',
          'Invalid pixel index provided ($index). Valid range is from "0" to "${_pixels.length - 1}"');
    }
  }

  /// Sets [color] under the specified [x], [y] coordinates.
  void setPixelColor(int x, int y, Color color) {
    final index = getPixelIndex(x, y);
    setPixelColorAtIndex(index, color);
  }

  void setPixelColorAtIndex(int index, Color color) {
    _isValidIndex(index);
    _pixels[index] = color;
  }

  /// Throws the [RangeError] if the provided
  /// [x], [y] coordinates are out of range.
  int getPixelIndex(int x, int y) {
    final index = x * size.height + y;
    _isValidIndex(index);
    return index;
  }

  Color getPixelColor(int x, int y) {
    final index = getPixelIndex(x, y);
    return _pixels[index];
  }

  /// Sets the [x] column to the specified [color].
  void setColumnColor(int x, Color color) {
    final index = getPixelIndex(x, 0);
    for (var i = index; i < index + size.height; i++) {
      setPixelColorAtIndex(i, color);
    }
  }

  void setRowColor(int y, Color color) {
    final index = getPixelIndex(0, y);
    for (var i = index, x = 0; x < size.width; i += size.height, x++) {
      setPixelColorAtIndex(i, color);
    }
  }

  /// Sets all pixels to the specified [color].
  void setAllPixelsColor(Color color) {
    for (var i = 0; i < size.length; i++) {
      setPixelColorAtIndex(i, color);
    }
  }

  Color getPixelColorAtIndex(int index) {
    _isValidIndex(index);
    return _pixels[index];
  }

  void setPixels(List<Color> pixels) {
    if (size.length != pixels.length) {
      throw ArgumentError.value(
          pixels,
          'pixels',
          'Unsupported pixels length: "${pixels.length}". '
              'Size of "${size.length}" is allowed.');
    }
    for (var i = 0; i < size.length; i++) {
      setPixelColorAtIndex(i, pixels[i]);
    }
  }

  List<Color> getColumn(int x) =>
      List<Color>.generate(size.height, (y) => _pixels[x * size.height + y]);

  List<Color> getRow(int y) =>
      List<Color>.generate(size.width, (x) => _pixels[x * size.height + y]);

  /// Verify wether two visual frames are compatible.
  static void assertCompatibility(
    PixelsView prev,
    PixelsView next,
  ) {
    if (prev.size != next.size) {
      throw ArgumentError('PixelViews cannot have different sizes.');
    }
  }

  /// Blend [from] frame with [to] frame using [progress].
  ///
  /// The new frame will have the duration of [to] or [duration] if specified.
  static PixelsView linearBlend(
    PixelsView from,
    PixelsView to,
    double progress, {
    Duration? duration,
  }) {
    PixelsView.assertCompatibility(from, to);

    final pixels = [
      for (var i = 0; i < from._pixels.length; i++)
        Color.linearBlend(from._pixels[i], to._pixels[i], progress)
    ];

    return PixelsView(from.size, pixels);
  }

  @override
  int get hashCode => Object.hash(
        size,
        Object.hashAll(_pixels),
      );

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is PixelsView &&
        other.size == size &&
        const ListEquality().equals(_pixels, other._pixels);
  }
}
