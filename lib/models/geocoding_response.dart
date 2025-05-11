class GeocodingResponse {
  final String name;

  GeocodingResponse({required this.name});

  factory GeocodingResponse.fromJson(Map<String, dynamic> json) {
    return GeocodingResponse(
      name: json['name'] ?? '',
    );
  }
}
