import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:icicles_animation_dart/icicles_animation_dart.dart';

enum SerialMessageTypes {
  /// Keep leds aware of ongoing serial communication.
  ///
  /// Built-in animations are stopped.
  ping(0),

  /// display following frame
  displayView(1),

  /// End serial communication and start playing built-in animations
  end(10);

  final int value;

  const SerialMessageTypes(this.value);
}

class RadioPanelView extends Equatable {
  final int index;
  final Color color;

  RadioPanelView(this.index, this.color);

  RadioPanelView copyWith({
    int? index,
    Color? color,
  }) =>
      RadioPanelView(index ?? this.index, color ?? this.color);

  RadioColorFrame toRadioColorFrame([Duration duration = Duration.zero]) =>
      RadioColorFrame(duration, index, color);

  @override
  List<Object?> get props => [index, color];
}

/// Class used for serial communication,
/// represents the current icicles state
class AnimationView extends Equatable {
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
          radioPanels[i] = radioPanels[i].copyWith(
            color: newFrame.color,
          );
        }
      } else {
        final localIndex = newFrame.panelIndex - 1;
        // shift index due to broadcast panel at 0
        radioPanels[localIndex] =
            radioPanels[localIndex].copyWith(color: newFrame.color);
      }
    }

    return copyWith(frame: updatedFrame, radioPanels: radioPanels);
  }

  AnimationView copyWith({
    VisualFrame? frame,
    List<RadioPanelView>? radioPanels,
  }) =>
      AnimationView(
        frame ?? this.frame,
        radioPanels ?? this.radioPanels,
      );

  int getRadioPanelSize() {
    const panelIndexSize = UINT_8_SIZE_IN_BYTES;
    const color = UINT_8_SIZE_IN_BYTES * 3;
    return panelIndexSize + color;
  }

  List<RadioColorFrame> getRadioColorFrames(
      [Duration duration = Duration.zero]) {
    final allPanelsSameColor = radioPanels.isNotEmpty &&
        radioPanels.every((panel) => panel.color == radioPanels.first.color);
    if (allPanelsSameColor) {
      /// We can set colors of all panels via single frame
      return [RadioColorFrame(duration, 0, radioPanels.first.color)];
    } else {
      return radioPanels.map((panel) => panel.toRadioColorFrame()).toList();
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
    final messageTypeSize = UINT_8_SIZE_IN_BYTES;
    final viewSize = messageTypeSize + frameSize + radioPanelsSize;

    final writter = Writer(viewSize, endian);

    // Set message type
    writter.writeSerialMessageType(SerialMessageTypes.displayView);

    /// frame pixels
    final pixels = frame.pixels;
    for (var i = 0; i < pixels.length; i++) {
      writter.writeColor(pixels[i]);
    }

    /// encode radio panels
    for (var i = 0; i < radioPanels.length; i++) {
      final radioPanelView = radioPanels[i];

      writter
        ..writeUint8(radioPanelView.index)
        ..writeColor(radioPanelView.color);
    }

    return writter.bytes;
  }

  @override
  List<Object?> get props => [frame, radioPanels];
}
