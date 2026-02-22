import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  int _currentStep = 0;

  static const _steps = [
    (icon: Icons.camera_alt_outlined, label: 'Analyzing Photos'),
    (icon: Icons.description_outlined, label: 'Understanding Description'),
    (icon: Icons.auto_awesome_outlined, label: 'Generating Listing'),
  ];

  @override
  void initState() {
    super.initState();
    _runSteps();
  }

  Future<void> _runSteps() async {
    for (int i = 1; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      setState(() => _currentStep = i);
    }
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    context.go('/preview');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Spacer(flex: 3),
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(255, 88, 88, 88),
                        blurRadius: 40,
                        offset: Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_awesome_outlined,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.7),
                    size: 85,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Creating Magic',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 48),

                // Steps
                Column(
                  children: List.generate(_steps.length, (idx) {
                    final step = _steps[idx];
                    final isComplete = idx < _currentStep;
                    final isActive = idx == _currentStep;

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: idx < _steps.length - 1 ? 20 : 0,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isComplete
                              ? const Color.fromARGB(219, 255, 255, 255)
                              : isActive
                              ? Colors.white
                              : const Color.fromARGB(87, 227, 227, 227),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: isActive ? 36 : 23, // smaller when inactive
                          horizontal: 25,
                        ),
                        child: Row(
                          children: [
                            // Step icon / check
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isComplete
                                    ? const Color(0xFF059669)
                                    : isActive
                                    ? Theme.of(context).colorScheme.secondary
                                    : const Color.fromARGB(152, 245, 243, 240),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: isComplete
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    )
                                  : Icon(
                                      step.icon,
                                      color: isActive
                                          ? const Color.fromARGB(
                                              210,
                                              232,
                                              232,
                                              236,
                                            )
                                          : const Color.fromARGB(
                                              214,
                                              229,
                                              167,
                                              228,
                                            ),
                                      size: 30,
                                    ),
                            ),

                            const SizedBox(width: 16),

                            // Label
                            Expanded(
                              child: Text(
                                step.label,
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: isActive
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  color: isActive
                                      ? const Color(0xFF0A0A0B)
                                      : isComplete
                                      ? const Color(0xFF059669)
                                      : const Color.fromARGB(
                                          164,
                                          253,
                                          253,
                                          253,
                                        ),
                                ),
                              ),
                            ),

                            // Active spinner
                            if (isActive)
                              SizedBox(
                                width: 45,
                                child: LoadingAnimationWidget.waveDots(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  size: 50,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                Spacer(flex: 2),
                const Text(
                  'Please wait...',
                  style: TextStyle(
                    fontSize: 21,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
