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
