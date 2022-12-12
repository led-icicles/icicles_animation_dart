import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:icicles_animation_dart/src/frames/additive_frame_rgb565.dart';
import 'package:icicles_animation_dart/src/utils/progress_bar.dart';
import 'package:path/path.dart' as p;

export 'animation_header.dart';
export 'animation_view.dart';

enum Framerate {
  fps60(60),
  fps30(30),
  fps24(24);

  final int framesPerSecond;

  Duration get interFrameDuration =>
      Duration(milliseconds: (1000 / framesPerSecond).floor());

  const Framerate(this.framesPerSecond);
}

enum FramerateBehavior {
  error,
  drop,
}

void debugPrint(String msg) {
  if (!stdout.hasTerminal) return;
  print(msg);
}

class Animation {
  final _frames = <Frame>[];
  List<Frame> get frames {
    return List.unmodifiable(_frames);
  }

  AnimationHeader get header => _header;
  final AnimationHeader _header;

  /// Current pixels view
  AnimationView get currentView => _currentView;
  AnimationView _currentView;

  /// View that was buffered but not yet displayed
  /// This is used together with [FramerateBehavior.drop].
  AnimationView get bufferedView => _bufferedView;
  AnimationView _bufferedView;

  final bool optimize;
  final bool useRgb565;
  final Framerate framerate;
  final FramerateBehavior framerateBehavior;

  Iterable<AnimationView> play() sync* {
    final intialFrame = VisualFrame.filled(
      Duration.zero,
      header.pixelsCount,
      Colors.black,
    );

    // radio panels indexes starts from 1 (0 is a broadcast channel)
    final radioPanels = List<RadioPanelView>.generate(header.radioPanelsCount,
        (index) => RadioPanelView(index + 1, Colors.black));

    var loop = 0;
    while (loop++ < header.loopsCount) {
      var view = AnimationView(intialFrame, radioPanels);

      for (final frame in _frames) {
        if (frame is VisualFrame) {
          view = view.copyWith(frame: frame);
          yield view;
        } else if (frame is DelayFrame) {
          view = view.copyWith(
            frame: view.frame.copyWith(duration: frame.duration),
          );

          yield view;
        } else if (frame is AdditiveFrame) {
          view = view.copyWith(
            frame: frame.mergeOnto(view.frame),
          );
          yield view;
        } else if (frame is RadioColorFrame) {
          view = view.copyWith(
            frame: view.frame.copyWith(duration: frame.duration),
            radioPanels: view.radioPanels.map((panel) {
              if (frame.isBroadcast || frame.panelIndex == panel.index) {
                return panel.copyWith(color: frame.color);
              } else {
                return panel;
              }
            }).toList(),
          );
          if (frame.duration != Duration.zero) {
            yield view;
          }
        } else {
          throw UnsupportedError('Unsupported frame type: "${frame.type}"');
        }
      }
    }
    yield AnimationView(intialFrame, radioPanels);
  }

  Animation(
    String name, {
    required int xCount,
    required int yCount,
    this.optimize = true,
    this.useRgb565 = false,
    this.framerate = Framerate.fps30,
    this.framerateBehavior = FramerateBehavior.error,
    int loopsCount = 1,
    int versionNumber = NEWEST_ANIMATION_VERSION,
    int radioPanelsCount = 0,
  })  : _header = AnimationHeader(
          name: name,
          xCount: xCount,
          yCount: yCount,
          loopsCount: loopsCount,
          versionNumber: versionNumber,
          radioPanelsCount: radioPanelsCount,
        ),

        /// Before each animation leds are set to black color.
        /// But black color is not displayed. To set all pixels to black,
        /// you should add frame, even [DelayFrame]
        _currentView = _initView(xCount, yCount, radioPanelsCount),
        _bufferedView = _initView(xCount, yCount, radioPanelsCount);

  static AnimationView _initView(int xCount, int yCount, int radioPanelsCount) {
    return AnimationView(
      VisualFrame(
        /// zero duration - this is just a placeholder
        Duration.zero,
        List.filled(xCount * yCount, Colors.black),
      ),
      List<RadioPanelView>.generate(
        radioPanelsCount,
        (index) => RadioPanelView(index + 1, Colors.black),
      ),
    );
  }

  /// Add frame to the animation without optimization
  bool _addFrame(Frame frame) {
    _frames.add(frame);
    _updateView(frame);
    return true;
  }

  bool _replaceLastFrame(Frame frame) {
    _frames.last = frame;
    _updateView(frame);
    return true;
  }

