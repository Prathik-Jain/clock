import 'dart:ui';
import 'package:clock/ETGPainter.dart';
import 'package:clock/colors.dart';
import 'package:clock/time.dart';
import 'package:flutter/material.dart';

class Clock extends StatefulWidget {
  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> with TickerProviderStateMixin {
  Animation<Offset> _linesXAnimation;
  Animation<Offset> _linesYAnimation;
  AnimationController _gridController;

  Animation<double> _pulseAnimation;
  AnimationController _pulseController;

  final Time _time = Time();
  final List _lines = List.generate(15, (i) => i);
  final double _gridGap = 50;
  final double _lineThickness = 1;

  double percent = 0.0;

  @override
  void initState() {
    super.initState();

    // Listen to change in time
    _time.addListener(
      () => setState(() {
        _pulseController.forward();
      }),
    );

    // Grid Animation
    _gridController =
        AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..repeat(reverse: true);

    _linesXAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0.02, 0),
    ).animate(
        CurvedAnimation(parent: _gridController, curve: Curves.easeInOut));

    _linesYAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 0.02),
    ).animate(
        CurvedAnimation(parent: _gridController, curve: Curves.easeInOut));

    // Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _pulseAnimation =
        CurveTween(curve: Curves.decelerate).animate(_pulseController);

    _pulseAnimation.addListener(
      () => setState(() {
        percent = _pulseAnimation.value;
        if (percent == 1) {
          _pulseController.reset();
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: AspectRatio(
          aspectRatio: 5 / 3,
          child: Stack(
            fit: StackFit.loose,
            overflow: Overflow.clip,
            children: <Widget>[
              Container(
                color: background,
              ),
              SlideTransition(
                position: _linesXAnimation,
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  children: _lines
                      .map<Widget>(
                        (i) => Container(
                          width: _gridGap,
                          alignment: Alignment.topLeft,
                          child: Container(
                            width: _lineThickness,
                            height: double.infinity,
                            color: foreground,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              SlideTransition(
                position: _linesYAnimation,
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  children: _lines
                      .map<Widget>(
                        (i) => Container(
                          alignment: Alignment.topLeft,
                          height: _gridGap,
                          child: Container(
                            height: _lineThickness,
                            width: double.infinity,
                            color: foreground,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    child: Text(
                      "${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontFamily: "monospace",
                        color: foreground,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 4),
                            color: Colors.black54,
                            blurRadius: 4,
                          ),
                          Shadow(
                            offset: Offset(8, 16),
                            color: Colors.black12,
                            blurRadius: 32,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                child: CustomPaint(
                  painter: ETGPainter(percent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
