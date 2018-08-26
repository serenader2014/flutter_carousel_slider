# carousel_slider

A carousel slider widget, support infinite scroll and custom child widget, with autoplay feature.

## Installation

Add `carousel_slider: ^0.0.6` in your `pubspec.yaml` dependencies.

## How to use

Simply create a `CarouselSlider` widget, and pass the required params:

```dart
new CarouselSlider(
  items: [1,2,3,4,5].map((i) {
    return new Builder(
      builder: (BuildContext context) {
        return new Container(
          width: MediaQuery.of(context).size.width,
          margin: new EdgeInsets.symmetric(horizontal: 5.0),
          decoration: new BoxDecoration(
            color: Colors.amber
          ),
          child: new Text('text $i', style: new TextStyle(fontSize: 16.0),)
        );
      },
    );
  }).toList(),
  height: 400.0,
  autoPlay: true
)
```

For a more detail example please take a look at the `example` folder.

![screenshot](./example/screenshot.gif)

## Params

```dart
new CarouselSlider(
  items: items,
  viewportFraction: 0.8,
  initialPage: 0,
  aspectRatio: 16/9,
  height: 400,
  reverse: false,
  autoPlay: false,
  interval: const Duration(seconds: 4),
  autoPlayCurve: Curves.fastOutSlowIn,
  autoPlayDuration: const Duration(milliseconds: 800),
  updateCallback: someFunction
)
```

You can pass the above params to the class. If you pass the `height` params, the `aspectRatio` param will be ignore.

## Instance methods

You can use the instance methods to programmatically take control of the pageView's position.

### `.nextPage({Duration duration, Curve curve})`

Animate to the next page

### `.previousPage({Duration duration, Curve curve})`

Animate to the previous page

### `.jumpToPage(int page)`

Jump to the given page.

### `.animateToPage(int page, {Duration duration, Curve curve})`

Animate to the given page.