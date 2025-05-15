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

class OdsayRouteResponse {
  final int routeNumber;
  final int totalTime;
  final int payment;
  final int busTransitCount;
  final int subwayTransitCount;
  final int totalBusTime;
  final int totalSubwayTime;
  final int totalWalkTime;

  OdsayRouteResponse({
    required this.routeNumber,
    required this.totalTime,
    required this.payment,
    required this.busTransitCount,
    required this.subwayTransitCount,
    required this.totalBusTime,
    required this.totalSubwayTime,
    required this.totalWalkTime,
  });

  factory OdsayRouteResponse.fromJson(Map<String, dynamic> json) {
    return OdsayRouteResponse(
      routeNumber: json['routeNumber'],
      totalTime: json['totalTime'],
      payment: json['payment'],
      busTransitCount: json['busTransitCount'],
      subwayTransitCount: json['subwayTransitCount'],
      totalBusTime: json['totalBusTime'],
      totalSubwayTime: json['totalSubwayTime'],
      totalWalkTime: json['totalWalkTime'],
    );
  }
}

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
