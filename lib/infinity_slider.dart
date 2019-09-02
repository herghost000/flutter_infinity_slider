library infinity_slider;

import 'package:flutter/material.dart';
import 'dart:async';

int _calcIndex(int input, int source) {
  final int result = input % source;
  return result < 0 ? source + result : result;
}

int _getRealIndex(int position, int base, int length) {
  final int offset = position - base;
  return _calcIndex(offset, length);
}

typedef void UpdatePageCallback(int index);

class InfinitySlider extends StatefulWidget {
  const InfinitySlider({
    Key key,
    @required this.items,
    this.height,
    this.aspectRatio: 16 / 9,
    this.viewportFraction: 1.0,
    this.initialPage: 0,
    this.loop = true,
    this.autoPlay = false,
    this.interval = const Duration(seconds: 2),
    this.autoPlayAnimationDuration = const Duration(milliseconds: 800),
    this.autoPlayCurve: Curves.fastOutSlowIn,
    this.pauseAutoPlayOnTouch,
    this.updateCallback,
    this.pageController,
    this.linkAncestor = true,
    this.enableScale = false
  })  : assert(items != null),
        assert(items.length > 0),
        assert(initialPage != null),
        assert(autoPlay != null),
        assert(interval != null),
        super(key: key);

  final int initialPage;

  final double aspectRatio;

  final num viewportFraction;

  final List<Widget> items;

  final bool autoPlay;

  final bool loop;

  final Duration interval;

  final Duration autoPlayAnimationDuration;

  final Curve autoPlayCurve;

  final Duration pauseAutoPlayOnTouch;

  final double height;

  final PageController pageController;

  final UpdatePageCallback updateCallback;

  final bool linkAncestor;

  final bool enableScale;

  static InfinitySliderState of(BuildContext context) {
    return context.ancestorStateOfType(TypeMatcher<InfinitySliderState>());
  }

  @override
  InfinitySliderState createState() => InfinitySliderState();
}

class InfinitySliderState extends State<InfinitySlider> {
  int currentPage;

  Timer timer;

  PageController _pageController;

  int realPage;

  double autoMinPage;

  double autoMaxPage;

  InfinitySliderState _ancestor;

  bool get isLeftEdge{
    return _pageController?.position?.pixels == _pageController?.position?.minScrollExtent;
  }

  bool get isRightEdge{
    return _pageController?.position?.pixels == _pageController?.position?.maxScrollExtent;
  }

  @override
  void initState() {
    _linkAncestorIfNeeded();
    realPage = widget.loop ? widget.items.length : widget.initialPage;
    autoMinPage = 0.0;
    autoMaxPage = (widget.items.length * 2).toDouble();

    _pageController = widget.pageController ?? new PageController(
        initialPage: widget.loop ? realPage + widget.initialPage : widget.initialPage,
        viewportFraction: widget.viewportFraction
    );

    _pageController.addListener(() {
      if (_pageController.page == autoMinPage ||
          _pageController.page == autoMaxPage) {
        _pageController.position
            .setPixels(MediaQuery.of(context).size.width * realPage);
      }
    });

    currentPage = widget.initialPage;

    timer = _getAutoPlayTimerIfNeeded();
    super.initState();
  }

  Future<void> nextPage({Duration duration, Curve curve}) {
    return _pageController.nextPage(duration: duration ?? widget.autoPlayAnimationDuration, curve: curve ?? widget.autoPlayCurve);
  }

  Future<void> previousPage({Duration duration, Curve curve}) {
    return _pageController.previousPage(duration: duration ?? widget.autoPlayAnimationDuration, curve: curve ?? widget.autoPlayCurve);
  }

  Future<void> animateToPage(int page, {Duration duration, Curve curve}) {
    final index = _getRealIndex(_pageController.page.toInt(), realPage, widget.items.length);
    return _pageController.animateToPage(_pageController.page.toInt() + page - index, duration: duration ?? widget.autoPlayAnimationDuration, curve: curve ?? widget.autoPlayCurve);
  }

