class PlaceAutoCompleteResponse {
  final String placeName;
  final String roadAddress;
  final double latitude;
  final double longitude;

  PlaceAutoCompleteResponse({
    required this.placeName,
    required this.roadAddress,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceAutoCompleteResponse.fromJson(Map<String, dynamic> json) {
    return PlaceAutoCompleteResponse(
      placeName: json['placeName'] ?? '',
      roadAddress: json['roadAddress'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}
