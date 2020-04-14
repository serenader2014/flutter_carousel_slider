library carousel_slider;

import 'dart:async';

import 'package:carousel_slider/carousel_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum CarouselPageChangedReason { timed, manual, controller }

class CarouselOptions {
  /// Set carousel height and overrides any existing [aspectRatio].
  final double height;

  /// Aspect ratio is used if no height have been declared.
  ///
  /// Defaults to 16:9 aspect ratio.
  final double aspectRatio;

  /// The fraction of the viewport that each page should occupy.
  ///
  /// Defaults to 0.8, which means each page fills 80% of the carousel.
  final num viewportFraction;

  /// The initial page to show when first creating the [CarouselSlider].
  ///
  /// Defaults to 0.
  final num initialPage;

  ///Determines if carousel should loop infinitely or be limited to item length.
  ///
  ///Defaults to true, i.e. infinite loop.
  final bool enableInfiniteScroll;

  /// Reverse the order of items if set to true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// Enables auto play, sliding one page at a time.
  ///
  /// Use [autoPlayInterval] to determent the frequency of slides.
  /// Defaults to false.
  final bool autoPlay;

  /// Sets Duration to determent the frequency of slides when
  ///
  /// [autoPlay] is set to true.
  /// Defaults to 4 seconds.
  final Duration autoPlayInterval;

  /// The animation duration between two transitioning pages while in auto playback.
  ///
  /// Defaults to 800 ms.
  final Duration autoPlayAnimationDuration;

  /// Determines the animation curve physics.
  ///
  /// Defaults to [Curves.fastOutSlowIn].
  final Curve autoPlayCurve;

  /// Sets a timer on touch detected that pause the auto play with
  /// the given [Duration].
  ///
  /// Touch Detection is only active if [autoPlay] is true.
  final Duration pauseAutoPlayOnTouch;

  /// Determines if current page should be larger then the side images,
  /// creating a feeling of depth in the carousel.
  ///
  /// Defaults to false.
  final bool enlargeCenterPage;

  /// The axis along which the page view scrolls.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis scrollDirection;

  /// Called whenever the page in the center of the viewport changes.
  final Function(int index, CarouselPageChangedReason reason) onPageChanged;

  /// Called whenever the carousel is scrolled
  final ValueChanged<double> onScrolled;

  /// How the carousel should respond to user input.
  ///
  /// For example, determines how the items continues to animate after the
  /// user stops dragging the page view.
  ///
  /// The physics are modified to snap to page boundaries using
  /// [PageScrollPhysics] prior to being used.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics scrollPhysics;

  CarouselOptions(
      {this.height,
      this.aspectRatio: 16 / 9,
      this.viewportFraction: 0.8,
      this.initialPage: 0,
      this.enableInfiniteScroll: true,
      this.reverse: false,
      this.autoPlay: false,
      this.autoPlayInterval: const Duration(seconds: 4),
      this.autoPlayAnimationDuration = const Duration(milliseconds: 800),
      this.autoPlayCurve: Curves.fastOutSlowIn,
      this.pauseAutoPlayOnTouch,
      this.enlargeCenterPage = false,
      this.onPageChanged,
      this.onScrolled,
      this.scrollPhysics,
      this.scrollDirection: Axis.horizontal,
      carouselController});
}

class CarouselSlider extends StatefulWidget {
  /// [CarouselOptions] to create a [CarouselState] with
  ///
  /// This property must not be null
  final CarouselOptions options;

  /// The widgets to be shown in the carousel of default constructor
  final List<Widget> items;

  /// The widget item builder that will be used to build item on demand
  final IndexedWidgetBuilder itemBuilder;

  /// A [MapController], used to control the map.
  final CarouselControllerImpl _carouselController;

  final int itemCount;

  CarouselSlider({@required this.items, this.options, carouselController})
      : itemBuilder = null,
        itemCount = items != null ? items.length : 0,
        _carouselController = carouselController ?? CarouselController();

