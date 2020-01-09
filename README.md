# carousel_slider

A carousel slider widget, support infinite scroll and custom child widget, with auto play feature.

## Installation

Add `carousel_slider: ^1.3.0` in your `pubspec.yaml` dependencies. And import it:

```dart
import 'package:carousel_slider/carousel_slider.dart';
```

## How to use

Simply create a `CarouselSlider` widget, and pass the required params:

```dart
CarouselSlider(
  height: 400.0,
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

## Params

```dart

CarouselSlider(
   items: items,
   height: 400,
   aspectRatio: 16/9,
   viewportFraction: 0.8,
   initialPage: 0,
   enableInfiniteScroll: true,
   reverse: false,
   autoPlay: true,
   autoPlayInterval: Duration(seconds: 3),
   autoPlayAnimationDuration: Duration(milliseconds: 800),
   autoPlayCurve: Curves.fastOutSlowIn,
   pauseAutoPlayOnTouch: Duration(seconds: 10),
   enlargeCenterPage: true,
   onPageChanged: callbackFunction,
   scrollDirection: Axis.horizontal,
 )
```

You can pass the above params to the class. If you pass the `height` params, the `aspectRatio` param will be ignore.

## Build item widgets on demand

This method will save memory and build item when it will be visible.
Can be used to build different child item widgets related to content or by item index.

```dart

CarouselSlider.builder(
   itemCount: 15,
   itemBuilder: (BuildContext context, int itemIndex) =>
        Container(
            child: Text(itemIndex.toString()),
        ),
   )
```

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

## Example

Let a carousel slide play automatically or use buttons:

![auto_button_loop.gif](example/auto_button_loop.gif)

Show dot indicator or play carousel in cover mode:

![indicator_fullscreen_loop.gif](example/indicator_fullscreen_loop.gif)

Pause slideshow for a set amount of time on user touch input:

![touch_pause_loop.gif](example/touch_pause_loop.gif)

For a more detail example please take a look at the `example` folder.

## Faq

### Can I display a dotted indicator for the slider?

Yes, you can.

```dart
class CarouselWithIndicator extends StatefulWidget {
  @override
  _CarouselWithIndicatorState createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          items: child,
          autoPlay: true,
          aspectRatio: 2.0,
          onPageChangedCallback: (index) {
            setState(() {
              _current = index;
            });
          },
        ),
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: map<Widget>(imgList, (index, url) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == index ? Color.fromRGBO(0, 0, 0, 0.9) : Color.fromRGBO(0, 0, 0, 0.4)
                ),
              );
            }),
          )
        )
      ]
    );
  }
}

```

### Can I pause the slider if i touch it?

Yes.
Use the `pauseAutoPlayOnTouch` which takes a duration and when set, enables touch detection.
Touch Detection is only active if the `autoPlay` property is set to true.
If the screen is touched it will pause the automatic playback for the set duration.
if touched again during the time out the timer is reset to the duration passed to `pauseAutoPlayOnTouch`.

This feature can be useful if you want users to be able to interact with the screen and not have the pages continue sliding, forcing the user to repeatedly swipe back.
One such example could be a commercial advertisement where the customers can react to something they like.

### Can I disable the infinite loop mode?

Yes. This was added by popular demand in patch `1.2.0`.  
Just set the constructor argument `enableInfiniteScroll` to false.

##

The example folder contains an example showcasing all features.

If something is missing, feel free to open a ticket or contribute!
