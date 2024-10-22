import 'dart:typed_data';

import 'package:icicles_animation_dart/src/core/encodable.dart';
import 'package:icicles_animation_dart/src/core/size.dart';
import 'package:meta/meta.dart';

enum FrameType {
  /// [(1)type][(2)duration]
  delay(1),

  /// [(1)type][(2)duration][(ledsCount*3)pixels]
  visual(2),

  /// [(1 - uint8)type][(2 - uint16)duration][(2 - uint16)changedPixelsCount][(x)changedPixels]
  ///
  /// Changed pixels are described by:
  /// [(2 - uint16)pixel_index][(1 -uint8)red][(1 -uint8)green][(1 -uint8)blue]
  /// Therefore it is possible to index `65535` pixels (leds)
  additive(3),

  /// [(1)type][(2)duration][(ledsCount*2)pixels]
  visualRgb565(12),

  /// [(1 - uint8)type][(2 - uint16)duration][(2 - uint16)changedPixelsCount][(x)changedPixels]
  ///
  /// Changed pixels are described by:
  /// [(2 - uint16)pixel_index][(1 -uint8)red][(1 -uint8)green][(1 -uint8)blue]
  /// Therefore it is possible to index `65535` pixels (leds)
  additiveRgb565(13),

  /// [(uint8)type][(uint16)duration][(uint8)panelIndex][(uint8)red][(uint8)green][(uint8)blue]
  radioColor(100),
  radioVisualFrame(101);

  final int value;

  const FrameType(this.value);

  factory FrameType.fromValue(int value) {
    return FrameType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError.value(
        value,
        'value',
        'Unsupported frame type value',
      ),
    );
  }
}

/// Generic animation frame interface.
@immutable
abstract class Frame implements Encodable {
  /// Constant describing the maximum possible duration of the frame.
  static const maxDuration = Duration(milliseconds: uint16MaxSize);

  /// Frame type
  FrameType get type;

  /// The frame duration.
  final Duration duration;

  Frame({
    required this.duration,
  }) {
    if (!duration.isNegative && duration > Frame.maxDuration) {
      throw ArgumentError(
        'Not valid duration provided. Duration should be larger or equal 0 but no larger than [Frame.maxDuration].',
      );
    }
  }

  /// Frame size in bytes
  int get size;

  Frame copyWith({Duration? duration});

  /// Converts the following frame into its binary representation.
  @override
  Uint8List toBytes([Endian endian = Endian.little]);
}
