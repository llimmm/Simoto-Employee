import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For haptic feedback
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'splash/splash_screen.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with SingleTickerProviderStateMixin {
  double _dragValue = 0.0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 270), // Slightly slower for weight
      value: 0.0, // Initialize with zero!
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack, // Heavier curve with slight bounce
    );

    _animation.addListener(() {
      setState(() {
        _dragValue = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragValue += details.primaryDelta! / 235;
      _dragValue = _dragValue.clamp(0.0, 1.0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    // Add haptic feedback for that physical feeling
    HapticFeedback.mediumImpact();

    if (_dragValue > 0.5 || velocity > 600) {
      // Animate to end if dragged more than halfway or with high velocity
      _animationController.value = _dragValue;
      _animationController.animateTo(1.0).then((_) {
        Future.delayed(const Duration(milliseconds: 200), () {
          Get.offAll(() => const SplashScreen());

          // Reset safely
          if (mounted) {
            _animationController.value = 0.0;
            setState(() {
              _dragValue = 0.0;
            });
          }
        });
      });
    } else {
      // Animate back to start
      _animationController.value = _dragValue;
      _animationController.animateTo(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282828),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 35, left: 2.5),
            child: Image.asset(
              'assets/images/ssstart.png',
              width: 3750,
              height: 400,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 27),
          Padding(
            padding: const EdgeInsets.only(
                left: 35), // Increased left padding for alignment
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/kliktokos.png',
                width: 250,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: GestureDetector(
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              child: Container(
                width: 300,
                height: 60,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/ayomulai.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Stack(
                  children: [
                    // Progress fill with heavier animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutQuart,
                      width: 300 * _dragValue,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEFCDE),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    // Slider thumb with physical weight
                    Transform.translate(
                      offset: Offset(5 + (_dragValue * 235), 5),
                      child: Container(
                        alignment: Alignment.center,
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF7E7E7D),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 6,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                            // Inner highlight for 3D effect
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 2,
                              spreadRadius: 0,
                              offset: const Offset(0, -1),
                            )
                          ],
                        ),
                        child: SvgPicture.asset(
                          'assets/images/kons.svg',
                          width: 37,
                          height: 37,
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