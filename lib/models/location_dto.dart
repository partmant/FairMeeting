class LocationDto {
  final double latitude;
  final double longitude;
  final String name;

  LocationDto({
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  factory LocationDto.fromJson(Map<String, dynamic> json) {
    return LocationDto(
      latitude: json['latitude'],
      longitude: json['longitude'],
      name: json['name'],
    );
  }
}