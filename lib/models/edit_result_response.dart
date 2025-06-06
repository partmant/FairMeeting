import 'location_dto.dart';
import 'odsay_route_response.dart';

class EditResultResponse {
  final LocationDto midpoint;
  final List<OdsayRouteResponse> routes;

  EditResultResponse({
    required this.midpoint,
    required this.routes,
  });

  factory EditResultResponse.fromJson(Map<String, dynamic> json) {
    final midpointJson = json['midpoint'] as Map<String, dynamic>;
    final routesJson = (json['routes'] as List<dynamic>).cast<Map<String, dynamic>>();

    return EditResultResponse(
      midpoint: LocationDto.fromJson(midpointJson),
      routes: routesJson
          .map((e) => OdsayRouteResponse.fromJson(e))
          .toList(),
    );
  }
}
