import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/src/features/auth/data/auth_repository.dart';
import 'package:frontend/src/features/listing/data/listing_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class GenerateListingScreen extends ConsumerStatefulWidget {
  const GenerateListingScreen({super.key});

  @override
  ConsumerState<GenerateListingScreen> createState() =>
      _GenerateListingScreenState();
}

class _GenerateListingScreenState extends ConsumerState<GenerateListingScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();

  List<XFile> _photos = [];
  XFile? _voiceFile;

  bool _isUploadingPhoto = false;
  bool _isUploadingVoice = false;
  bool _isGenerating = false;

  bool get _isBusy => _isUploadingPhoto || _isUploadingVoice || _isGenerating;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // ── Your Functions (unchanged) ───────────────────────────────────────────────

  Future<void> _pickAndUploadPhoto() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isEmpty) return;

      setState(() => _isUploadingPhoto = true);

      final result = await ref
          .read(listingRepositoryProvider)
          .uploadPhoto(photos: images);

      setState(() => _isUploadingPhoto = false);

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() => _photos = [..._photos, ...images]);
        _showSnack('${images.length} photo(s) uploaded!', Colors.green);
      } else {
        _showSnack(result['error'] ?? 'Photo upload failed', Colors.red);
      }
    } catch (e) {
      setState(() => _isUploadingPhoto = false);
      _showSnack('Error: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _signOut() async {
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.signOut();
    if (mounted) context.go('/signIn');
  }

  Future<void> _pickAndUploadVoice() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result == null || result.files.single.bytes == null) return;

      final picked = result.files.single;
      final xfile = XFile.fromData(picked.bytes!, name: picked.name);

      setState(() => _isUploadingVoice = true);

      final uploadResult = await ref
          .read(listingRepositoryProvider)
          .uploadVoice(voiceFile: xfile);

      setState(() => _isUploadingVoice = false);

      if (!mounted) return;

      if (uploadResult['success'] == true) {
        setState(() => _voiceFile = xfile);
        _showSnack('Voice uploaded!', Colors.green);
      } else {
        _showSnack(uploadResult['error'] ?? 'Voice upload failed', Colors.red);
      }
    } catch (e) {
      setState(() => _isUploadingVoice = false);
      _showSnack('Error: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _generateListing() async {
    if (_photos.isEmpty) {
      _showSnack('Please upload at least one photo first', Colors.orange);
      return;
    }
    if (_voiceFile == null) {
      _showSnack('Please upload a voice recording first', Colors.orange);
      return;
    }

    // Fire the API call WITHOUT awaiting it — we hand the Future to LoadingScreen
    final future = ref
        .read(listingRepositoryProvider)
        .generateListing(photos: _photos, voiceFile: _voiceFile!);

    // Navigate immediately to LoadingScreen, passing the live future
    context.go('/loading', extra: future);
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // ── Build ────────────────────────────────────────────────────────────────────

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
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPhotoUploadSection(),
                          const SizedBox(height: 28),
                          _buildVoiceInputSection(),
                          const SizedBox(height: 20),
                          _buildTextInputSection(),
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

  // ── Header ───────────────────────────────────────────────────────────────────

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
          const Expanded(
            child: Text(
              'Create Listing',
              style: TextStyle(
                fontSize: 21,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Photo Upload ─────────────────────────────────────────────────────────────

  Widget _buildPhotoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Photos',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A0A0B),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Upload 3–10 images',
          style: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 78, 78, 84),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._photos.map((img) => _buildImageThumbnail(img)),
              if (_photos.length < 10) _buildAddImageButton(),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${_photos.length} of 10 photos',
          style: const TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 78, 78, 84),
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(XFile img) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
            color: const Color(0xFFF3F4F6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FutureBuilder<Uint8List>(
              future: img.readAsBytes(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  );
                }
                return const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF059669),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Color(0xFF059669),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _isBusy ? null : _pickAndUploadPhoto,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF059669), width: 2),
        ),
        child: _isUploadingPhoto
            ? const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF059669),
                    ),
                  ),
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xFF059669),
                    size: 28,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Voice Input ──────────────────────────────────────────────────────────────

  Widget _buildVoiceInputSection() {
    final bool voiceReady = _voiceFile != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Describe Your Homestay',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A0A0B),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _isBusy ? null : _pickAndUploadVoice,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: voiceReady
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: voiceReady
                    ? const Color(0xFF059669)
                    : const Color(0xFFD1D5DB),
                width: 2,
              ),
            ),
            child: _isUploadingVoice
                ? const Column(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF059669),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Uploading voice...',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: voiceReady
                              ? const Color(0xFF059669)
                              : const Color(0xFF9CA3AF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          voiceReady
                              ? Icons.mic_rounded
                              : Icons.mic_none_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        voiceReady ? 'Voice Ready ✓' : 'Upload Voice Recording',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: voiceReady
                              ? const Color(0xFF059669)
                              : const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        voiceReady
                            ? _voiceFile!.name
                            : 'Tap to select an audio file',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ── Text Input ───────────────────────────────────────────────────────────────

  Widget _buildTextInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Or type here (optional)',
          style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Tell us about your homestay...',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 18),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom Button ─────────────────────────────────────────────────────────────

  Widget _buildBottomButton() {
    final bool canGenerate = _photos.isNotEmpty && _voiceFile != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: (_isBusy || !canGenerate) ? null : _generateListing,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: canGenerate ? 1.0 : 0.5,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316),
              borderRadius: BorderRadius.circular(20),
              boxShadow: canGenerate
                  ? const [
                      BoxShadow(
                        color: Color(0x40F97316),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: _isGenerating
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Generating...',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Generate Listing',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