  /// The on demand item builder constructor
  CarouselSlider.builder(
      {@required this.itemCount,
      @required this.itemBuilder,
      this.options,
      carouselController})
      : items = null,
        _carouselController = carouselController ?? CarouselController();

  @override
  CarouselSliderState createState() => CarouselSliderState(_carouselController);
}

abstract class CarouselController {
  bool get ready;

  Future<Null> get onReady;

  void nextPage({Duration duration, Curve curve});

  void previousPage({Duration duration, Curve curve});

  void jumpToPage(int page);

  void animateToPage(int page, {Duration duration, Curve curve});

  factory CarouselController() => CarouselControllerImpl();
}

class CarouselControllerImpl implements CarouselController {
  final Completer<Null> _readyCompleter = Completer<Null>();

  CarouselState _state;

  set state(CarouselState state) {
    _state = state;
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
  }

  @override
  bool get ready => _state != null;

  @override
  Future<Null> get onReady => _readyCompleter.future;

  /// Animates the controlled [CarouselSlider] to the next page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  Future<void> nextPage({Duration duration, Curve curve}) {
    return _state.pageController.nextPage(duration: duration, curve: curve);
  }

  /// Animates the controlled [CarouselSlider] to the previous page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  Future<void> previousPage({Duration duration, Curve curve}) {
    return _state.pageController.previousPage(duration: duration, curve: curve);
  }

  /// Changes which page is displayed in the controlled [CarouselSlider].
  ///
  /// Jumps the page position from its current value to the given value,
  /// without animation, and without checking if the new value is in range.
  void jumpToPage(int page) {
    final index = _getRealIndex(_state.pageController.page.toInt(),
        _state.realPage - _state.initialPage, _state.itemCount);

    final int pageToJump = _state.pageController.page.toInt() + page - index;
    print(_state.pageController.page.toInt());
    return _state.pageController.jumpToPage(pageToJump);
  }

  /// Animates the controlled [CarouselSlider] from the current page to the given page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  Future<void> animateToPage(int page, {Duration duration, Curve curve}) {
    final index = _getRealIndex(_state.pageController.page.toInt(),
        _state.realPage - _state.initialPage, _state.itemCount);
    return _state.pageController.animateToPage(
        _state.pageController.page.toInt() + page - index,
        duration: duration,
        curve: curve);
  }
}

