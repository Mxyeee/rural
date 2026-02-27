class Listing {
  final String id;
  final String name;
  final String thumbnail;
  final String pricePerNight;
  final String propertyType;
  final String description;
  final List<String> photoUrls;

  const Listing({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.pricePerNight,
    required this.propertyType,
    required this.description,
    required this.photoUrls,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    final rawPhotos = json['photo_urls'];
    List<String> photos = [];

    if (rawPhotos is List) {
      photos = List<String>.from(rawPhotos);
    } else if (rawPhotos is Map) {
      photos = rawPhotos.values.map((e) => e.toString()).toList();
    }

    return Listing(
      id: json['listing_id'] ?? json['id'] ?? '',
      name: json['title'] ?? json['name'] ?? 'Unnamed Listing',
      thumbnail: photos.isNotEmpty ? photos[0] : '',
      pricePerNight: json['price_per_night'] ?? '',
      propertyType: json['property_type'] ?? '',
      description: json['description'] ?? '',
      photoUrls: photos,
    );
  }
}