import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:test/test.dart';

import '../compat/compat_helpers.dart';

Animation sameSetup(Animation source) => Animation(
      're-encoded',
      xCount: source.header.xCount,
      yCount: source.header.yCount,
      version: source.header.version,
      loopsCount: source.header.loopsCount,
      radioPanelsCount: source.header.radioPanelsCount,
      radioPanelPixelCount: source.header.radioPanelPixelCount,
      optimize: source.optimize,
      useRgb565: source.useRgb565,
      framerate: source.framerate,
      framerateBehavior: source.framerateBehavior,
    );

List<List<Color>> stateOf(Icicles icicles) => [
      icicles.strip.toList(),
      for (final panel in icicles.radioPanels) panel.toList(),
    ];

void main() {
  group('setView', () {
    for (final scenario in scenarios) {
      test('${scenario.name}: re-encoding the views keeps them', () {
        final source = scenario.build();
        final target = sameSetup(source);
        final icicles = Icicles(target);
        for (final view in source.toIndex().views) {
          icicles
            ..setView(view)
            ..show(view.frame.duration);
        }

        expect(target.toIndex().views, source.toIndex().views);
      });
    }

    Animation panels() => Animation('x',
        xCount: 2, yCount: 2, radioPanelsCount: 2, radioPanelPixelCount: 3);

    AnimationView viewOf({
      int pixels = 4,
      List<int> panelIndexes = const [1, 2],
      int panelPixels = 3,
    }) =>
        AnimationView(
          VisualFrame.filled(ms(100), pixels, Colors.red),
          [
            for (final index in panelIndexes)
              RadioPanelView(index, List.filled(panelPixels, Colors.blue)),
          ],
        );

    test('rejects an invalid view without changes', () {
      final icicles = Icicles(panels());
      final before = stateOf(icicles);

      expect(() => icicles.setView(viewOf(pixels: 3)), throwsArgumentError);
      expect(() => icicles.setView(viewOf(panelIndexes: [1])),
          throwsArgumentError);
      expect(
          () => icicles.setView(viewOf(panelPixels: 2)), throwsArgumentError);
      expect(() => icicles.setView(viewOf(panelIndexes: [1, 3])),
          throwsRangeError);
      expect(stateOf(icicles), before);
    });

    test('sets the pixels and panels by index', () {
      final icicles = Icicles(panels());
      icicles.setView(AnimationView(
        VisualFrame.filled(ms(100), 4, Colors.red),
        [
          RadioPanelView(2, List.filled(3, Colors.green)),
          RadioPanelView(1, List.filled(3, Colors.blue)),
        ],
      ));

      expect(stateOf(icicles), [
        List.filled(4, Colors.red),
        List.filled(3, Colors.blue),
        List.filled(3, Colors.green),
      ]);
    });

    test('respects masks', () {
      final icicles = Icicles(panels());
      final stripMask = PixelsView.filled(Size(2, 2), Colors.white)
        ..setPixel(0, Colors.transparent);
      final panelMask = PixelsView.filled(Size(3, 1), Colors.white)
        ..setPixel(2, Colors.transparent);
      icicles.withMask(stripMask, [panelMask, panelMask]).setView(viewOf());

      expect(stateOf(icicles), [
        [Colors.black, Colors.red, Colors.red, Colors.red],
        [Colors.blue, Colors.blue, Colors.black],
        [Colors.blue, Colors.blue, Colors.black],
      ]);
    });
  });
}
