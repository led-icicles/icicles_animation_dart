import 'dart:io';
import 'dart:math' as math;

class ProgressBar {
  final int size;

  ProgressBar([this.size = 30]);

  Stopwatch? stoper;

  bool get isActive => stoper != null;

  void render(double progress, {bool force = false}) {
    if (!stdout.hasTerminal) return;

    if (isActive) {
      if (!force && stoper!.elapsedMilliseconds < 100) {
        return;
      } else {
        stoper!.reset();
      }

      for (var i = 0; i < stdout.terminalColumns; i++) {
        stdout.writeCharCode(8); // output backspace
      }
    } else {
      stoper = Stopwatch()..start();
    }

    final accesoriesLength = 8;

    final targetSize = math.min(
      stdout.terminalColumns - accesoriesLength,
      size,
    );

    final buffer = StringBuffer();
    final barSegments = (targetSize * progress).floor();
    for (var i = 0; i < barSegments; i++) {
      buffer.write('█');
    }
    for (var i = 0; i < targetSize - barSegments; i++) {
      buffer.write('░');
    }

    buffer.write(' ');
    final percent = (progress * 100).toStringAsFixed(2).padRight(6);
    buffer.write(percent);
    buffer.write('%');
    stdout.write(buffer.toString());
  }

  void done() {
    if (!stdout.hasTerminal) return;
    render(1.0, force: true);
    stdout.writeln();
    stoper?.stop();
    stoper = null;
  }
}
