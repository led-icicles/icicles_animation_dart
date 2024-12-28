class Size {
  final int width;
  final int height;

  const Size(this.width, this.height);

  int get length => width * height;

  @override
  int get hashCode => Object.hash(width, height);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Size && other.width == width && other.height == height;
  }
}
