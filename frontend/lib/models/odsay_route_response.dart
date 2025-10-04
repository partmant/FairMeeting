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

  /// 버스 환승과 지하철 환승을 합산한 총 환승 횟수
  int get totalTransitCount => busTransitCount + subwayTransitCount;

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