  void jumpToPage(int page) {
    final index = _getRealIndex(_pageController.page.toInt(), realPage, widget.items.length);
    return _pageController.jumpToPage(_pageController.page.toInt() + page - index);
  }

  void _linkAncestorIfNeeded() {
    if (widget.linkAncestor) {
      _ancestor = InfinitySlider.of(context);
    }
  }

  Timer _getAutoPlayTimerIfNeeded() {
    if (widget.autoPlay) {
      return _getAutoPlayTimer();
    }
    return null;
  }

  Timer _getAutoPlayTimer() {
    return Timer.periodic(widget.interval, (_) {
      widget.pageController
          .nextPage(duration: widget.autoPlayAnimationDuration, curve: widget.autoPlayCurve);
    });
  }

  void _pauseOnTouch() {
    timer.cancel();
    timer = Timer(widget.pauseAutoPlayOnTouch, () {
      timer = _getAutoPlayTimerIfNeeded();
    });
  }

  Widget addGestureDetection(Widget child) =>
      GestureDetector(onPanDown: (_) => _pauseOnTouch(), child: child);

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is OverscrollNotification && _ancestor != null) {
      if (_canLinkWithAncestorScroll(notification.overscroll < 0)) {
        _ancestor._pageController.position
            .moveTo(_ancestor._pageController.offset + notification.overscroll);
      }
    }
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (notification.depth == 0 &&
        _canLinkWithAncestorScroll(notification.leading)) {
      notification.disallowGlow();
      return true;
    }
    return false;
  }

  bool _canLinkWithAncestorScroll(bool onLeftEdge) {
    //return false;
    if (_ancestor == null) return false;
    return (onLeftEdge &&
        _ancestor._pageController.offset !=
            _ancestor._pageController.position.minScrollExtent) ||
        ((!onLeftEdge &&
            _ancestor._pageController.offset !=
                _ancestor._pageController.position.maxScrollExtent));
  }

  Widget _getWrapper(Widget child) {
    if (widget.height != null) {
      final Widget wrapper = Container(height: widget.height, child: child);
      return widget.autoPlay && widget.pauseAutoPlayOnTouch != null
          ? addGestureDetection(wrapper)
          : wrapper;
    } else {
      final Widget wrapper = AspectRatio(aspectRatio: widget.aspectRatio, child: child);
      return widget.autoPlay && widget.pauseAutoPlayOnTouch != null
          ? addGestureDetection(wrapper)
          : wrapper;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: _handleScrollNotification,
      child: NotificationListener(
        onNotification: _handleGlowNotification,
        child: _getWrapper(PageView.builder(
          itemCount: widget.loop ? null : widget.items.length,
          itemBuilder: (BuildContext context, int i) {
            final int index = _getRealIndex(i, realPage, widget.items.length);
            return AnimatedBuilder(
              animation: _pageController,
              child: widget.items[index],
              builder: (BuildContext context, child) {
                if (_pageController.position.minScrollExtent == null ||
                    _pageController.position.maxScrollExtent == null) {
                  Future.delayed(Duration.zero, () {
                    setState(() {});
                  });
                  return Container();
                }

                double value = _pageController.page - i;
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);

                final double height =
                    widget.height ?? MediaQuery.of(context).size.width * (1 / widget.aspectRatio);

                final double distortionValue =
                widget.enableScale ? Curves.easeOut.transform(value) : 1.0;

                return Center(
                    child: SizedBox(
                        height: height * distortionValue,
                        child: child
                    )
                );
              },
            );
          },
          controller: _pageController,
          onPageChanged: (int index) {
            currentPage = _getRealIndex(index, realPage, widget.items.length);
            if (widget.updateCallback != null) widget.updateCallback(currentPage);
          },
        )),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    if (widget.pageController == null) {
      _pageController?.dispose();
      _pageController = null;
    }
    super.dispose();
  }
}