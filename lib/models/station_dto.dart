class StationDto {
  final double latitude;
  final double longitude;
  final String name;

  StationDto({
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  factory StationDto.fromJson(Map<String, dynamic> json) {
    return StationDto(
      latitude: json['latitude'],
      longitude: json['longitude'],
      name: json['name'],
    );
  }
}