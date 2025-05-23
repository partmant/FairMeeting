class CategoryResponse {
  final String placeName;
  final String placeUrl;
  final String x;
  final String y;

  CategoryResponse({
    required this.placeName,
    required this.placeUrl,
    required this.x,
    required this.y,
  });

  factory CategoryResponse.fromJson(Map<String,dynamic> json) => CategoryResponse(
    placeName: json['place_name'],
    placeUrl:  json['place_url'],
    x:         json['x'],
    y:         json['y'],
  );
}