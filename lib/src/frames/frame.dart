import 'dart:typed_data';

import 'package:icicles_animation_dart/src/utils/size.dart';
import 'package:meta/meta.dart';

enum FrameType {
  /// [(1)type][(2)duration]
  DelayFrame(1),

  /// [(1)type][(2)duration][(ledsCount*3)pixels]
  VisualFrame(2),

  /// [(1 - uint8)type][(2 - uint16)duration][(2 - uint16)changedPixelsCount][(x)changedPixels]
  ///
  /// Changed pixels are described by:
  /// [(2 - uint16)pixel_index][(1 -uint8)red][(1 -uint8)green][(1 -uint8)blue]
  /// Therefore it is possible to index `65535` pixels (leds)
  AdditiveFrame(3),

  /// [(1)type][(2)duration][(ledsCount*2)pixels]
  VisualFrameRgb565(12),

  /// [(1 - uint8)type][(2 - uint16)duration][(2 - uint16)changedPixelsCount][(x)changedPixels]
  ///
  /// Changed pixels are described by:
  /// [(2 - uint16)pixel_index][(1 -uint8)red][(1 -uint8)green][(1 -uint8)blue]
  /// Therefore it is possible to index `65535` pixels (leds)
  AdditiveFrameRgb565(13),

  /// [(uint8)type][(uint16)duration][(uint8)panelIndex][(uint8)red][(uint8)green][(uint8)blue]
  RadioColorFrame(100);

  final int value;

  const FrameType(this.value);
}

@immutable
abstract class Frame {
  static const maxDuration = Duration(milliseconds: UINT_16_MAX_SIZE);
  FrameType get type;
  final Duration duration;

  Frame(this.duration) {
    if (!duration.isNegative && duration > Frame.maxDuration) {
      throw ArgumentError(
          'Not valid duration provided. Duration should be larger or equal 0 but no larger than [Frame.maxDuration].');
    }
  }

  /// Frame size in bytes
  int get size;
  Uint8List toBytes();
}