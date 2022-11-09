library carousel_slider;

import 'dart:async';

import 'package:carousel_slider/carousel_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'carousel_controller.dart';
import 'carousel_options.dart';
import 'utils.dart';

export 'carousel_controller.dart';
export 'carousel_options.dart';

typedef Widget ExtendedIndexedWidgetBuilder(
    BuildContext context, int index, int realIndex);

class CarouselSlider extends StatefulWidget {
  /// [CarouselOptions] to create a [CarouselState] with
  final CarouselOptions options;

  /// The widgets to be shown in the carousel of default constructor
  final List<Widget>? items;

  /// The widget item builder that will be used to build item on demand
  /// The third argument is the PageView's real index, can be used to cooperate
  /// with Hero.
  final ExtendedIndexedWidgetBuilder? itemBuilder;

  /// A [MapController], used to control the map.
  final CarouselControllerImpl _carouselController;

  final int? itemCount;

  CarouselSlider(
      {required this.items,
      required this.options,
      CarouselController? carouselController,
      Key? key})
      : itemBuilder = null,
        itemCount = items != null ? items.length : 0,
        _carouselController = carouselController != null
            ? carouselController as CarouselControllerImpl
            : CarouselController() as CarouselControllerImpl,
        super(key: key);

  /// The on demand item builder constructor
  CarouselSlider.builder(
      {required this.itemCount,
      required this.itemBuilder,
      required this.options,
      CarouselController? carouselController,
      Key? key})
      : items = null,
        _carouselController = carouselController != null
            ? carouselController as CarouselControllerImpl
            : CarouselController() as CarouselControllerImpl,
        super(key: key);

  @override
  CarouselSliderState createState() => CarouselSliderState(_carouselController);
}

