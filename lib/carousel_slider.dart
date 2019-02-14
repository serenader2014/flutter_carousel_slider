library carousel_slider;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

int _remainder(int input, int source) {
  final int result = input % source;
  return result < 0 ? source + result : result;
}

int _getRealIndex(int position, int base, int length) {
  final int offset = position - base;
  return _remainder(offset, length);
}

class CarouselSlider extends StatefulWidget {
  final List<Widget> items;
  final num viewportFraction;
  final num initialPage;
  final double aspectRatio;
  final double height;
  final PageController pageController;
  final num realPage;
  final bool autoPlay;
  final Duration autoPlayDuration;
  final Curve autoPlayCurve;
  final Duration pauseOnTouchDuration;
  final Duration interval;
  final bool reverse;
  final Function updateCallback;
  final bool distortion;

  CarouselSlider({
    @required
    this.items,
    this.viewportFraction: 0.8,
    this.initialPage: 0,
    this.aspectRatio: 16/9,
    this.height,
    this.realPage: 10000,
    this.autoPlay: false,
    this.interval: const Duration(seconds: 4),
    this.reverse: false,
    this.autoPlayCurve: Curves.fastOutSlowIn,
    this.autoPlayDuration: const Duration(milliseconds: 800),
    this.pauseOnTouchDuration,
    this.updateCallback,
    this.distortion: true,
  }) :
    pageController = PageController(
      viewportFraction: viewportFraction,
      initialPage: realPage + initialPage,
    );

  @override
  _CarouselSliderState createState() {
    return _CarouselSliderState();
  }

  Future<Null> nextPage({Duration duration, Curve curve}) {
    return pageController.nextPage(duration: duration, curve: curve);
  }

  Future<Null> previousPage({Duration duration, Curve curve}) {
    return pageController.previousPage(duration: duration, curve: curve);
  }

  void jumpToPage(int page) {
    final index = _getRealIndex(pageController.page.toInt(), realPage, items.length);
    return pageController.jumpToPage(pageController.page.toInt() + page - index);
  }

  Future<void> animateToPage(int page, {Duration duration, Curve curve}) {
    final index = _getRealIndex(pageController.page.toInt(), realPage, items.length);
    return pageController.animateToPage(
      pageController.page.toInt() + page - index,
      duration: duration,
      curve: curve
    );
  }
}

class _CarouselSliderState extends State<CarouselSlider> with TickerProviderStateMixin {
  int currentPage;
  Timer timer;

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;
    timer = getTimer();
  }

  Timer getTimer() {
    return Timer.periodic(widget.interval, (_) {
      if (widget.autoPlay) {
        widget.pageController.nextPage(
          duration: widget.autoPlayDuration,
          curve: widget.autoPlayCurve
        );
      }
    });
  }

  void pauseOnTouch() {
    setState(() {
      timer.cancel();
      timer = Timer(widget.pauseOnTouchDuration, () {
        setState(() {
          timer = getTimer();
          });
      });
    });
  }

  Widget getWrapper(Widget child) {
    if (widget.height != null) {
      final Widget wrapper = Container(height: widget.height, child: child);
      return widget.autoPlay && widget.pauseOnTouchDuration != null
          ? addGestureDetection(wrapper)
          : wrapper;
    } else {
      final Widget wrapper = AspectRatio(aspectRatio: widget.aspectRatio, child: child);
      return widget.autoPlay && widget.pauseOnTouchDuration != null
          ? addGestureDetection(wrapper)
          : wrapper;
    }
  }

  Widget addGestureDetection(Widget child) =>
      GestureDetector(onPanDown: (_) => pauseOnTouch(), child: child);

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return getWrapper(
      PageView.builder(
        onPageChanged: (int index) {
          currentPage = _getRealIndex(index, widget.realPage, widget.items.length);
          if (widget.updateCallback != null) widget.updateCallback(currentPage);
        },
        controller: widget.pageController,
        reverse: widget.reverse,
        itemBuilder: (BuildContext context, int i) {
          final int index = _getRealIndex(i, widget.realPage, widget.items.length);

          return AnimatedBuilder(
            animation: widget.pageController,
            builder: (BuildContext context, child) {
              // on the first render, the pageController.page is null,
              // this is a dirty hack
              if (widget.pageController.position.minScrollExtent == null
                || widget.pageController.position.maxScrollExtent == null) {
                Future.delayed(Duration(microseconds: 1), () {
                  setState(() {});
                });
                return Container();
              }
              double value = widget.pageController.page - i;
              value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);

              final double height = widget.height ?? MediaQuery.of(context).size.width * (1 / widget.aspectRatio);
              final double distortionValue = widget.distortion ? Curves.easeOut.transform(value) : 1.0;

              return Center(
                child: SizedBox(
                  height: distortionValue * height,
                  child: child
                )
              );
            },
            child: widget.items[index]
          );
        },
      )
    );
  }
}