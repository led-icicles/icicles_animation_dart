/// How [Color.composite] mixes a source color with a destination color.
enum BlendMode {
  /// The source over the destination, same as [Color.alphaBlend].
  normal,

  /// Sum of the channels, clamped to `255`.
  add,

  /// Inverted product of the inverted channels, never darker than either.
  screen,

  /// Product of the channels, never lighter than either.
  multiply,

  /// The lighter channel.
  max,

  /// The darker channel.
  min,
}