class CarouselSliderState extends State<CarouselSlider>
    with TickerProviderStateMixin {
  final CarouselControllerImpl carouselController;
  Timer? timer;

  CarouselOptions get options => widget.options;

  CarouselState? carouselState;

  PageController? pageController;

  ValueNotifier<int> _currentPageNotifier = ValueNotifier(0);

  /// mode is related to why the page is being changed
  CarouselPageChangedReason mode = CarouselPageChangedReason.controller;

  CarouselSliderState(this.carouselController);

  void changeMode(CarouselPageChangedReason _mode) {
    mode = _mode;
  }

  @override
  void didUpdateWidget(CarouselSlider oldWidget) {
    carouselState!.options = options;
    carouselState!.itemCount = widget.itemCount;

    // pageController needs to be re-initialized to respond to state changes
    pageController = PageController(
      viewportFraction: options.viewportFraction,
      initialPage: carouselState!.realPage,
    );
    carouselState!.pageController = pageController;

    // handle autoplay when state changes
    handleAutoPlay();

    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    carouselState =
        CarouselState(this.options, clearTimer, resumeTimer, this.changeMode);

    carouselState!.itemCount = widget.itemCount;
    carouselController.state = carouselState;
    carouselState!.initialPage = widget.options.initialPage;
    carouselState!.realPage = options.enableInfiniteScroll
        ? carouselState!.realPage + carouselState!.initialPage
        : carouselState!.initialPage;
    handleAutoPlay();

    pageController = PageController(
      viewportFraction: options.viewportFraction,
      initialPage: carouselState!.realPage,
    );

    carouselState!.pageController = pageController;
  }

  Timer? getTimer() {
    return widget.options.autoPlay
        ? Timer.periodic(widget.options.autoPlayInterval, (_) {
            final route = ModalRoute.of(context);
            if (route?.isCurrent == false) {
              return;
            }

            CarouselPageChangedReason previousReason = mode;
            changeMode(CarouselPageChangedReason.timed);
            int nextPage = carouselState!.pageController!.page!.round() + 1;
            int itemCount = widget.itemCount ?? widget.items!.length;

            if (nextPage >= itemCount &&
                widget.options.enableInfiniteScroll == false) {
              if (widget.options.pauseAutoPlayInFiniteScroll) {
                clearTimer();
                return;
              }
              nextPage = 0;
            }

            carouselState!.pageController!
                .animateToPage(nextPage,
                    duration: widget.options.autoPlayAnimationDuration,
                    curve: widget.options.autoPlayCurve)
                .then((_) => changeMode(previousReason));
          })
        : null;
  }

  void clearTimer() {
    if (timer != null) {
      timer?.cancel();
      timer = null;
    }
  }

  void resumeTimer() {
    if (timer == null) {
      timer = getTimer();
    }
  }

  void handleAutoPlay() {
    bool autoPlayEnabled = widget.options.autoPlay;

    if (autoPlayEnabled && timer != null) return;

    clearTimer();
    if (autoPlayEnabled) {
      resumeTimer();
    }
  }

  Widget getGestureWrapper(Widget child) {
    Widget wrapper;
    if (widget.options.height != null) {
      wrapper = Container(height: widget.options.height, child: child);
    } else {
      wrapper =
          AspectRatio(aspectRatio: widget.options.aspectRatio, child: child);
    }

    return RawGestureDetector(
      gestures: {
        _MultipleGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<_MultipleGestureRecognizer>(
                () => _MultipleGestureRecognizer(),
                (_MultipleGestureRecognizer instance) {
          instance.onStart = (_) {
            onStart();
          };
          instance.onDown = (_) {
            onPanDown();
          };
          instance.onEnd = (_) {
            onPanUp();
          };
          instance.onCancel = () {
            onPanUp();
          };
        }),
      },
      child: NotificationListener(
        onNotification: (Notification notification) {
          if (widget.options.onScrolled != null &&
              notification is ScrollUpdateNotification) {
            widget.options.onScrolled!(carouselState!.pageController!.page);
          }
          return false;
        },
        child: wrapper,
      ),
    );
  }

  Widget getButtonWrapper({
    required Widget child,
  }) {
    if (!widget.options.withButtons) {
      return child;
    }

    return ValueListenableBuilder<int>(
      valueListenable: _currentPageNotifier,
      builder: (context, currentPage, _) {
        final itemCount = widget.itemCount ?? widget.items!.length;
        final nextPage = currentPage < (itemCount - 1)
            ? currentPage + 1
            : currentPage;

        final enableInfiniteScroll = widget.options.enableInfiniteScroll;

        final hasPrevious = currentPage > 0 || enableInfiniteScroll;
        final hasNext = nextPage != currentPage || enableInfiniteScroll;

        final isHorizontal = options.scrollDirection == Axis.horizontal;

        return Stack(
          children: [
            child,
            Positioned(
              top: 0,
              bottom: isHorizontal ? 0 : null,
              left: isHorizontal ? 16 : 0,
              right: isHorizontal ? null : 0,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 250),
                child: hasPrevious
                    ? InkWell(
                  onTap: () => carouselController.previousPage(),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(8),
                    child: Center(
                      child: Icon(
                        isHorizontal
                            ? Icons.chevron_left
                            : Icons.keyboard_arrow_up,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
                    : null,
              ),
            ),
            Positioned(
              top: isHorizontal ? 0 : null,
              bottom: 0,
              right: isHorizontal ? 16 : 0,
              left: isHorizontal ? null : 0,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 250),
                child: hasNext
                    ? InkWell(
                  onTap: () => carouselController.nextPage(),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(8),
                    child: Center(
                      child: Icon(
                        isHorizontal
                            ? Icons.chevron_right
                            : Icons.keyboard_arrow_down,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget getCenterWrapper(Widget child) {
    if (widget.options.disableCenter) {
      return Container(
        child: child,
      );
    }
    return Center(child: child);
  }

  Widget getEnlargeWrapper(Widget? child,
      {double? width, double? height, double? scale}) {
    if (widget.options.enlargeStrategy == CenterPageEnlargeStrategy.height) {
      return SizedBox(child: child, width: width, height: height);
    }
    return Transform.scale(
        scale: scale!,
        child: Container(child: child, width: width, height: height));
  }

  void onStart() {
    changeMode(CarouselPageChangedReason.manual);
  }

  void onPanDown() {
    if (widget.options.pauseAutoPlayOnTouch) {
      clearTimer();
    }

    changeMode(CarouselPageChangedReason.manual);
  }

  void onPanUp() {
    if (widget.options.pauseAutoPlayOnTouch) {
      resumeTimer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    clearTimer();
    _currentPageNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return getButtonWrapper(
        child: getGestureWrapper(PageView.builder(
          padEnds: widget.options.padEnds,
          scrollBehavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            overscroll: false,
            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
          ),
          clipBehavior: widget.options.clipBehavior,
          physics: widget.options.scrollPhysics,
          scrollDirection: widget.options.scrollDirection,
          pageSnapping: widget.options.pageSnapping,
          controller: carouselState!.pageController,
          reverse: widget.options.reverse,
          itemCount: widget.options.enableInfiniteScroll ? null : widget.itemCount,
          key: widget.options.pageViewKey,
          onPageChanged: (int index) {
            int currentPage = getRealIndex(index + carouselState!.initialPage,
                carouselState!.realPage, widget.itemCount);
            if (widget.options.onPageChanged != null) {
              widget.options.onPageChanged!(currentPage, mode);
            }
            _currentPageNotifier.value = index;
          },
          itemBuilder: (BuildContext context, int idx) {
            final int index = getRealIndex(idx + carouselState!.initialPage,
                carouselState!.realPage, widget.itemCount);

            return AnimatedBuilder(
              animation: carouselState!.pageController!,
              child: (widget.items != null)
                  ? (widget.items!.length > 0 ? widget.items![index] : Container())
                  : widget.itemBuilder!(context, index, idx),
              builder: (BuildContext context, child) {
                double distortionValue = 1.0;
                // if `enlargeCenterPage` is true, we must calculate the carousel item's height
                // to display the visual effect

                if (widget.options.enlargeCenterPage != null &&
                    widget.options.enlargeCenterPage == true) {
                  // pageController.page can only be accessed after the first build,
                  // so in the first build we calculate the itemoffset manually
                  double itemOffset = 0;
                  var position = carouselState?.pageController?.position;
                  if (position != null &&
                      position.hasPixels &&
                      position.hasContentDimensions) {
                    var _page = carouselState?.pageController?.page;
                    if (_page != null) {
                      itemOffset = _page - idx;
                    }
                  } else {
                    BuildContext storageContext = carouselState!
                        .pageController!.position.context.storageContext;
                    final double? previousSavedPosition =
                    PageStorage.of(storageContext)?.readState(storageContext)
                    as double?;
                    if (previousSavedPosition != null) {
                      itemOffset = previousSavedPosition - idx.toDouble();
                    } else {
                      itemOffset =
                          carouselState!.realPage.toDouble() - idx.toDouble();
                    }
                  }

                  final num distortionRatio =
                  (1 - (itemOffset.abs() * 0.3)).clamp(0.0, 1.0);
                  distortionValue =
                      Curves.easeOut.transform(distortionRatio as double);
                }

                final double height = widget.options.height ??
                    MediaQuery.of(context).size.width *
                        (1 / widget.options.aspectRatio);

                if (widget.options.scrollDirection == Axis.horizontal) {
                  return getCenterWrapper(getEnlargeWrapper(child,
                      height: distortionValue * height, scale: distortionValue));
                } else {
                  return getCenterWrapper(getEnlargeWrapper(child,
                      width: distortionValue * MediaQuery.of(context).size.width,
                      scale: distortionValue));
                }
              },
            );
          },
        )),
    );
  }
}

class _MultipleGestureRecognizer extends PanGestureRecognizer {}
