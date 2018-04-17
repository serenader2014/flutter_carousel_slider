# carousel_slider

A carousel slider widget, support infinite scroll and custom child widget.

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
  height: 400.0
)
```

For a more detail example please take a look at the `example` folder.

![screenshot](./example/screenshot.gif)

## Params

```dart
new CarouselSlider(
  items: items,
  viewportFraction: viewportFraction,
  initialPage: initialPage,
  aspectRatio: aspectRatio,
  height: height
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