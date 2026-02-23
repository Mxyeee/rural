import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingScreen extends StatefulWidget {
  final Future<Map<String, dynamic>> generationFuture;

  const LoadingScreen({super.key, required this.generationFuture});

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
    _run();
  }

  Future<void> _run() async {
    final results = await Future.wait([
      _runAnimation(),
      widget.generationFuture,
    ]);

    if (!mounted) return;

    final apiResult = results[1] as Map<String, dynamic>;

    if (apiResult['success'] == true) {
      context.go(
        '/previewListing',
        extra: {
          'title': apiResult['listing']?['title'],
          'description': apiResult['listing']?['description'],
        },
      );
    } else {
      final error = apiResult['error'] ?? 'Generation failed';
      context.go('/generateListing');
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _runAnimation() async {
    for (int i = 1; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      setState(() => _currentStep = i);
    }
    await Future.delayed(const Duration(milliseconds: 800));
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
                const Spacer(flex: 3),

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

                const Text(
                  'Creating Magic',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 48),

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
                          vertical: isActive ? 36 : 23,
                          horizontal: 25,
                        ),
                        child: Row(
                          children: [
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

                const Spacer(flex: 2),

                const Text(
                  'Please wait...',
                  style: TextStyle(
                    fontSize: 21,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
