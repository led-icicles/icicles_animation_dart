import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';

enum SerialMessageTypes {
  // ignore: slash_for_doc_comments
  /**
   * Keep leds aware of ongoing serial communication.
   *
   * Built-in animations are stopped.
   */
  ping(0),

  // display following frame
  displayView(1),

  /// End serial communication and start playing built-in animations
  end(10);

  final int value;

  const SerialMessageTypes(this.value);
}

class RadioPanelView {
  final int index;
  final Color color;

  RadioPanelView(this.index, this.color);

  RadioPanelView copyWith({
    int? index,
    Color? color,
  }) =>
      RadioPanelView(index ?? this.index, color ?? this.color);
}

/// Class used for serial communication,
/// represents the current icicles state
class AnimationView {
  final VisualFrame frame;
  final List<RadioPanelView> radioPanels;

  AnimationView(
    this.frame,
    this.radioPanels,
  );

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
}
