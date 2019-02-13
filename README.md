# infinity_slider

A infinity slider widget, support infinite scroll and autoplay feature.

## Installation

Add `infinity_slider: ^0.0.1` in your `pubspec.yaml` dependencies. And import it:

```dart
import 'package:infinity_slider/infinity_slider.dart';
```

## How to use

Simply create a `InifitySlider` widget, and pass the required params:

```dart
InfinitySlider(
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
  height: 400.0,
  autoPlay: true
)
```

You can pass the above params to the class. If you pass the `height` params, the `aspectRatio` param will be ignore.

## Instance methods

You can use the instance methods to programmatically take control of the pageView's position.

### `.nextPage({Duration duration, Curve curve})`

Animate to the next page

### `.previousPage({Duration duration, Curve curve})`

Animate to the previous page

## Faq

### Can I display a dotted indicator for the slider?

Yes, you can.

```dart
class InfinityWithIndicator extends StatefulWidget {
  @override
  _InfinityWithIndicatorState createState() => _InfinityWithIndicatorState();
}

class _InfinityWithIndicatorState extends State<InfinityWithIndicator> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InfinitySlider(
          items: child,
          autoPlay: true,
          updateCallback: (index) {
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