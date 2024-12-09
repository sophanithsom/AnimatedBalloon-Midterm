import 'package:flutter/material.dart';

class AnimatedBalloonWidget extends StatefulWidget {
  @override
  _AnimatedBalloonWidgetState createState() => _AnimatedBalloonWidgetState();
}

class _AnimatedBalloonWidgetState extends State<AnimatedBalloonWidget> with TickerProviderStateMixin {
  late AnimationController _controllerFloatUp;
  late AnimationController _controllerGrowSize;
  late AnimationController _controllerRotate;
  late Animation<double> _animationFloatUp;
  late Animation<double> _animationGrowSize;
  late Animation<double> _animationRotate;

  // Variables for interaction
  Offset _balloonPosition = Offset(0, 0);  // Start at initial position
  double _balloonScale = 1.0;              // Initial scale factor

  @override
  void initState() {
    super.initState();
    _controllerFloatUp = AnimationController(duration: Duration(seconds: 8), vsync: this);
    _controllerGrowSize = AnimationController(duration: Duration(seconds: 4), vsync: this);
    _controllerRotate = AnimationController(duration: Duration(seconds: 4), vsync: this)..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controllerFloatUp.dispose();
    _controllerGrowSize.dispose();
    _controllerRotate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _balloonHeight = MediaQuery.of(context).size.height / 2;
    double _balloonWidth = MediaQuery.of(context).size.height / 3;
    double _balloonBottomLocation = MediaQuery.of(context).size.height - _balloonHeight;

    _animationFloatUp = Tween(begin: _balloonBottomLocation, end: 0.0).animate(
      CurvedAnimation(parent: _controllerFloatUp, curve: Curves.linear),
    );

    _animationGrowSize = Tween(begin: 50.0, end: _balloonWidth).animate(
      CurvedAnimation(parent: _controllerGrowSize, curve: Curves.linear),
    );

    _animationRotate = Tween(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controllerRotate, curve: Curves.easeInOut),
    );

    _controllerFloatUp.forward();
    _controllerGrowSize.forward();

    return AnimatedBuilder(
      animation: _animationFloatUp,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(top: _animationFloatUp.value),
          width: _animationGrowSize.value * _balloonScale,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          if (_controllerFloatUp.isCompleted) {
            _controllerFloatUp.reverse();
            _controllerGrowSize.reverse();
          } else {
            _controllerFloatUp.forward();
            _controllerGrowSize.forward();
          }
        },
        onScaleUpdate: (details) {
          setState(() {
            _balloonPosition += details.focalPointDelta; // Update position by translation
            _balloonScale = details.scale.clamp(0.5, 2.0); // Update scale, with limits
          });
        },
        child: Transform.translate(
          offset: _balloonPosition,
          child: RotationTransition(
            turns: _animationRotate,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Shadow layer
                Positioned(
                  top: 15, // Adjust offset to position shadow
                  left: 10, // Adjust offset to position shadow
                  child: Opacity(
                    opacity: 0.2, // Lower opacity for shadow effect
                    child: Image.asset(
                      'assets/images/BeginningGoogleFlutter-Balloon.png',
                      height: _balloonHeight * _balloonScale,
                      width: _balloonWidth * _balloonScale,
                      color: Colors.black, // Make shadow darker
                      colorBlendMode: BlendMode.srcATop, // Blend for shadow effect
                    ),
                  ),
                ),
                // Main balloon image
                Image.asset(
                  'assets/images/BeginningGoogleFlutter-Balloon.png',
                  height: _balloonHeight * _balloonScale,
                  width: _balloonWidth * _balloonScale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
