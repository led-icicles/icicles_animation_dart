import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:meta/meta.dart';

enum SerialMessageTypes {
  /// Keep LEDs aware of ongoing serial communication.
  ///
  /// Built-in animations are stopped.
  ping(0),

  /// Display following frame
  displayView(1),

  /// End serial communication and start playing built-in animations
  end(10);

  final int value;

  const SerialMessageTypes(this.value);
}

@immutable
class RadioPanelView {
  final int index;
  final List<Color> colors;

  RadioPanelView(this.index, List<Color> colors)
      : assert(
          colors.isNotEmpty,
          'The color list must include at least one color.',
        ),
        colors = List<Color>.unmodifiable(colors);

  RadioPanelView copyWith({
    int? index,
    List<Color>? colors,
  }) {
    if (colors != null && colors.length != this.colors.length) {
      throw ArgumentError(
        'Invalid colors list length: Provided ${colors.length} colors, '
            'but the expected length is ${this.colors.length}.',
        'colors',
      );
    }
    return RadioPanelView(
      index ?? this.index,
      colors ?? this.colors,
    );
  }

  RadioPanelView copyWithColor(Color color) => RadioPanelView(
        index,
        List.filled(colors.length, color),
      );

  /// Return true when all colors stored inside the [RadioPanelView]
  /// are identical.
  bool hasAllColorsIdentical() {
    final firstColor = colors.first;
    return colors.every((color) => color == firstColor);
  }

  /// Converts this [RadioPanelView] to [RadioColorFrame].
  ///
  /// When [hasAllColorsIdentical] returns false, then [UnsupportedError]
  /// is thrown.
  RadioColorFrame toRadioColorFrame([Duration duration = Duration.zero]) {
    if (colors.length == 1) {
      return RadioColorFrame(duration, index, colors.first);
    } else if (hasAllColorsIdentical()) {
      return RadioColorFrame(duration, index, colors.first);
    } else {
      throw StateError(
        'Cannot convert to RadioColorFrame. '
        'All colors must be identical.',
      );
    }
  }

  /// Converts this [RadioPanelView] to [RadioVisualFrame].
  RadioVisualFrame toRadioVisualFrame([Duration duration = Duration.zero]) {
    return RadioVisualFrame(duration, index, colors);
  }

  @override
  int get hashCode => Object.hash(index, Object.hashAll(colors));

  @override
  bool operator ==(Object other) {
    return other is RadioPanelView &&
        other.index == index &&
        const ListEquality().equals(colors, other.colors);
  }
}

/// Class used for serial communication,
/// represents the current icicles state
@immutable
class AnimationView {
  final VisualFrame frame;
  final List<RadioPanelView> radioPanels;

  AnimationView(
    this.frame,
    List<RadioPanelView> radioPanels,
  ) : radioPanels = List.unmodifiable(radioPanels);

  AnimationView copyApplied(Frame newFrame) {
    VisualFrame? updatedFrame;
    final radioPanels = List.of(this.radioPanels);

    if (newFrame is VisualFrame) {
      updatedFrame = newFrame;
    } else if (newFrame is AdditiveFrame) {
      updatedFrame = newFrame.mergeOnto(frame);
    } else if (newFrame is RadioColorFrame) {
      if (newFrame.isBroadcast) {
        for (var i = 0; i < radioPanels.length; i++) {
          radioPanels[i] = radioPanels[i].copyWithColor(
            newFrame.color,
          );
        }
      } else {
        final localIndex = newFrame.panelIndex - 1;
        // shift index due to broadcast panel at 0
        radioPanels[localIndex] =
            radioPanels[localIndex].copyWithColor(newFrame.color);
      }
    } else if (newFrame is RadioVisualFrame) {
      if (newFrame.isBroadcast) {
        for (var i = 0; i < radioPanels.length; i++) {
          radioPanels[i] = radioPanels[i].copyWith(
            colors: newFrame.colors,
          );
        }
      } else {
        final localIndex = newFrame.panelIndex - 1;
        // shift index due to broadcast panel at 0
        radioPanels[localIndex] = radioPanels[localIndex].copyWith(
          colors: newFrame.colors,
        );
      }
    }

    return copyWith(frame: updatedFrame, radioPanels: radioPanels);
  }

  AnimationView copy() => copyWith();

  AnimationView copyWith({
    VisualFrame? frame,
    List<RadioPanelView>? radioPanels,
  }) =>
      AnimationView(
        frame ?? this.frame,
        radioPanels ?? this.radioPanels,
      );

  int getRadioPanelSize() {
    const panelIndexSize = uint8SizeInBytes;
    const color = uint8SizeInBytes * 3;
    return panelIndexSize + color;
  }

  /// Converts the current view into most valid [RadioFrame].
  ///
  /// - If there are no radio panels, an empty list will be returned.
  /// - If all radio panels have the same state (colors), one frame will be
  /// returned - [RadioColorFrame] or [RadioVisualFrame] depending
  /// on the frame content.
  /// - If the radio panels have different states (colors),
  /// a [RadioColorFrame] or [RadioVisualFrame] will be generated
  /// for each panel.
  List<RadioFrame> getRadioFrames([Duration duration = Duration.zero]) {
    if (radioPanels.isEmpty) return [];

    final hasPanelsWithSameColors = radioPanels.isNotEmpty &&
        radioPanels.every((panel) => const ListEquality()
            .equals(panel.colors, radioPanels.first.colors));

    if (hasPanelsWithSameColors) {
      if (radioPanels.first.hasAllColorsIdentical()) {
        return [
          RadioColorFrame(
            duration,
            RadioFrame.broadcastChannelIndex,
            radioPanels.first.colors.first,
          )
        ];
      } else {
        return [
          RadioVisualFrame(
            duration,
            RadioFrame.broadcastChannelIndex,
            radioPanels.first.colors,
          ),
        ];
      }
    } else {
      return radioPanels.map((panel) => panel.toRadioVisualFrame()).toList();
    }
  }

  int getFrameSize() {
    final colorsSize = frame.pixels.length * 3;
    // During serial communication frame duration and type is redundant;
    return colorsSize;
  }

  ///  Convert to bytes that can be send over serial (skip duration)
  Uint8List toBytes([Endian endian = Endian.little]) {
    final radioPanelSize = getRadioPanelSize();
    final radioPanelsSize = radioPanelSize * radioPanels.length;
    final frameSize = getFrameSize();
    final messageTypeSize = uint8SizeInBytes;
    final viewSize = messageTypeSize + frameSize + radioPanelsSize;

    final writer = Writer(viewSize, endian);

    // Set message type
    writer.writeSerialMessageType(SerialMessageTypes.displayView);

    /// frame pixels
    writer.writeAllColors(frame.pixels);

    /// encode radio panels
    for (var i = 0; i < radioPanels.length; i++) {
      final radioPanelView = radioPanels[i];

      writer
        ..writeUint8(radioPanelView.index)
        ..writeAllColors(radioPanelView.colors);
    }

    return writer.bytes;
  }

  @override
  int get hashCode => Object.hash(frame, Object.hashAllUnordered(radioPanels));

  @override
  bool operator ==(Object other) {
    return other is AnimationView &&
        other.frame == frame &&
        const UnorderedIterableEquality()
            .equals(radioPanels, other.radioPanels);
  }
}
