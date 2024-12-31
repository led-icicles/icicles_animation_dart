import 'package:collection/collection.dart';
import 'package:icicles_animation_dart/icicles_animation_dart.dart';

abstract interface class Pixels implements Iterable<Color> {
  Size get size;
  @override
  int get length;

  factory Pixels(Size size, List<Color> data) = _Pixels;
  factory Pixels.empty(Size size) = _Pixels.empty;
  factory Pixels.filled(Size size, Color fill) = _Pixels.filled;
  factory Pixels.of(Pixels pixels) = _Pixels.of;

  /// Verify wether two visual frames are compatible.
  static void assertCompatibility(
    Pixels prev,
    Pixels next,
  ) {
    if (prev.size != next.size) {
      throw ArgumentError('Pixels cannot have different sizes.');
    }
  }

  Color getPixel(int index);
  void setPixel(int index, Color color);
}

class _Pixels extends Iterable<Color> implements Pixels {
  final Size _size;
  final List<Color> _data;

  @override
  Size get size => _size;

  _Pixels(this._size, List<Color> data)
      : assert(data.length == _size.length),
        _data = List.of(
          data,
          growable: false,
        );
  _Pixels.empty(this._size)
      : _data = List.filled(
          _size.length,
          const Color(0x00000000),
          growable: false,
        );
  _Pixels.filled(this._size, Color fill)
      : _data = List.filled(
          _size.length,
          fill,
          growable: false,
        );
  _Pixels.of(Pixels pixels)
      : _size = pixels.size,
        _data = List.of(
          pixels,
          growable: false,
        );

  void _assertValidIndex(int index) {
    if (index >= _data.length || index < 0) {
      throw RangeError.index(index, _data, 'pixels',
          'Invalid pixel index provided ($index). Valid range is from "0" to "${_data.length - 1}"');
    }
  }

  @override
  void setPixel(int index, Color color) {
    _assertValidIndex(index);
    _data[index] = color;
  }

  @override
  Color getPixel(int index) {
    _assertValidIndex(index);
    return _data[index];
  }

  @override
  int get length => _data.length;

  @override
  Iterator<Color> get iterator => _data.iterator;

  @override
  int get hashCode => Object.hash(
        size,
        Object.hashAll(_data),
      );

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Pixels &&
        other.size == size &&
        IterableEquality().equals(this, other);
  }
}

class PixelsView extends Iterable<Color> implements Pixels {
  final Pixels data;

  PixelsView(Size size, List<Color> pixels) : data = Pixels(size, pixels);
  PixelsView.empty(Size size) : data = Pixels.empty(size);
  PixelsView.filled(Size size, Color fill) : data = Pixels.filled(size, fill);
  PixelsView.of(Pixels pixels) : data = pixels;

  void _assertValidIndex(int index) {
    if (index >= data.length || index < 0) {
      throw RangeError.index(index, data, 'pixels',
          'Invalid pixel index provided ($index). Valid range is from "0" to "${data.length - 1}"');
    }
  }

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
