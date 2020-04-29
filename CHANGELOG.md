# 2.0.0

## Breaking change

Instead of passing all the options to the `CarouselSlider`, now you'll need to pass these option to `CarouselOptions`:

```dart
CarouselSlider(
  CarouselOptions(height: 400.0),
  items: [1,2,3,4,5].map((i) {
    return Builder(
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            color: Colors.amber
          ),
          child: Text('text $i', style: TextStyle(fontSize: 16.0),)
        );
      },
    );
  }).toList(),
)
```

## Add

- `CarouselController`

Since `v2.0.0`, `carousel_slider` plugin provides a way to pass your own `CaourselController`, and you can use `CaouselController` instance to manually control the carousel's position. For a more detailed example please refer to [example project](example/lib/main.dart).

- `CarouselPageChangedReason`

Now you can receive a `CarouselPageChangedReason` in `onPageChanged` callback.

## Remove

- `pauseAutoPlayOnTouch`

`pauseAutoPlayOnTouch` option is removed, because it doesn't fix the problem we have. Currently, when we enable the `autoPlay` feature, we can not stop sliding when the user interact with the carousel. This is [a flutter's issue](https://github.com/flutter/flutter/issues/54875).

# 1.4.1

## Fix

- Fix `animateTo()/jumpTo()` with non-zero initialPage

# 1.4.0

## Add

- Add on-demand item feature

## Fix

- Fix `setState() called after dispose()` bug

# 1.3.1

## Add

- Scroll physics option

## Fix

- onPage indexing bug


# 1.3.0

## Deprecation

- Remove the deprecated param: `interval`, `autoPlayDuration`, `distortion`, `updateCallback`. Please use the new param.

## Fix

-  Fix `enlargeCenterPage` option is not working in `vertical` carousel slider.

# 1.2.0

## Add

- Vertical scroll support
- Enable/disable infinite scroll

# 1.1.0

## Add

- Added `pauseAutoPlayOnTouch` option
- Add documentation

# 1.0.1

## Add

- Update doc

# 1.0.0

## Add

- Added `distortion` option


# 0.0.6

## Fix

- Fix hard coded number

# 0.0.5

## Fix

- Fix `initialPage` bug, fix crash when widget is disposed.


# v0.0.2

Remove useless dependencies, add changelog.

# v0.0.1

Initial version.
