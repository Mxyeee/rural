class Amenity {
  final String id;
  final String icon;
  final String label;
  final bool isCustom;

  const Amenity({
    required this.id,
    required this.icon,
    required this.label,
    this.isCustom = false,
  });
}

const List<Amenity> kPredefinedAmenities = [
  // Basics
  Amenity(id: 'wifi', icon: '📶', label: 'WiFi'),
  Amenity(id: 'tv', icon: '📺', label: 'TV'),
  Amenity(id: 'kitchen', icon: '🍳', label: 'Kitchen'),
  Amenity(id: 'washer', icon: '🧺', label: 'Washer'),
  Amenity(id: 'free_parking', icon: '🚗', label: 'Free Parking'),
  Amenity(id: 'paid_parking', icon: '🅿️', label: 'Paid Parking'),
  Amenity(id: 'ac', icon: '❄️', label: 'Air Conditioner'),
  Amenity(id: 'workspace', icon: '💼', label: 'Dedicated Workspace'),
  // Outdoor & leisure
  Amenity(id: 'pool', icon: '🏊', label: 'Pool'),
  Amenity(id: 'hot_tub', icon: '🛁', label: 'Hot Tub'),
  Amenity(id: 'patio', icon: '🪑', label: 'Patio'),
  Amenity(id: 'bbq', icon: '🔥', label: 'BBQ Grill'),
  Amenity(id: 'outdoor_dining', icon: '🍽️', label: 'Outdoor Dining Area'),
  Amenity(id: 'fire_pit', icon: '🪵', label: 'Fire Pit'),
  Amenity(id: 'outdoor_shower', icon: '🚿', label: 'Outdoor Shower'),
  Amenity(id: 'lake_access', icon: '🏞️', label: 'Lake Access'),
  Amenity(id: 'beach_access', icon: '🏖️', label: 'Beach Access'),
  // Indoor extras
  Amenity(id: 'pool_table', icon: '🎱', label: 'Pool Table'),
  Amenity(id: 'fireplace', icon: '🔥', label: 'Indoor Fireplace'),
  Amenity(id: 'piano', icon: '🎹', label: 'Piano'),
  Amenity(id: 'exercise', icon: '🏋️', label: 'Exercise Equipment'),
  // Safety
  Amenity(id: 'smoke_alarm', icon: '🚨', label: 'Smoke Alarm'),
  Amenity(id: 'first_aid', icon: '🩹', label: 'First Aid Kit'),
  Amenity(id: 'fire_extinguisher', icon: '🧯', label: 'Fire Extinguisher'),
  Amenity(id: 'co_alarm', icon: '⚠️', label: 'Carbon Monoxide Alarm'),
];
