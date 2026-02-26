import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class AirbnbProfileScreen extends StatefulWidget {
  final Map<String, dynamic> listingData;

  const AirbnbProfileScreen({super.key, required this.listingData});

  @override
  State<AirbnbProfileScreen> createState() => _AirbnbProfileScreenState();
}

class _AirbnbProfileScreenState extends State<AirbnbProfileScreen> {
  String? _copiedField;
  final Set<int> _completedSteps = {};

  late final String _businessName = widget.listingData['title'] ?? 'New Listing';
  late final String _businessDescription = widget.listingData['description'] ?? '';

  late final List<String> _amenities = List<String>.from(widget.listingData['amenities'] ?? []);

  static const _steps = [
    'Open the Airbnb website (airbnb.com)',
    "Click 'Airbnb your home' or 'Become a Host'",
    'Create an Airbnb account or sign in',
    'Choose your property type (e.g. Entire home)',
    'Copy and paste your listing title below',
    'Copy and paste your description below',
    'Add your address and exact location on the map',
    'Set your amenities (which you selected in your listing) and house rules',
    'Upload at least 5 photos of your homestay',
    'Set your nightly price and availability',
    'Review and publish your listing',
  ];

  void _copyToClipboard(String field, String text) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copiedField = field);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedField = null);
    });
  }

  void _toggleStep(int index) {
    setState(() {
      if (_completedSteps.contains(index)) {
        _completedSteps.remove(index);
      } else {
        _completedSteps.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 200),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWhySection(),
                          const SizedBox(height: 24),
                          _buildCopyInfoSection(),
                          const SizedBox(height: 24),
                          _buildStepsSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomButton()),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF059669),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/previewListing'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Airbnb',
                  style: TextStyle(
                    fontSize: 21,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Get more bookings via Airbnb',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Why Section ─────────────────────────────────────────────────────────────

  Widget _buildWhySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 236, 244, 253),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromARGB(255, 179, 214, 255),
          width: 2,
        ),
      ),
      child: const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why Airbnb?',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A0A0B),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Help guests find your homestay on an app with millions of users like Airbnb. It's free and easy!",
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 78, 78, 84),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Copy Info Section ────────────────────────────────────────────────────────

  Widget _buildCopyInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Copy This Information',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A0A0B),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Listing Title',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A0A0B),
          ),
        ),
        const SizedBox(height: 4),
        // Business Name
        _buildCopyRow(value: _businessName, field: 'name', multiLine: false),
        const SizedBox(height: 12),
        // Description
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A0A0B),
          ),
        ),
        const SizedBox(height: 4),
        _buildDescriptionCopyCard(),
        const SizedBox(height: 12),
        const Text(
          'Amenities',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A0A0B),
          ),
        ),
        const SizedBox(height: 4),
        // Category
        _buildAmenityGrid(),
      ],
    );
  }

  Widget _buildAmenityGrid() {
    if (_amenities.isEmpty) return const Text("No amenities listed");

    return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _amenities.map((amenity) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
            ),
            child: Text(
              amenity,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      );
    }

  Widget _buildCopyRow({
    required String value,
    required String field,
    required bool multiLine,
  }) {
    final isCopied = _copiedField == field;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _copyToClipboard(field, value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCopied ? Icons.check_rounded : Icons.copy_rounded,
                    size: 16,
                    color: const Color(0xFF059669),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isCopied ? 'Copied!' : 'Copy',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCopyCard() {
    final isCopied = _copiedField == 'description';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _businessDescription,
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF374151),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _copyToClipboard('description', _businessDescription),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCopied ? Icons.check_rounded : Icons.copy_rounded,
                    size: 16,
                    color: const Color(0xFF059669),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isCopied ? 'Copied!' : 'Copy',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Steps Section ────────────────────────────────────────────────────────────

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Follow These Steps',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A0A0B),
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(_steps.length, (index) {
          final isCompleted = _completedSteps.contains(index);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => _toggleStep(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF6EE7B7)
                        : const Color(0xFFE5E7EB),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFF059669)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCompleted
                              ? const Color(0xFF059669)
                              : const Color(0xFFD1D5DB),
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            )
                          : Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _steps[index],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? const Color(0xFF047857)
                              : const Color(0xFF0A0A0B),
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Bottom Button ────────────────────────────────────────────────────────────

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                html.window.open("https://www.airbnb.com/host/homes", "_blank");
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF5A5F), width: 2),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.open_in_new_rounded,
                    color: Color(0xFFFF5A5F),
                    size: 25,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Open Airbnb',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFFFF5A5F),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 27),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Back to Dashboard',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
