import 'dart:async';

import 'package:carousel_slider/carousel_options.dart';
import 'package:flutter/material.dart';

import 'carousel_state.dart';
import 'utils.dart';

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

  void _setModeController() =>
      _state.changeMode(CarouselPageChangedReason.controller);
  @override
  bool get ready => _state != null;

  @override
  Future<Null> get onReady => _readyCompleter.future;

  /// Animates the controlled [CarouselSlider] to the next page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  Future<void> nextPage({Duration duration, Curve curve}) {
    _setModeController();
    return _state.pageController.nextPage(duration: duration, curve: curve);
  }

  /// Animates the controlled [CarouselSlider] to the previous page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  Future<void> previousPage({Duration duration, Curve curve}) {
    _setModeController();
    return _state.pageController.previousPage(duration: duration, curve: curve);
  }

  /// Changes which page is displayed in the controlled [CarouselSlider].
  ///
  /// Jumps the page position from its current value to the given value,
  /// without animation, and without checking if the new value is in range.
  void jumpToPage(int page) {
    final index = getRealIndex(_state.pageController.page.toInt(),
        _state.realPage - _state.initialPage, _state.itemCount);

    final int pageToJump = _state.pageController.page.toInt() + page - index;
    print(_state.pageController.page.toInt());
    _setModeController();
    return _state.pageController.jumpToPage(pageToJump);
  }

  /// Animates the controlled [CarouselSlider] from the current page to the given page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  Future<void> animateToPage(int page, {Duration duration, Curve curve}) {
    final index = getRealIndex(_state.pageController.page.toInt(),
        _state.realPage - _state.initialPage, _state.itemCount);
    _setModeController();
    return _state.pageController.animateToPage(
        _state.pageController.page.toInt() + page - index,
        duration: duration,
        curve: curve);
  }
}