  /// Updates [currentView] and the [bufferedView].
  void _updateView(Frame frame) {
    _currentView = _currentView.copyApplied(frame);
    _bufferedView = _currentView;
  }

  void _updateBufferedView(Frame frame) {
    _bufferedView = _bufferedView.copyApplied(frame);
  }

  bool _addDelayFrame(Frame frame, {bool optimize = true}) {
    /// _addDelayFrame accepts all frames, therefore it is required
    /// To convert the provided frame to the DelayFrame.
    if (frame is! DelayFrame) {
      frame = DelayFrame.fromFrame(frame);
    }

    if (optimize) {
      /// Nothing to add
      if (frame.duration == Duration.zero) {
        return false;
      }

      final prevFrame = _frames.lastOrNull;

      /// Previous frame does not exist
      if (prevFrame == null) {
        return _addFrame(frame);
      }
      final mergedDuration = frame.duration + prevFrame.duration;

      /// It is not possible to increase the delay of the previous frame
      if (mergedDuration > Frame.maxDuration) {
        return _addFrame(frame);
      }

      final mergedFrame = prevFrame.copyWith(duration: mergedDuration);

      /// Override the last frame with new merged one
      _replaceLastFrame(mergedFrame);
      return false;
    } else {
      return _addFrame(frame);
    }
  }

  bool _addVisualFrame(VisualFrame frame, {bool optimize = true}) {
    if (frame.pixels.length != _header.pixelsCount) {
      throw ArgumentError(
        'Unsupported frame length. '
        'Current: ${frame.pixels.length}, '
        'required: ${_header.pixelsCount}',
      );
    }

    if (useRgb565 && frame is! VisualFrameRgb565) {
      frame = VisualFrameRgb565.fromVisualFrame(frame);
    } else if (!useRgb565 && frame is VisualFrameRgb565) {
      frame = frame.toVisualFrame();
    }

    /// No optimization, just add the frame
    if (!optimize) {
      return _addFrame(frame);
    }

    final prevFrame = _frames.lastOrNull;
    if (prevFrame == null) {
      return _addFrame(frame);
    }

    final changedPixels = AdditiveFrame.getChangedPixelsFromFrames(
      currentView.frame,
      frame,
    );

    /// No pixels are changed, add only a duration of this frame.
    if (changedPixels.isEmpty) {
      return _addDelayFrame(frame);
    }

    final additiveFrame = useRgb565
        ? AdditiveFrameRgb565(
            frame.duration,
            changedPixels,
          )
        : AdditiveFrame(
            frame.duration,
            changedPixels,
          );

    final isAdditiveFrameSmaller = additiveFrame.size < frame.size;
    if (isAdditiveFrameSmaller) {
      return _addAdditiveFrame(additiveFrame);
    } else {
      return _addFrame(frame);
    }
  }

  bool _addAdditiveFrame(AdditiveFrame frame, {bool optimize = true}) {
    if (useRgb565 && frame is! AdditiveFrameRgb565) {
      frame = AdditiveFrameRgb565.fromAdditiveFrame(frame);
    } else if (!useRgb565 && frame is AdditiveFrameRgb565) {
      frame = frame.toAdditiveFrame();
    }

    if (!optimize) {
      return _addFrame(frame);
    }

    final newView = frame.mergeOnto(currentView.frame);

    final changedPixels = AdditiveFrame.getChangedPixelsFromFrames(
      currentView.frame,
      newView,
    );

    /// No visual changes, add the frame duration
    if (changedPixels.isEmpty) {
      return _addDelayFrame(frame);
    }

    /// Frame has larger duration than zero
    if (frame.duration > Duration.zero) {
      return _addFrame(frame);
    }

    final prevFrame = _frames.lastOrNull;

    /// If prev frame is null, cannot optimize just push add the frame
    if (prevFrame == null) {
      return _addFrame(frame);
    }

    if (prevFrame is VisualFrame) {
      _replaceLastFrame(frame.mergeOnto(prevFrame));
      return false;
    } else if (prevFrame is AdditiveFrame) {
      _replaceLastFrame(prevFrame.mergeWith(frame));
      return false;
    } else if (prevFrame is DelayFrame) {
      final mergedDuration = prevFrame.duration + frame.duration;
      if (mergedDuration > Frame.maxDuration) {
        return _addFrame(frame);
      }

      final mergedFrame = frame.copyWith(duration: mergedDuration);
      return _addFrame(mergedFrame);
    } else {
      return _addFrame(frame);
    }
  }

