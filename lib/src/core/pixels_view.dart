import 'package:collection/collection.dart';
import 'package:icicles_animation_dart/icicles_animation_dart.dart';

class Pixels extends Iterable<Color> {
  final Size _size;
  final List<Color> _pixels;

  Pixels(this._size, List<Color> pixels)
      : assert(pixels.length == _size.length),
        _pixels = List.of(pixels, growable: false);
  Pixels.empty(this._size)
      : _pixels =
            List.filled(_size.length, const Color(0x00000000), growable: false);
  Pixels.filled(this._size, Color fill)
      : _pixels = List.filled(_size.length, fill, growable: false);
  Pixels.of(Pixels pixels)
      : _size = pixels.size,
        _pixels = List.of(pixels._pixels, growable: false);

  /// Verify wether two visual frames are compatible.
  static void assertCompatibility(
    Pixels prev,
    Pixels next,
  ) {
    if (prev.size != next.size) {
      throw ArgumentError('Pixels cannot have different sizes.');
    }
  }

  Size get size => _size;

  void _assertValidIndex(int index) {
    if (index >= _pixels.length || index < 0) {
      throw RangeError.index(index, _pixels, 'pixels',
          'Invalid pixel index provided ($index). Valid range is from "0" to "${_pixels.length - 1}"');
    }
  }

  void setPixel(int index, Color color) {
    _assertValidIndex(index);
    _pixels[index] = color;
  }

  Color getPixel(int index) {
    _assertValidIndex(index);
    return _pixels[index];
  }

  @override
  int get length => _pixels.length;

  @override
  Iterator<Color> get iterator => _pixels.iterator;

  @override
  int get hashCode => Object.hash(
        size,
        Object.hashAll(_pixels),
      );

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Pixels &&
        other.size == size &&
        const ListEquality().equals(_pixels, other._pixels);
  }
}

class PixelsView extends Iterable<Color> implements Pixels {
  final Pixels data;

  PixelsView(Size size, List<Color> pixels) : data = Pixels(size, pixels);
  PixelsView.empty(Size size) : data = Pixels.empty(size);
  PixelsView.filled(Size size, Color fill) : data = Pixels.filled(size, fill);
  PixelsView.of(Pixels pixels) : data = pixels;

  /// Sets [color] under the specified [x], [y] coordinates.
  void setPixelAt(int x, int y, Color color) {
    final index = getPixelIndex(x, y);
    setPixel(index, color);
  }

  /// Throws the [RangeError] if the provided
  /// [x], [y] coordinates are out of range.
  int getPixelIndex(int x, int y) {
    final index = x * size.height + y;
    _assertValidIndex(index);
    return index;
  }

  Color getPixelColor(int x, int y) {
    final index = getPixelIndex(x, y);
    return getPixel(index);
  }

  /// Sets the [x] column to the specified [color].
  void setColumnColor(int x, Color color) {
    final index = getPixelIndex(x, 0);
    for (var i = index; i < index + size.height; i++) {
      setPixel(i, color);
    }
  }

  void setRowColor(int y, Color color) {
    final index = getPixelIndex(0, y);
    for (var i = index, x = 0; x < size.width; i += size.height, x++) {
      setPixel(i, color);
    }
  }

  /// Sets all pixels to the specified [color].
  void setAllPixelsColor(Color color) {
    for (var i = 0; i < size.length; i++) {
      setPixel(i, color);
    }
  }

  Color getPixelColorAtIndex(int index) {
    _assertValidIndex(index);
    return getPixel(index);
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
      setPixel(i, pixels[i]);
    }
  }

  List<Color> getColumn(int x) =>
      List<Color>.generate(size.height, (y) => getPixel(x * size.height + y));

  List<Color> getRow(int y) => List<Color>.generate(
      size.width, (x) => data.getPixel(x * size.height + y));

  /// Blend [from] frame with [to] frame using [progress].
  ///
  /// The new frame will have the duration of [to] or [duration] if specified.
  static PixelsView linearBlend(
    PixelsView from,
    PixelsView to,
    double progress, {
    Duration? duration,
  }) {
    Pixels.assertCompatibility(from, to);

    final pixels = [
      for (var i = 0; i < from.data.length; i++)
        Color.linearBlend(from.getPixel(i), to.getPixel(i), progress)
    ];

    return PixelsView(from.size, pixels);
  }

  MaskedPixelView withMask(Pixels mask) {
    Pixels.assertCompatibility(this, mask);
    return MaskedPixelView(this, PixelsView.of(mask));
  }

  @override
  int get hashCode => Object.hash(size, Object.hashAll(data));

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is PixelsView && other.data == data;
  }

  @override
  void _assertValidIndex(int index) {
    data._assertValidIndex(index);
  }

  @override
  Size get _size => data._size;
  @override
  Size get size => data.size;

  @override
  Color getPixel(int index) {
    return data.getPixel(index);
  }

  @override
  void setPixel(int index, Color color) {
    return data.setPixel(index, color);
  }

  @override
  Iterator<Color> get iterator => data.iterator;

  @override
  List<Color> get _pixels => data._pixels;
}

class MaskedPixelView extends PixelsView {
  final PixelsView mask;

  @override
  void setPixel(int index, Color color) {
    if (mask.getPixel(index).isTransparent) return;
    super.setPixel(index, color);
  }

  MaskedPixelView(
    super.pixels,
    this.mask,
  ) : super.of();
}