class CarouselSliderState extends State<CarouselSlider>
    with TickerProviderStateMixin {
  final CarouselControllerImpl carouselController;
  Timer timer;

  @override
  CarouselOptions get options => widget.options ?? CarouselOptions();

  @override
  CarouselState carouselState;

  /// mode is related to why the page is being changed
  CarouselPageChangedReason mode = CarouselPageChangedReason.controller;

  CarouselSliderState(this.carouselController);

  @override
  void didUpdateWidget(CarouselSlider oldWidget) {
    carouselState.options = options;
    carouselState.itemCount = widget.itemCount;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    carouselState = CarouselState(this.options);

    carouselState.itemCount = widget.itemCount;
    carouselController.state = carouselState;
    carouselState.realPage = options.enableInfiniteScroll
        ? carouselState.realPage + carouselState.initialPage
        : carouselState.initialPage;
    timer = getTimer();

    carouselState.initialPage = widget.options.initialPage;

    PageController pageController = PageController(
      viewportFraction: options.viewportFraction,
      initialPage: carouselState.realPage,
    );

    carouselState.pageController = pageController;
  }

  Timer getTimer() {
    return widget.options.autoPlay
        ? Timer.periodic(widget.options.autoPlayInterval, (_) {
            CarouselPageChangedReason previousReason = mode;
            mode = CarouselPageChangedReason.timed;
            carouselState.pageController
                .nextPage(
                    duration: widget.options.autoPlayAnimationDuration,
                    curve: widget.options.autoPlayCurve)
                .then((_) => mode = previousReason);
          })
        : null;
  }

  void pauseOnTouch() {
    timer.cancel();
    timer = Timer(widget.options.pauseAutoPlayOnTouch, () {
      timer = getTimer();
    });
  }

  Widget getWrapper(Widget child) {
    Widget wrapper;
    if (widget.options.height != null) {
      wrapper = Container(height: widget.options.height, child: child);
    } else {
      wrapper =
          AspectRatio(aspectRatio: widget.options.aspectRatio, child: child);
    }

    Widget listenerWrapper = NotificationListener(
      onNotification: (notification) {
        if (widget.options.onScrolled != null &&
            notification is ScrollUpdateNotification) {
          widget.options.onScrolled(carouselState.pageController.page);
        }
        return false;
      },
      child: wrapper,
    );

    return widget.options.autoPlay &&
            widget.options.pauseAutoPlayOnTouch != null
        ? addGestureDetection(listenerWrapper)
        : listenerWrapper;
  }

  void onPanDown() {
    if (widget.options.autoPlay &&
        widget.options.pauseAutoPlayOnTouch != null) {
      pauseOnTouch();
    }

    mode = CarouselPageChangedReason.manual;
  }

  Widget addGestureDetection(Widget child) =>
      GestureDetector(onPanDown: (_) => onPanDown(), child: child);

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return getWrapper(PageView.builder(
      physics: widget.options.scrollPhysics,
      scrollDirection: widget.options.scrollDirection,
      controller: carouselState.pageController,
      reverse: widget.options.reverse,
      itemCount: widget.options.enableInfiniteScroll ? null : widget.itemCount,
      onPageChanged: (int index) {
        int currentPage = _getRealIndex(index + carouselState.initialPage,
            carouselState.realPage, widget.itemCount);
        if (widget.options.onPageChanged != null) {
          widget.options.onPageChanged(currentPage, mode);
        }
        mode = CarouselPageChangedReason.controller;
      },
      itemBuilder: (BuildContext context, int i) {
        final int index = _getRealIndex(i + carouselState.initialPage,
            carouselState.realPage, widget.itemCount);

        return AnimatedBuilder(
          animation: carouselState.pageController,
          child: (widget.items != null)
              ? widget.items[index]
              : widget.itemBuilder(context, index),
          builder: (BuildContext context, child) {
            // on the first render, the pageController.page is null,
            // this is a dirty hack
            if (carouselState.pageController.position.minScrollExtent == null ||
                carouselState.pageController.position.maxScrollExtent == null) {
              Future.delayed(Duration(microseconds: 1), () {
                if (this.mounted) {
                  setState(() {});
                }
              });
              return Container();
            }
            double value = carouselState.pageController.page - i;
            value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);

            final double height = widget.options.height ??
                MediaQuery.of(context).size.width *
                    (1 / widget.options.aspectRatio);
            final double distortionValue = widget.options.enlargeCenterPage
                ? Curves.easeOut.transform(value)
                : 1.0;

            if (widget.options.scrollDirection == Axis.horizontal) {
              return Center(
                  child:
                      SizedBox(height: distortionValue * height, child: child));
            } else {
              return Center(
                  child: SizedBox(
                      width:
                          distortionValue * MediaQuery.of(context).size.width,
                      child: child));
            }
          },
        );
      },
    ));
  }
}

/// Converts an index of a set size to the corresponding index of a collection of another size
/// as if they were circular.
///
/// Takes a [position] from collection Foo, a [base] from where Foo's index originated
/// and the [length] of a second collection Baa, for which the correlating index is sought.
///
/// For example; We have a Carousel of 10000(simulating infinity) but only 6 images.
/// We need to repeat the images to give the illusion of a never ending stream.
/// By calling _getRealIndex with position and base we get an offset.
/// This offset modulo our length, 6, will return a number between 0 and 5, which represent the image
/// to be placed in the given position.
int _getRealIndex(int position, int base, int length) {
  final int offset = position - base;
  return _remainder(offset, length);
}

/// Returns the remainder of the modulo operation [input] % [source], and adjust it for
/// negative values.
int _remainder(int input, int source) {
  if (source == 0) return 0;
  final int result = input % source;
  return result < 0 ? source + result : result;
}
