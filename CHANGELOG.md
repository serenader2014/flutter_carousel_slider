# v0.0.1

Initial version.

# v0.0.2

Remove useless dependencies, add changelog.

# 0.0.5

Fix `initialPage` bug, fix crash when widget is disposed.

# 0.0.6

Fix hard coded number

# 1.0.0

Added `distortion` option

# 1.0.1

Update doc

# 1.1.0

Added `pauseAutoPlayOnTouch` option

Sets a timer on touch detected that pause the auto play with the given `Duration`.
Touch Detection is only active if the `autoPlay` property is set to true.
If screen is touched again during the time out the timer is reset to the given duration.

Added documentation to public properties.

Refactored ambiguous property names and deprecated the old ones.

Updated example project displaying the new feature and refactored the code to follow flutters style guidelines.

Updated .readme

# 1.2.0

Introducing two new features,
Vertical scroll and enable/disable infinite scroll .

Pass an `Axis` as the `scrollDirection` argument to specify direction.  
Use `enableInfiniteScroll` to toggle between finite and infinite scroll mode.
When `enableInfiniteScroll` is set to `false` the carousel will not scroll past the first or last item.

# 1.3.0

## Breaking change

- Remove the deprecated param: `interval`, `autoPlayDuration`, `distortion`, `updateCallback`. Please use the new param.

## Bugfix

-  Fix `enlargeCenterPage` option is not working in `vertical` carousel slider.

## 1.3.1

Fixed onPage indexing bug

Added scroll physics option