import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/src/config/backend_config.dart';
import 'package:frontend/src/features/auth/data/auth_repository.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:frontend/src/features/home/domain/listing_model.dart';
import 'dart:html';

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
      final token = _authRepository.idToken;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/generate_listing/'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token' ;
      }

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
        final photoUrls = List<String>.from(data['photo_urls'] ?? []);
  

              
        return {
          'success': true,
          'listingId': data['listing_id'],
          'listing': data['listing'],
          'photoUrls': photoUrls
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

  Future<Map<String, dynamic>> getUserPhotos() async {
  try {
    final uid = _authRepository.userId;

    final response = await http.post(
      Uri.parse('$baseUrl/get_user_photos/'),
      body: {
        'uid': uid ?? '',
      },
    );

    final data = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data['success'] == true) {
      return {
        'success': true,
        'photoUrls': List<String>.from(data['photo_urls'] ?? []),
      };
    } else {
      return {
        'success': false,
        'error': data['error'] ?? 'Failed to fetch photos',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': e.toString(),
    };
  }
  }


Future<List<Listing>> fetchListings() async {
  final token = _authRepository.idToken; 
  if (token == null || token.isEmpty) return [];

  final response = await http.get(
    Uri.parse('$baseUrl/listings/'), 
    headers: {'Authorization': 'Bearer $token'},
  );

  final data = jsonDecode(response.body);
  if (response.statusCode == 200 && data['success'] == true) {
    final listingsMap = data['listings'] as Map<String, dynamic>? ?? {};
    return listingsMap.entries.map((entry) {
      final listingData = Map<String, dynamic>.from(entry.value);
      listingData['id'] = entry.key;
      return Listing.fromJson(listingData);
    }).toList();
  }
  return [];
}
}

@riverpod
ListingRepository listingRepository(Ref ref) {
  return ListingRepository(
    baseUrl: BackendConfig.baseUrl,
    authRepository: ref.watch(authRepositoryProvider),
  );
}

final listingsProvider = FutureProvider<List<Listing>>((ref) async {
  final repo = ref.watch(listingRepositoryProvider);
  final token = ref.watch(authRepositoryProvider).idToken;

  if (token == null) return [];

  return repo.fetchListings();
});