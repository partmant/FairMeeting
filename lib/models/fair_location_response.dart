import 'package:fair_front/models/station_dto.dart';
import 'fair_location_route_detail.dart';

class FairLocationResponse {
  final StationDto midpointStation;
  final List<FairLocationRouteDetail> routes;

  FairLocationResponse({
    required this.midpointStation,
    required this.routes,
  });

  factory FairLocationResponse.fromJson(Map<String, dynamic> json) {
    return FairLocationResponse(
      midpointStation: StationDto.fromJson(json['midpointStation']),
      routes: (json['routes'] as List<dynamic>)
          .map((e) => FairLocationRouteDetail.fromJson(e))
          .toList(),
    );
  }
}