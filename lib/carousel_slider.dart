library carousel_slider;

import 'dart:async';

import 'package:carousel_slider/carousel_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'utils.dart';
import 'carousel_options.dart';
import 'carousel_controller.dart';

export 'carousel_options.dart';
export 'carousel_controller.dart';

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

  CarouselSlider({
    @required this.items,
    @required this.options,
    carouselController,
    Key key
  }) : itemBuilder = null,
    itemCount = items != null ? items.length : 0,
    _carouselController = carouselController ?? CarouselController(),
    super(key: key);

  /// The on demand item builder constructor
  CarouselSlider.builder({
    @required this.itemCount,
    @required this.itemBuilder,
    @required this.options,
    carouselController,
    Key key
  }) : items = null,
    _carouselController = carouselController ?? CarouselController(),
    super(key: key);

  @override
  CarouselSliderState createState() => CarouselSliderState(_carouselController);
}

class CarouselSliderState extends State<CarouselSlider> with TickerProviderStateMixin {
  final CarouselControllerImpl carouselController;
  Timer timer;

  CarouselOptions get options => widget.options ?? CarouselOptions();

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
    carouselState.initialPage = widget.options.initialPage;
    carouselState.realPage = options.enableInfiniteScroll
      ? carouselState.realPage + carouselState.initialPage
      : carouselState.initialPage;
    timer = getTimer();


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

    // currently we can't listen to the `onPanUp` event(it doesn't work with pageview widget),
    // so we can't resume the auto play when user finish swiping. here we use a hardcode
    // duration to automatically triggering next auto play. This should be fixed when
    // we find a solution to listen to the `onPanUp` event.
    timer = Timer(Duration(seconds: 1), () {
      timer = getTimer();
    });
  }

  Widget getWrapper(Widget child) {
    Widget wrapper;
    if (widget.options.height != null) {
      wrapper = Container(height: widget.options.height, child: child);
    } else {
      wrapper = AspectRatio(aspectRatio: widget.options.aspectRatio, child: child);
    }

    Widget listenerWrapper = NotificationListener(
      onNotification: (notification) {
        if (widget.options.onScrolled != null && notification is ScrollUpdateNotification) {
          widget.options.onScrolled(carouselState.pageController.page);
        }
        return false;
      },
      child: wrapper,
    );

    return widget.options.autoPlay
      ? addGestureDetection(listenerWrapper)
      : listenerWrapper;
  }

  void onPanDown() {
    if (widget.options.autoPlay) {
      pauseOnTouch();
    }

    mode = CarouselPageChangedReason.manual;
  }

  Widget addGestureDetection(Widget child) =>
    GestureDetector(
      onPanDown: (_) => onPanDown(),
      child: child,
    );

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
        int currentPage = getRealIndex(index + carouselState.initialPage,
            carouselState.realPage, widget.itemCount);
        if (widget.options.onPageChanged != null) {
          widget.options.onPageChanged(currentPage, mode);
        }
        mode = CarouselPageChangedReason.controller;
      },
      itemBuilder: (BuildContext context, int idx) {
        final int index = getRealIndex(idx + carouselState.initialPage,
            carouselState.realPage, widget.itemCount);

        return AnimatedBuilder(
          animation: carouselState.pageController,
          child: (widget.items != null)
              ? (widget.items.length > 0 ? widget.items[index] : Container())
              : widget.itemBuilder(context, index),
          builder: (BuildContext context, child) {
            double distortionValue = 1.0;
            // if `enlargeCenterPage` is true, we must calculate the carousel item's height
            // to display the visual effect
            if (widget.options.enlargeCenterPage != null && widget.options.enlargeCenterPage == true) {
              double itemOffset;
              // pageController.page can only be accessed after the first build,
              // so in the first build we calculate the itemoffset manually
              if (carouselState.pageController.position.minScrollExtent == null ||
                  carouselState.pageController.position.maxScrollExtent == null) {
                itemOffset = carouselState.realPage.toDouble() - idx.toDouble();
              } else {
                itemOffset = carouselState.pageController.page - idx;
              }
              final distortionRatio = (1 - (itemOffset.abs() * 0.3)).clamp(0.0, 1.0);
              distortionValue = Curves.easeOut.transform(distortionRatio);
            }

            final double height = widget.options.height ??
                MediaQuery.of(context).size.width *
                    (1 / widget.options.aspectRatio);

            if (widget.options.scrollDirection == Axis.horizontal) {
              return Center(
                child: SizedBox(
                  height: distortionValue * height,
                  child: child,
                ),
              );
            } else {
              return Center(
                child: SizedBox(
                  width: distortionValue * MediaQuery.of(context).size.width,
                  child: child,
                ),
              );
            }
          },
        );
      },
    ));
  }
}
