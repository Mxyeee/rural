import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/src/constant.dart';
import 'package:frontend/src/features/listing/data/listing_repository.dart';
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

  List<XFile> _photos = [];
  XFile? _voiceFile;
  Map<String, dynamic>? _listing;

  bool _isUploadingPhoto = false;
  bool _isUploadingVoice = false;
  bool _isGenerating = false;

  bool get _isBusy => _isUploadingPhoto || _isUploadingVoice || _isGenerating;

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

  Future<void> _pickAndUploadVoice() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result == null || result.files.single.bytes == null) return;

      // Wrap the picked file as XFile using the name
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

    try {
      setState(() => _isGenerating = true);

      final result = await ref
          .read(listingRepositoryProvider)
          .generateListing(photos: _photos, voiceFile: _voiceFile!);

      setState(() => _isGenerating = false);

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() => _listing = result['listing']);
        _showSnack('Listing created!', Colors.green);
      } else {
        _showSnack(result['error'] ?? 'Generation failed', Colors.red);
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      _showSnack('Error: ${e.toString()}', Colors.red);
    }
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Pick & Upload Photo
              ElevatedButton.icon(
                onPressed: _isBusy ? null : _pickAndUploadPhoto,
                icon: _isUploadingPhoto
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(
                  _isUploadingPhoto ? 'Uploading...' : 'Pick & Upload Photo',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              if (_photos.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${_photos.length} photo(s) ready',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Upload Voice
              ElevatedButton.icon(
                onPressed: _isBusy ? null : _pickAndUploadVoice,
                icon: _isUploadingVoice
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        _voiceFile != null
                            ? Icons.mic_rounded
                            : Icons.mic_none_rounded,
                      ),
                label: Text(
                  _isUploadingVoice
                      ? 'Uploading...'
                      : _voiceFile != null
                      ? 'Voice Ready ✓'
                      : 'Upload Voice Recording',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: _voiceFile != null
                      ? Colors.green[600]
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Create Listing
              ElevatedButton.icon(
                onPressed: _isBusy ? null : _generateListing,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_isGenerating ? 'Generating...' : 'Create Listing'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (_listing != null)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _listing!['title'] ?? 'Your Listing',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _listing!['description'] ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Backend Connection',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connected to Django backend\nAuthentication: Firebase Auth\nStorage: Firebase Storage',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.blue[900]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

AppBar customAppBar() {
  const kGreenDark = Color(0xFF267A54);

  return AppBar(
    backgroundColor: kGreen,
    centerTitle: false,
    toolbarHeight: 70,
    title: const Text(
      'RumahGen',
      style: TextStyle(fontSize: 28, color: Colors.white, letterSpacing: 0.53),
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
    ),
    leading: Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: kGreenDark.withOpacity(0.45),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.house_rounded),
      ),
    ),
    actions: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.language_rounded, color: kWhite, size: 16),
          SizedBox(width: 4),
          Text(
            'EN',
            style: TextStyle(
              color: kWhite,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
      IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () {},
        tooltip: 'Sign Out',
      ),
    ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(70.0),
      child: Container(
        padding: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
        child: const Row(
          children: [
            Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ],
        ),
      ),
    ),
  );
}
