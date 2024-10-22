import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:meta/meta.dart';

abstract class RadioFrame extends Frame {
  static const maxPanelIndex = uint8MaxSize;
  static const broadcastChannelIndex = 0;

  /// Panel index.
  /// `0` - Stands for the broadcast (all panels). This is also described by the
  /// [RadioColorFrame.broadcastChannelIndex] constant. Take a look at the
  /// [isBroadcast] getter.
  ///
  /// Panel index cannot be larger than [RadioColorFrame.maxPanelIndex].
  final int panelIndex;

  bool get isBroadcast {
    return panelIndex == RadioFrame.broadcastChannelIndex;
  }

  RadioFrame(super.duration, this.panelIndex) {
    if (panelIndex.isNegative || panelIndex > uint8MaxSize) {
      throw ArgumentError(
        'Not valid panel index provided. '
        'Panel index should be larger or equal 0 (for broadcast) '
        'and smaller than [RadioColorFrame.maxPanelIndex].',
      );
    }
  }
}
