import 'package:flutter/material.dart';
import 'login.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _pickupController;
  late Animation<double> _pickupAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _pickupController = AnimationController(
      duration: const Duration(milliseconds: 2050),
      vsync: this,
    );

    _pickupAnimation = Tween<double>(
      begin: 0.0,
      end: 2.05,
    ).animate(CurvedAnimation(
      parent: _pickupController,
      curve: Curves.linear,
    ));

    _controller.forward();


    Future.delayed(const Duration(milliseconds: 2050), () {
      _pickupController.forward();
    });


    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pickupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Splash.jpg', 
              fit: BoxFit.cover,
            ),
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                left: _animation.value * screenWidth,
                top: screenHeight * 0.4, 
                child: Image.asset(
                  'assets/jogging.png', 
                  width: 150,
                  height: 250,
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _pickupAnimation,
            builder: (context, child) {
              return Positioned(
                left: screenWidth * (0.36 + _pickupAnimation.value * 0.64), 
                top: screenHeight * 0.5, 
                child: Image.asset(
                  'assets/pickUpTrash.png', 
                  width: screenWidth * 0.3, 
                  height: screenHeight * 0.18, 
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
