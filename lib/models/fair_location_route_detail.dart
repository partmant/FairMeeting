import 'package:fair_front/models/station_dto.dart';
import 'odsay_route_response.dart';

class FairLocationRouteDetail {
  final StationDto fromStation;
  final OdsayRouteResponse route;

  FairLocationRouteDetail({
    required this.fromStation,
    required this.route,
  });

  factory FairLocationRouteDetail.fromJson(Map<String, dynamic> json) {
    return FairLocationRouteDetail(
      fromStation: StationDto.fromJson(json['fromStation']),
      route: OdsayRouteResponse.fromJson(json['route']),
    );
  }
}