  bool _addRadioColorFrame(RadioColorFrame frame, {bool optimize = true}) {
    if (frame.panelIndex > header.radioPanelsCount) {
      throw ArgumentError(
        'Invalid panel index (${frame.panelIndex}). '
        'This animation supports "${header.radioPanelsCount}" radio panels.',
      );
    }

    if (!optimize) {
      return _addFrame(frame);
    }

    if (frame.isBroadcast) {
      final isChanged = currentView.radioPanels.any(
        (p) => p.color != frame.color,
      );

      if (!isChanged) {
        /// Colors not changed, add delay frame
        return _addDelayFrame(frame);
      } else {
        /// Colors changed
        return _addFrame(frame);
      }
    } else {
      final radioPanelView = currentView.radioPanels.firstWhere(
        (p) => p.index == frame.panelIndex,
        orElse: () => throw ArgumentError(
          'Panel with provided index (${frame.panelIndex}) does not exist.',
        ),
      );
      final isChanged = radioPanelView.color != frame.color;

      if (!isChanged) {
        /// Colors not changed, add delay frame
        return _addDelayFrame(frame);
      } else {
        /// Colors changed
        return _addFrame(frame);
      }
    }
  }

  /// When [framerateBehavior] is set to [FramerateBehavior.drop], this
  /// determines whether a frame can be accepted if its duration
  /// is less than supported.
  Duration _durationFromPrevFrame = Duration.zero;

  /// Asserts valid framerate.
  /// If [framerateBehavior] is set to [FramerateBehavior.error],
  /// an error will be thrown if [framerate] is lower than the duration of
  /// the interrupt.
  ///
  /// For [framerateBehavior] set to [FramerateBehavior.drop],
  /// this method will return true if the frame can be saved,
  /// or false for dropping it
  Frame? _assertValidFramerate(Frame frame) {
    /// Radio color frame with duration set to zero is changing the radio panels
    /// color state without displaying it
    if (frame is RadioColorFrame && frame.duration == Duration.zero) {
      return frame;
    }

    final minInterframeDuration = framerate.interFrameDuration;

    switch (framerateBehavior) {
      case FramerateBehavior.error:
        if (frame.duration < minInterframeDuration) {
          throw UnsupportedError(
            'The maximum animation framerate is set to ${framerate.name}, '
            'therefore, the minimum animation display duration is '
            '${minInterframeDuration.inMilliseconds}ms. '
            'Construct an animation class with the "framerate" argument set to '
            'a higher value, reduce the frame display duration or set the '
            '"framerateBehavior" argument to [FramerateBehavior.drop] in order '
            'to drop overframes.',
          );
        } else {
          return frame;
        }
      case FramerateBehavior.drop:
        final cumulativeDuration = _durationFromPrevFrame + frame.duration;
        final acceptFrame = cumulativeDuration >= minInterframeDuration;
        if (!acceptFrame) {
          _durationFromPrevFrame += frame.duration;

          /// The frame is dropped, but the current view must be updated
          /// to properly display the animation.
          _updateBufferedView(frame);

          return null;
        } else {
          _durationFromPrevFrame = Duration.zero;

          if (bufferedView == currentView) {
            return frame;
          } else {
            _updateBufferedView(frame);
            final view = bufferedView;

            /// Process buffered frame and add it instead of the current frame
            view.radioPanels
                .map((radioPanelView) => radioPanelView.toRadioColorFrame())
                .forEach((radioFrame) => addFrame(radioFrame));
            addFrame(view.frame.copyWith(duration: cumulativeDuration));

            return null;
          }
        }
    }
  }

  /// Returns true, when new frame was added.
  bool addFrame(Frame frame) {
    final acceptedFrame = _assertValidFramerate(frame);

    if (acceptedFrame == null) {
      _updateBufferedView(frame);
      return false;
    }

    if (acceptedFrame is DelayFrame) {
      return _addDelayFrame(acceptedFrame, optimize: optimize);
    } else if (acceptedFrame is VisualFrame) {
      return _addVisualFrame(acceptedFrame, optimize: optimize);
    } else if (acceptedFrame is AdditiveFrame) {
      return _addAdditiveFrame(acceptedFrame, optimize: optimize);
    } else if (acceptedFrame is RadioColorFrame) {
      return _addRadioColorFrame(acceptedFrame, optimize: optimize);
    } else {
      throw UnsupportedError(
        'Provided frame type (${frame.runtimeType}) is not supported.',
      );
    }
  }

  /// Animation duration - loops are not included
  Duration get duration {
    return (_frames.fold(Duration.zero, (p, n) => p + n.duration));
  }

