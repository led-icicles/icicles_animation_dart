import 'package:icicles_animation_dart/icicles_animation_dart.dart';

/// Random access by time to the views of a single animation pass.
///
/// See [Animation.toIndex].
class AnimationIndex {
  /// Views displayed for a non-zero duration, in playback order.
  final List<AnimationView> views;
  final List<Duration> _starts;

  /// Sum of the [views] durations.
  final Duration duration;

  AnimationIndex._(this.views, this._starts, this.duration);

  /// Indexes [views] of a single pass, skipping zero-duration views.
  factory AnimationIndex(Iterable<AnimationView> views) {
    final displayed = <AnimationView>[];
    final starts = <Duration>[];
    var time = Duration.zero;
    for (final view in views) {
      final duration = view.frame.duration;
      if (duration == Duration.zero) continue;
      displayed.add(view);
      starts.add(time);
      time += duration;
    }
    return AnimationIndex._(
      List.unmodifiable(displayed),
      List.unmodifiable(starts),
      time,
    );
  }

  /// Start time of the view at [index].
  Duration startOf(int index) => _starts[index];

  /// Index of the view displayed at [time], which must be in `[0, duration)`.
  int indexAt(Duration time) {
    if (time.isNegative || time >= duration) {
      throw RangeError.range(
        time.inMicroseconds,
        0,
        duration.inMicroseconds - 1,
        'time',
      );
    }
    var low = 0;
    var high = _starts.length - 1;
    while (low < high) {
      final mid = (low + high + 1) >> 1;
      if (_starts[mid] <= time) {
        low = mid;
      } else {
        high = mid - 1;
      }
    }
    return low;
  }

  /// View displayed at [time], which must be in `[0, duration)`.
  AnimationView viewAt(Duration time) => views[indexAt(time)];
}
