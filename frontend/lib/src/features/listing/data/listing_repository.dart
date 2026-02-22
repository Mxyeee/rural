import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/src/config/backend_config.dart';
import 'package:frontend/src/features/auth/data/auth_repository.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'listing_repository.g.dart';

class ListingRepository {
  final String baseUrl;
  final AuthRepository _authRepository;

  ListingRepository({
    required this.baseUrl,
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  Future<Map<String, dynamic>> uploadPhoto({
    required List<XFile> photos,
  }) async {
    try {
      // get UID from _authRepository
      final uid = _authRepository.userId;
      print('Current UID: $uid'); 

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload_photo/'),
      );

      if (uid != null) request.fields['uid'] = uid;

      for (final photo in photos) {
        final bytes = await photo.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: photo.name),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        return {
          'success': true,
          'photoUrls': List<String>.from(data['photo_url'] ?? []),
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Photo upload failed',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> uploadVoice({
    required XFile voiceFile,
  }) async {
    try {
      final uid = _authRepository.userId;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload_voice/'),
      );

      if (uid != null) request.fields['uid'] = uid;

      final bytes = await voiceFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes('voice', bytes, filename: voiceFile.name),
      );

      final response = await http.Response.fromStream(await request.send());
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'voiceUrl': data['voice_url']};
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Voice upload failed',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> generateListing({
    required List<XFile> photos,
    required XFile voiceFile,
  }) async {
    try {
      final uid = _authRepository.userId;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/generate_listing/'),
      );

      if (uid != null) request.fields['uid'] = uid;

      for (final photo in photos) {
        final bytes = await photo.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: photo.name),
        );
      }

      final voiceBytes = await voiceFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'voice',
          voiceBytes,
          filename: voiceFile.name,
        ),
      );

      final response = await http.Response.fromStream(await request.send());
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'listingId': data['listing_id'],
          'listing': data['listing'],
        };
      } else {
        return {
          'success': false,
          'error':
              data['error'] ?? data['Error'] ?? 'Listing generation failed',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}

@riverpod
ListingRepository listingRepository(Ref ref) {
  return ListingRepository(
    baseUrl: BackendConfig.baseUrl,
    authRepository: ref.watch(authRepositoryProvider),
  );
}