import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../loginComponents/LoginBottomSheet.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double _dragValue = 0.0;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragValue += details.primaryDelta! / 150; // Increased sensitivity
      _dragValue = _dragValue.clamp(0.0, 1.0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragValue > 0.6) {
      // Reduced threshold for activation
      setState(() {
        _dragValue = 1.0;
      });

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const LoginBottomSheet(),
      );

      Future.delayed(const Duration(milliseconds: 300), () {
        // Reduced delay
        setState(() {
          _dragValue = 0.0;
        });
      });
    } else {
      setState(() {
        _dragValue = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/bacgroungorg.png',
            width: 300,
            height: 400,
          ),
          const SizedBox(height: 10),
          Transform.translate(
            offset: const Offset(-30, 0),
            child: Container(
              width: 235,
              height: 49,
              alignment: Alignment.centerLeft,
              child: const Text(
                'KlikToko',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Transform.translate(
            offset: const Offset(15, 0),
            child: Container(
              width: 325,
              height: 30,
              alignment: Alignment.centerLeft,
              child: const Text(
                'For employees',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          const SizedBox(height: 80), // Reduced space before the swipe button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: GestureDetector(
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              child: Container(
                width: 300,
                height: 60,
                margin: const EdgeInsets.only(bottom: 50),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 50), // Faster animation
                      width: 300 * _dragValue,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    AnimatedPositioned(
                      duration:
                          const Duration(milliseconds: 50), // Faster animation
                      left: 5 + (_dragValue * 235),
                      top: 5,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF333333),
                        ),
                        child: SvgPicture.asset(
                          'assets/images/kons.svg',
                          width: 10,
                          height: 10,
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Swipe To Start',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
