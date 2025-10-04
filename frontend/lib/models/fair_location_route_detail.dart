import 'package:fair_front/models/location_dto.dart';
import 'odsay_route_response.dart';

class FairLocationRouteDetail {
  final LocationDto fromStation;
  final OdsayRouteResponse route;

  FairLocationRouteDetail({
    required this.fromStation,
    required this.route,
  });

  factory FairLocationRouteDetail.fromJson(Map<String, dynamic> json) {
    return FairLocationRouteDetail(
      fromStation: LocationDto.fromJson(json['fromStation']),
      route: OdsayRouteResponse.fromJson(json['route']),
    );
  }
}