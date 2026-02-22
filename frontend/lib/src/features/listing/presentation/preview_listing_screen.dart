import 'package:flutter/material.dart';
import 'package:frontend/src/features/listing/domain/amenity_model.dart';
import 'package:go_router/go_router.dart';

// context.go('/previewListing', extra: {
//   'description': generatedDescription,
//   'amenities': suggestedAmenities,
// });

class PreviewListingScreen extends StatefulWidget {
  final String? id; // present when viewing saved listing
  final String? prefillDescription; // present when coming from Gemini
  final List<Amenity>? prefillAmenities;

  const PreviewListingScreen({
    super.key,
    this.id,
    this.prefillDescription,
    this.prefillAmenities,
  });

  @override
  State<PreviewListingScreen> createState() => _PreviewListingScreenState();
}

class _PreviewListingScreenState extends State<PreviewListingScreen> {
  bool _isEditingDescription = false;
  int _currentImageIndex = 0;
  bool _showAmenityModal = false;

  final TextEditingController _descriptionController = TextEditingController(
    text:
        'Experience authentic rural living in this charming traditional homestay. '
        'Nestled in the peaceful countryside, our home offers a perfect escape from city life. '
        'Enjoy home-cooked meals, beautiful nature views, and warm hospitality. '
        'Perfect for families and nature lovers seeking a unique cultural experience.',
  );

  final TextEditingController _customAmenityController =
      TextEditingController();

  final List<String> _sampleImages = const [
    'https://images.unsplash.com/photo-1689420749580-f74353865d03?w=800&q=80',
    'https://images.unsplash.com/photo-1712330138676-60e86456c218?w=800&q=80',
    'https://images.unsplash.com/photo-1689420749580-f74353865d03?w=800&q=80',
    'https://images.unsplash.com/photo-1712330138676-60e86456c218?w=800&q=80',
    'https://images.unsplash.com/photo-1689420749580-f74353865d03?w=800&q=80',
    'https://images.unsplash.com/photo-1712330138676-60e86456c218?w=800&q=80',
  ];

  List<Amenity> _selectedAmenities = [
    kPredefinedAmenities[0], // WiFi
    kPredefinedAmenities[2], // Parking
    kPredefinedAmenities[1], // AC
    kPredefinedAmenities[5], // Nature View
  ];

  @override
  void initState() {
    super.initState();
    if (widget.prefillDescription != null) {
      // Coming from Gemini — use the pre-filled data directly
      _descriptionController.text = widget.prefillDescription!;
      _selectedAmenities = widget.prefillAmenities ?? [];
    } else {
      //_fetchListing(widget.id!);  BACKEND will implement
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _customAmenityController.dispose();
    super.dispose();
  }

  List<Amenity> get _availableAmenities => kPredefinedAmenities
      .where((a) => !_selectedAmenities.any((s) => s.id == a.id))
      .toList();

  void _removeAmenity(String id) {
    setState(() {
      _selectedAmenities.removeWhere((a) => a.id == id);
    });
  }

  void _addPredefinedAmenity(Amenity amenity) {
    setState(() {
      _selectedAmenities.add(amenity);
      _showAmenityModal = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageCarousel(),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDescriptionSection(),
                              const SizedBox(height: 28),
                              _buildAmenitiesSection(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Fixed bottom button
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomButton()),
          // Amenity modal
          if (_showAmenityModal) _buildAmenityModal(),
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
        //borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
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
            onTap: () => context.go('/home'),
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
          const Text(
            'Preview Listing',
            style: TextStyle(
              fontSize: 21,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Image Carousel ──────────────────────────────────────────────────────────

  Widget _buildImageCarousel() {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _sampleImages[_currentImageIndex],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFE5E7EB),
              child: const Icon(
                Icons.image_not_supported_rounded,
                color: Color(0xFF9CA3AF),
                size: 48,
              ),
            ),
          ),
          // Prev button
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => setState(() {
                  _currentImageIndex = _currentImageIndex == 0
                      ? _sampleImages.length - 1
                      : _currentImageIndex - 1;
                }),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: Color(0x33000000), blurRadius: 6),
                    ],
                  ),
                  child: const Icon(Icons.chevron_left_rounded, size: 22),
                ),
              ),
            ),
          ),
          // Next button
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => setState(() {
                  _currentImageIndex =
                      (_currentImageIndex + 1) % _sampleImages.length;
                }),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: Color(0x33000000), blurRadius: 6),
                    ],
                  ),
                  child: const Icon(Icons.chevron_right_rounded, size: 22),
                ),
              ),
            ),
          ),
          // Dots
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _sampleImages.length,
                (idx) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: idx == _currentImageIndex ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: idx == _currentImageIndex
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Description ─────────────────────────────────────────────────────────────

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A0A0B),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(
                () => _isEditingDescription = !_isEditingDescription,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFf97316).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isEditingDescription
                          ? Icons.check_rounded
                          : Icons.edit_outlined,
                      color: const Color(0xFFf97316),
                      size: 20,
                    ),
                    SizedBox(width: 6),
                    Text(
                      _isEditingDescription ? 'Done' : 'Edit',
                      style: TextStyle(
                        color: const Color(0xFFf97316),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _isEditingDescription
            ? TextField(
                controller: _descriptionController,
                maxLines: null,
                minLines: 5,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF374151),
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFECFDF5),
                  contentPadding: const EdgeInsets.all(16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF059669),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF059669),
                      width: 2,
                    ),
                  ),
                ),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                ),
                child: Text(
                  _descriptionController.text,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF374151),
                    height: 1.5,
                  ),
                ),
              ),
      ],
    );
  }

  // ── Amenities ────────────────────────────────────────────────────────────────

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Amenities',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A0A0B),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _showAmenityModal = true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _selectedAmenities.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                ),
                child: const Text(
                  'No amenities added yet. Tap "Add" to include amenities.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                ),
              )
            : Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _selectedAmenities
                    .map((a) => _buildAmenityChip(a))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildAmenityChip(Amenity amenity) {
    return GestureDetector(
      onTap: () => _removeAmenity(amenity.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(amenity.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              amenity.label,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
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
            child: ElevatedButton(
              onPressed: () => context.go('/googleBusiness'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFf97316),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Continue to Google Business',
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Set up your profile',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
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
            child: OutlinedButton(
              onPressed: () => context.go('/airbnb'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF5A5F), width: 2),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Export to Airbnb',
                    style: TextStyle(
                      fontSize: 19,
                      color: Color(0xFFFF5A5F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Publish your listing',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF9CA3AF),
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

  // ── Amenity Modal ────────────────────────────────────────────────────────────

  Widget _buildAmenityModal() {
    return GestureDetector(
      onTap: () => setState(() => _showAmenityModal = false),
      child: Container(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // prevent tap-through
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Modal handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Modal header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 16, 16),
                    child: Row(
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Amenities',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0A0A0B),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Select from the amenities list below',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _showAmenityModal = false),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Color(0xFF0A0A0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  // Modal content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 17,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          // Predefined amenities
                          if (_availableAmenities.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                  width: 2,
                                ),
                              ),
                              child: const Text(
                                '🎉  All common amenities have been added!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            )
                          else ...[
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 2.8,
                              children: _availableAmenities
                                  .map(
                                    (a) => GestureDetector(
                                      onTap: () => _addPredefinedAmenity(a),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF9FAFB),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFE5E7EB),
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              a.icon,
                                              style: const TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                a.label,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF374151),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