  /// Animation frames count - loops are not included
  int get frameCount {
    return _frames.length;
  }

  /// Animation size in bytes
  int get size {
    return _frames.fold(
        header.size, (currentSize, frame) => currentSize + frame.size);
  }

  Uint8List toBytes([Endian endian = Endian.little]) {
    if (_frames.isEmpty) {
      throw StateError('Animation is empty.');
    }
    final writter = Writer(size, endian)..writeEncodable(_header);

    for (final frame in _frames) {
      writter.writeEncodable(frame);
    }

    return writter.bytes;
  }

  Future<File> toFile(String path) async {
    final toFileWatch = Stopwatch()..start();
    debugPrint('Creating animation file: optimize=$optimize');

    final targetPath = p.absolute(path);

    final file = await File(targetPath).create(recursive: true);

    final sink = file.openWrite(mode: FileMode.write);

    debugPrint('Encoding ${_frames.length} frames...');
    final bar = ProgressBar();
    bar.render(0);

    try {
      sink.add(_header.toBytes());
      await sink.flush();

      for (var i = 0; i < _frames.length; i++) {
        final frame = _frames[i];

        final Uint8List bytes;

        if (useRgb565) {
          if (frame is VisualFrame) {
            bytes = VisualFrameRgb565.fromVisualFrame(frame).toBytes();
          } else if (frame is AdditiveFrame) {
            bytes = AdditiveFrameRgb565.fromAdditiveFrame(frame).toBytes();
          } else {
            bytes = frame.toBytes();
          }
        } else {
          bytes = frame.toBytes();
        }

        sink.add(bytes);
        bar.render(i / _frames.length);
      }
      bar.done();
      debugPrint('Writing to file...');
      await sink.flush();
      await sink.close();

      toFileWatch.stop();

      final duration = _frames.fold(Duration.zero, (s, e) => s + e.duration);

      debugPrint(
        'Written ${_frames.length} frames with overall '
        'size of ${(size / 1000).toStringAsFixed(2)}KB '
        'and duration of ${duration.inSeconds}s '
        'in ${toFileWatch.elapsedMilliseconds}ms.',
      );

      return file;
    } catch (err) {
      bar.done();
      await sink.close();
      await file.delete();
      rethrow;
    }
  }

  static Future<Animation> fromFile(String path) async {
    final bytes = await File(path).readAsBytes();
    return Animation.fromBytes(bytes);
  }

  factory Animation.fromBytes(
    Uint8List bytes, [
    Endian endian = Endian.little,
  ]) {
    final startWatch = Stopwatch()..start();

    final reader = Reader(bytes, endian);

    final header = AnimationHeader.fromReader(reader);

    final animation = Animation(
      header.name,
      xCount: header.xCount,
      yCount: header.yCount,
      loopsCount: header.loopsCount,
      radioPanelsCount: header.radioPanelsCount,
      optimize: false,
      useRgb565: false,
      versionNumber: header.versionNumber,
    );

    final pixelsCount = header.pixelsCount;

    while (reader.hasMoreData) {
      final frameType = reader.readFrameType();
      switch (frameType) {
        case FrameType.VisualFrame:
          animation.addFrame(VisualFrame.fromReader(
            reader,
            pixelsCount,
            withType: false,
          ));

          break;
        case FrameType.VisualFrameRgb565:
          animation.addFrame(VisualFrameRgb565.fromReader(
            reader,
            pixelsCount,
            withType: false,
          ));

          break;
        case FrameType.DelayFrame:
          animation.addFrame(DelayFrame.fromReader(
            reader,
            withType: false,
          ));

          break;
        case FrameType.RadioColorFrame:
          animation.addFrame(RadioColorFrame.fromReader(
            reader,
            withType: false,
          ));
          break;
        case FrameType.AdditiveFrame:
          animation.addFrame(AdditiveFrame.fromReader(
            reader,
            withType: false,
          ));
          break;
        case FrameType.AdditiveFrameRgb565:
          animation.addFrame(AdditiveFrameRgb565.fromReader(
            reader,
            withType: false,
          ));
          break;
        default:
          throw UnsupportedError('Unsupported frame type: "$frameType"');
      }
    }

    startWatch.stop();

    debugPrint(
      'Decoded ${animation._frames.length} frames '
      'of size ${(animation.size / 1000).toStringAsFixed(2)}KB in ${startWatch.elapsedMilliseconds}ms',
    );

    return animation;
  }

  void clear() {
    _frames.clear();
  }
}
