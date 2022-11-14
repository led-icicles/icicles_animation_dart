import 'dart:io';
import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:icicles_animation_dart/src/frames/additive_frame_rgb565.dart';
import 'package:path/path.dart' as p;

import 'animation_header.dart';
import 'animation_view.dart';

class Animation {
  final _frames = <Frame>[];
  List<Frame> get frames {
    return List.unmodifiable(_frames);
  }

  final AnimationHeader _header;
  AnimationHeader get header {
    return _header;
  }

  /// Current pixels view
  VisualFrame _currentView;
  VisualFrame get currentView {
    return _currentView;
  }

  final bool optimize;
  final bool useRgb565;

  final List<RadioPanelView> _radioPanels;

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
        _radioPanels = List<RadioPanelView>.generate(radioPanelsCount,
            (index) => RadioPanelView(index + 1, Colors.black)),

        /// Before each animation leds are set to black color.
        /// But black color is not displayed. To set all pixels to black,
        /// you should add frame, even [DelayFrame]
        _currentView = VisualFrame(
          /// zero duration - this is just a placeholder
          Duration.zero,
          List.filled(xCount * yCount, Colors.black),
        );

  void addFrame(Frame newFrame) {
    if (newFrame is DelayFrame) {
      _frames.add(newFrame);
      return;
    } else if (newFrame is RadioColorFrame) {
      if (newFrame.panelIndex > header.radioPanelsCount) {
        throw ArgumentError('Invalid panel index (${newFrame.panelIndex}). '
            'This animation supports "${header.radioPanelsCount}" radio panels.');
      }
      if (optimize) {
        final isChanged = newFrame.isBroadcast
            ? _radioPanels.any((p) => p.color != newFrame.color)
            : _radioPanels
                    .firstWhere((p) => p.index == newFrame.panelIndex,
                        orElse: () => throw ArgumentError(
                            'Panel with provided index (${newFrame.panelIndex}) does not exist.'))
                    .color !=
                newFrame
                    .color; // panel index is shifted due to broadcast panel at index 0
        if (!isChanged) {
          if (newFrame.duration == Duration.zero) {
            print('[OPTIMIZE] Skipping radio frame. '
                'No color changes. '
                'Size reduced by ${newFrame.size}B.');
            return;
          } else {
            final delayFrame = DelayFrame(newFrame.duration);
            print(
                '[OPTIMIZE] No changes, replacing radio frame with delay frame. Size reduced by ${newFrame.size - delayFrame.size}B.');
            _frames.add(delayFrame);
            return;
          }
        } else {
          if (newFrame.isBroadcast) {
            for (var i = 0; i < _radioPanels.length; i++) {
              _radioPanels[i] = _radioPanels[i].copyWith(
                color: newFrame.color,
              );
            }
          } else {
            // shift index due to broadcast panel at 0
            _radioPanels[newFrame.panelIndex - 1] =
                _radioPanels[newFrame.panelIndex - 1]
                    .copyWith(color: newFrame.color);
          }
          _frames.add(newFrame);
          return;
        }
      } else {
        _frames.add(newFrame);
      }
      return;
    } else if (newFrame.duration < const Duration(milliseconds: 16)) {
      throw ArgumentError(
          'The animation can\'t run faster than 60 FPS (preferred: 30 FPS). '
          'Therefore, the inter-frame delay cannot be less than 16ms.');
    } else if (newFrame is AdditiveFrameRgb565 ||
        newFrame is VisualFrameRgb565) {
      // TODO: optimize
      _frames.add(newFrame);
      return;
    } else if (newFrame is AdditiveFrame) {
      // TODO: optimize
      _frames.add(newFrame);
      return;
    } else if (newFrame is! VisualFrame) {
      throw ArgumentError('Unsupported frame type.');
    } else if (newFrame.pixels.length != _header.ledsCount) {
      throw ArgumentError('Unsupported frame length. '
          'Current: ${newFrame.pixels.length}, '
          'required: ${_header.ledsCount}');
    }

    if (optimize) {
      final changedPixels = AdditiveFrame.getChangedPixelsFromFrames(
        _currentView,
        newFrame,
      );

      final noPixelsChanges = changedPixels.isEmpty;

      if (noPixelsChanges) {
        /// TODO: We can then merge delay frames if possible.
        _frames.add(DelayFrame(newFrame.duration));
      } else {
        final additiveFrame = AdditiveFrame(
          newFrame.duration,
          changedPixels,
        );
        final isAdditiveFrameSmaller = additiveFrame.size < newFrame.size;
        if (isAdditiveFrameSmaller) {
          _frames.add(additiveFrame);
        } else {
          _frames.add(newFrame);
        }
      }
    } else {
      _frames.add(newFrame);
    }

    /// set current view
    _currentView = newFrame;
  }

  /// Animation duration - loops are not included
  Duration get duration {
    return (_frames.fold(Duration.zero, (p, n) => p + n.duration));
  }

  /// Animation frames count - loops are not included
  int get animationFramesCount {
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
    print('Creating animation file: optimize=$optimize');

    final targetPath = p.absolute(path);

    final file = await File(targetPath).create(recursive: true);

    final sink = file.openWrite(mode: FileMode.write);

    try {
      print('===== HEADER =====');
      print('Writing header...');
      sink.add(_header.toBytes());
      await sink.flush();

      print('Header written.');
      print('=== END HEADER ===');

      print('Writing ${_frames.length} frames...');

      final framesWatch = Stopwatch()..start();

      for (final frame in _frames) {
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
      }
      await sink.flush();
      await sink.close();

      framesWatch.stop();

      print('All frames written in ${framesWatch.elapsedMilliseconds}ms.');

      toFileWatch.stop();

      print(
          'frames count: ${_frames.length}, size: ${(size / 1000).toStringAsFixed(2)} KB');
      print(
          'File written in ${toFileWatch.elapsedMilliseconds}ms.  path="$targetPath".');

      return file;
    } catch (err) {
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
    final header = AnimationHeader.fromBytes(bytes);

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

    final reader = Reader(bytes, endian);

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

    print(
      'frames count: ${animation._frames.length}, '
      'size: ${(animation.size / 1000).toStringAsFixed(2)}KB',
    );

    return animation;
  }

  void clear() {
    _frames.clear();
  }
}
