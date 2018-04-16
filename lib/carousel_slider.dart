library carousel_slider;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

int remander(int input, int source) {
  final int result = input % source;
  return result < 0 ? source + result : result;
}

int getRealIndex(int position, int base, int length) {
  final int offset = position - base;
  return remander(offset, length);
}

class CarouselSlider extends StatefulWidget {
  final List<Widget> items;
  final num viewportFraction;
  final num initialPage;
  final num aspectRatio;

  CarouselSlider({
    @required
    this.items,
    this.viewportFraction: 0.8,
    this.initialPage: 0,
    this.aspectRatio: 16/9
  });

  @override
  _CarouselSliderState createState() {
    return new _CarouselSliderState();
  }
}

class _CarouselSliderState extends State<CarouselSlider> with TickerProviderStateMixin {
  int currentPage;
  int _initialPage;
  PageController pageController;

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;
    _initialPage = 10000;
    pageController = new PageController(
      viewportFraction: widget.viewportFraction,
      initialPage: _initialPage
    );
  }

  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: new PageView.builder(
        onPageChanged: (int index) {
          currentPage = getRealIndex(index, _initialPage, widget.items.length);
        },
        controller: pageController,
        itemBuilder: (BuildContext context, int i) {
          final int index = getRealIndex(i, 1000, widget.items.length);

          return new AnimatedBuilder(
            animation: pageController,
            builder: (BuildContext context, child) {
              // on the first render, the pageController.page is null, 
              // this is a dirty hack
              if (pageController.position.minScrollExtent == null || pageController.position.maxScrollExtent == null) {
                new Future.delayed(new Duration(microseconds: 1), () {
                  setState(() {});
                });
                return new Container();
              }
              double value = pageController.page - i;
              value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);

              return new Center(
                child: new SizedBox(
                  height: Curves.easeOut.transform(value) * MediaQuery.of(context).size.width * (1 / widget.aspectRatio),
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