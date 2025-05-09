package net.skhu.dto;

import lombok.Data;

@Data
public class OdsayRouteResponse {
    private int routeNumber;             // 경로 번호
    private int totalTime;               // 총 소요 시간 (분)
    private int payment;                 // 총 비용 (원)
    private int busTransitCount;         // 버스 환승 횟수
    private int subwayTransitCount;      // 지하철 환승 횟수
    private int totalBusTime;            // 총 버스 이동 시간
    private int totalSubwayTime;         // 총 지하철 이동 시간
    private int totalWalkTime;           // 총 도보 이동 시간
}
