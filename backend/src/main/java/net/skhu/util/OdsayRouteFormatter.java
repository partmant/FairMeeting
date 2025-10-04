package net.skhu.util;

import java.util.List;

// 콘솔 확인용 출력문
public class OdsayRouteFormatter {

    public static void printRoutes(List<OdsayDetailedRoute> routes) {
        int routeNumber = 1;

        for (OdsayDetailedRoute route : routes) {
            System.out.println("🚍 [경로 " + routeNumber++ + "]");

            System.out.println("출발지: " + route.getStartName() + formatCoord(route.getStartCoord()));
            System.out.println("목적지: " + route.getEndName() + formatCoord(route.getEndCoord()));
            System.out.println("총 소요시간: " + route.getTotalTime() + "분, 총 요금: " + route.getPayment() + "원");
            System.out.println("버스 환승: " + route.getBusTransitCount() + "회, 지하철 환승: " + route.getSubwayTransitCount() + "회\n");

            int step = 1;
            for (OdsaySubPath subPath : route.getSubPaths()) {
                switch (subPath.getTrafficType()) {
                    case 1 -> { // 지하철
                        System.out.println(step++ + ". 지하철 탑승: " + subPath.getLineName() + " "
                                + subPath.getStartName() + formatCoord(subPath.getStartCoord()) + " → "
                                + subPath.getEndName() + formatCoord(subPath.getEndCoord()));
                        System.out.println("   - " + subPath.getStationCount() + "개 역 이동 (약 " + subPath.getSectionTime() + "분 소요)");
                        System.out.println("   - 중간 환승 없이 직행\n");
                    }
                    case 2 -> { // 버스
                        System.out.println(step++ + ". 버스 탑승: " + String.join(", ", subPath.getLaneNames()));
                        System.out.println("   - 승차: " + subPath.getStartName() + formatCoord(subPath.getStartCoord()));
                        System.out.println("   - 하차: " + subPath.getEndName() + formatCoord(subPath.getEndCoord())
                                + " (약 " + subPath.getSectionTime() + "분 소요)\n");
                    }
                    case 3 -> { // 도보
                        System.out.println(step++ + ". 도보: 약 " + subPath.getDistance() + "m 이동 (약 "
                                + subPath.getSectionTime() + "분)\n");
                    }
                    default -> System.out.println(step++ + ". 알 수 없는 이동 수단\n");
                }
            }

            System.out.println("----------------------------------------------------------------\n");
        }
    }

    private static String formatCoord(String coord) {
        return coord != null && !coord.isBlank() ? " " + coord : "";
    }
}
