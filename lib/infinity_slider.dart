library infinity_slider;

import 'package:flutter/material.dart';
import 'dart:async';

int kRealPage;
double autoMaxPage;
double autoMinPage;

int _calcIndex(int input, int source) {
  final int result = input % source;
  return result < 0 ? source + result : result;
}

int _getRealIndex(int position, int base, int length) {
  final int offset = position - base;
  return _calcIndex(offset, length);
}

class InfinitySlider extends StatefulWidget {
  final int initialPage;
  final List<Widget> items;
  final bool autoPlay;
  final Duration interval;
  final Curve transCurve;
  final Duration transDuration;
  final double height;
  final PageController pageController;

  InfinitySlider({
    Key key,
    @required this.items,
    this.height: 120,
    this.initialPage: 0,
    this.autoPlay: true,
    this.interval: const Duration(seconds: 2),
    this.transDuration: const Duration(milliseconds: 800),
    this.transCurve: Curves.fastOutSlowIn,
  })  : pageController = new PageController(
          initialPage: kRealPage + initialPage,
        ),
        assert(items != null),
        assert(items.length > 0),
        assert(initialPage != null),
        assert(autoPlay != null),
        assert(interval != null),
        assert(transDuration != null),
        assert(transCurve != null),
        super(key: key) {
    kRealPage = items.length;
    autoMinPage = 0.0;
    autoMaxPage = (items.length * 2).toDouble();
  }

  @override
  _InfinitySliderState createState() => _InfinitySliderState();

  Future<void> nextPage({Duration duration, Curve curve}) {
    return pageController.nextPage(duration: duration, curve: curve);
  }

  Future<void> previousPage({Duration duration, Curve curve}) {
    return pageController.previousPage(duration: duration, curve: curve);
  }
}

class _InfinitySliderState extends State<InfinitySlider> {
  int currentPage;
  Timer timer;

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(() {
      if (widget.pageController.page == autoMinPage ||
          widget.pageController.page == autoMaxPage) {
        widget.pageController.position
            .setPixels(MediaQuery.of(context).size.width * kRealPage);
      }
    });
    currentPage = widget.initialPage;
    if (widget.autoPlay) {
      timer = new Timer.periodic(widget.interval, (_) {
        widget.nextPage(
            duration: widget.transDuration, curve: widget.transCurve);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: PageView.builder(
        itemBuilder: (BuildContext context, int i) {
          final int index = _getRealIndex(i, kRealPage, widget.items.length);
          return widget.items[index];
        },
        controller: widget.pageController,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }
}
