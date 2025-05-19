package net.skhu.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;
import net.skhu.dto.OdsayRouteResponse;
import net.skhu.util.OdsayDetailedRoute;
import net.skhu.util.OdsayRouteFormatter;
import net.skhu.util.OdsaySubPath;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Service
@RequiredArgsConstructor
public class OdsayService {

    @Value("${odsay.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    // 검색 결과 하나만 출력
    public OdsayRouteResponse fetchRoute(double sx, double sy, double ex, double ey) {
        try {
            String url = UriComponentsBuilder.fromUriString("https://api.odsay.com/v1/api/searchPubTransPathT")
                    .queryParam("SX", sx)
                    .queryParam("SY", sy)
                    .queryParam("EX", ex)
                    .queryParam("EY", ey)
                    .queryParam("apiKey", URLEncoder.encode(apiKey, StandardCharsets.UTF_8))
                    .toUriString();

            ResponseEntity<String> response = restTemplate.exchange(
                    url,
                    HttpMethod.GET,
                    new HttpEntity<>(new HttpHeaders()),
                    String.class
            );

            if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
                throw new RuntimeException("ODsay API 응답 오류: " + response.getStatusCode());
            }

            JsonNode root = objectMapper.readTree(response.getBody());
            JsonNode paths = root.path("result").path("path");

            if (!paths.isArray() || paths.isEmpty()) {
                throw new RuntimeException("ODsay API 경로 없음");
            }

            JsonNode path = paths.get(0); // 첫 번째 경로만 사용
            JsonNode info = path.path("info");

            int totalBusTime = 0;
            int totalSubwayTime = 0;
            int totalWalkTime = 0;

            for (JsonNode subPath : path.path("subPath")) {
                int trafficType = subPath.path("trafficType").asInt();
                int sectionTime = subPath.path("sectionTime").asInt();

                switch (trafficType) {
                    case 1 -> totalSubwayTime += sectionTime;
                    case 2 -> totalBusTime += sectionTime;
                    case 3 -> totalWalkTime += sectionTime;
                }
            }

            OdsayRouteResponse route = new OdsayRouteResponse();
            route.setRouteNumber(1);
            route.setTotalTime(info.path("totalTime").asInt());
            route.setPayment(info.path("payment").asInt());
            route.setSubwayTransitCount(info.path("subwayTransitCount").asInt());
            route.setBusTransitCount(info.path("busTransitCount").asInt());
            route.setTotalBusTime(totalBusTime);
            route.setTotalSubwayTime(totalSubwayTime);
            route.setTotalWalkTime(totalWalkTime);

            return route;
        } catch (Exception e) {
            throw new RuntimeException("ODsay API 호출 또는 파싱 실패: " + e.getMessage(), e);
        }
    }

    // 검색 결과 전체 출력
    public List<OdsayRouteResponse> fetchRoutes(double sx, double sy, double ex, double ey) {
        try {
            String url = UriComponentsBuilder.fromUriString("https://api.odsay.com/v1/api/searchPubTransPathT")
                    .queryParam("SX", sx)
                    .queryParam("SY", sy)
                    .queryParam("EX", ex)
                    .queryParam("EY", ey)
                    .queryParam("apiKey", URLEncoder.encode(apiKey, StandardCharsets.UTF_8))
                    .toUriString();

            ResponseEntity<String> response = restTemplate.exchange(
                    url,
                    HttpMethod.GET,
                    new HttpEntity<>(new HttpHeaders()),
                    String.class
            );

            if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
				throw new RuntimeException("ODsay API 응답 오류: " + response.getStatusCode());
			}

            JsonNode root = objectMapper.readTree(response.getBody());
            JsonNode paths = root.path("result").path("path");

            List<OdsayRouteResponse> routeResponses = new ArrayList<>();
            List<OdsayDetailedRoute> detailedRoutes = new ArrayList<>();

            int routeNumber = 1;

            for (JsonNode path : paths) {
                JsonNode info = path.path("info");

                int totalBusTime = 0;
                int totalSubwayTime = 0;
                int totalWalkTime = 0;

                // 서브 경로 분석
                for (JsonNode subPath : path.path("subPath")) {
                    int trafficType = subPath.path("trafficType").asInt();
                    int sectionTime = subPath.path("sectionTime").asInt();

                    switch (trafficType) {
                        case 1 -> totalSubwayTime += sectionTime;
                        case 2 -> totalBusTime += sectionTime;
                        case 3 -> totalWalkTime += sectionTime;
                    }
                }

                // 사용자에게 전달할 요약 정보
                OdsayRouteResponse route = new OdsayRouteResponse();
                route.setRouteNumber(routeNumber++);
                route.setTotalTime(info.path("totalTime").asInt());
                route.setPayment(info.path("payment").asInt());
                route.setSubwayTransitCount(info.path("subwayTransitCount").asInt());
                route.setBusTransitCount(info.path("busTransitCount").asInt());
                route.setTotalBusTime(totalBusTime);
                route.setTotalSubwayTime(totalSubwayTime);
                route.setTotalWalkTime(totalWalkTime);
                routeResponses.add(route);

                // 출력용 상세 경로
                OdsayDetailedRoute detail = new OdsayDetailedRoute();
                detail.setTotalTime(route.getTotalTime());
                detail.setPayment(route.getPayment());
                detail.setStartName(info.path("firstStartStation").asText());
                detail.setEndName(info.path("lastEndStation").asText());
                detail.setStartCoord(formatCoord(info.path("mapY"), info.path("mapX")));
                detail.setEndCoord(formatCoord(info.path("mapY2"), info.path("mapX2")));
                detail.setBusTransitCount(route.getBusTransitCount());
                detail.setSubwayTransitCount(route.getSubwayTransitCount());

                List<OdsaySubPath> subPaths = new ArrayList<>();
                for (JsonNode subPath : path.path("subPath")) {
                    OdsaySubPath sp = new OdsaySubPath();
                    int trafficType = subPath.path("trafficType").asInt();
                    sp.setTrafficType(trafficType);
                    sp.setStartName(subPath.path("startName").asText());
                    sp.setEndName(subPath.path("endName").asText());
                    sp.setStartCoord(formatCoord(subPath.path("startY"), subPath.path("startX")));
                    sp.setEndCoord(formatCoord(subPath.path("endY"), subPath.path("endX")));
                    sp.setSectionTime(subPath.path("sectionTime").asInt());

                    if (trafficType == 1) {
                        sp.setLineName(subPath.path("lane").get(0).path("name").asText());
                        sp.setStationCount(subPath.path("stationCount").asInt());
                    } else if (trafficType == 2) {
                        List<String> laneNames = new ArrayList<>();
                        for (JsonNode lane : subPath.path("lane")) {
                            laneNames.add(lane.path("busNo").asText());
                        }
                        sp.setLaneNames(laneNames);
                    } else if (trafficType == 3) {
                        sp.setDistance(subPath.path("distance").asInt());
                    }

                    subPaths.add(sp);
                }

                detail.setSubPaths(subPaths);
                detailedRoutes.add(detail);

            }

            // 콘솔 출력
            OdsayRouteFormatter.printRoutes(detailedRoutes);

            return routeResponses;
        } catch (Exception e) {
            throw new RuntimeException("ODsay API 호출 또는 파싱 실패: " + e.getMessage(), e);
        }
    }

    private String formatCoord(JsonNode latNode, JsonNode lngNode) {
        if (latNode == null || lngNode == null || latNode.isMissingNode() || lngNode.isMissingNode()) {
            return "";
        }
        return "(" + latNode.asText() + ", " + lngNode.asText() + ")";
    }
}
