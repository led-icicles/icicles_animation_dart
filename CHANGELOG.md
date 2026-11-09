## 3.2.0

Generated animations are byte-identical to 3.1.0.

- Added _AnimationIndex_ (`Animation.toIndex()`): views of a single pass with `viewAt(time)`.
- Added `Framerate.frameStart`/`frameDuration`: a fixed-step timeline in whole milliseconds, without drift.
- Added `AnimationHeader.hasSameLayout`.
- Added `Icicles.setView`.
- Added _BlendMode_ and `Color.composite`.

## 3.1.0

Generated animations are byte-identical to 3.0.0.

- `play()` plays an infinite animation (`loopsCount: 0`) once, or `infiniteLoopsLimit` times.
- An animation uses a single color format: `fromBytes` detects RGB565, `toBytes`/`toFile` accept `useRgb565`.
- _AdditiveFrameRgb565.toAdditiveFrame_ returns an RGB888 frame.
- Out of range `x`/`y` coordinates throw `RangeError` instead of addressing another pixel.
- Fixed _IndexedColor.blend_.
- `fromBytes`, `debugPrint` and _ProgressBar_ work without `stdout` (web).
- Exported _CurveTween_.
- Drop framerate no longer throws when a frame exceeds `Frame.maxDuration`.
- Cached `Animation.frames`.
- Documentation fixes, `lints` 6.

## 3.0.0

- **Breaking:** _Icicles_ uses _PixelsView_: `pixels` replaced by `strip`, `xCount`/`yCount` by `size`.
- **Breaking:** _Icicles_ radio panel indexes start from 0.
- Added masks: _PixelsView.withMask_, _Icicles.withMask_.
- Translucent colors are encoded blended with black (RGB888 and RGB565).
- Fixed RGB565 animations failing after a pause, a leading delay or radio frames.
- Negative frame durations and names containing NUL are rejected.
- Rejected frames are no longer stored; `clear()` resets the current view.
- v1 _RadioVisualFrame_ with identical colors is stored as _RadioColorFrame_.
- Fixed examples.

## 2.0.1

- Fixed radio panels issues.
- Copy color values of _RadioVisualFrame_

## 1.4.0

- Updated package dependencies
- Added helper methods.
- Improved types naming.
- Exposed _BackCurve_ and _ElasticCurve_ constructors.
- Removed equatable package.

## 1.3.3

- Updated package dependencies
- Improved constant naming

## 1.3.2

- Added _blendAllPixels_, _darken_ and _lighten_ methods to the _Icicles_ class.
- Added _darken_, _lighten_ and _blend_ method to the _Color_ class.

## 1.3.1

- Added _Colors.all_ getter.
- Added _Colors.random()_ method.
- Added check for empty animation when calling _Animation.toFile_ method.

## 1.3.0

- Added _Tween_, _ColorTween_, _NumberTween_ and _CurveTween_ interpolation classes.
- Added abstract _Curve_ class.
- Added _Curves_ class and implemented basic curves.
- Fixed _Icicles.setRowColor_ method.
- Added _Framerate.fps45_ value.

## 1.2.0

- Improved the icicles class documentation.
