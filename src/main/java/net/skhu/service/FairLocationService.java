package net.skhu.service;

import java.util.List;
import java.util.stream.Collectors;

import org.neo4j.driver.exceptions.NoSuchRecordException;
import org.springframework.stereotype.Service;

import net.skhu.dto.CoordinateDto;
import net.skhu.dto.FairLocationRequest;
import net.skhu.dto.FairLocationResponse;
import net.skhu.dto.FairLocationRouteDetail;
import net.skhu.dto.OdsayRouteResponse;
import net.skhu.dto.StationDto;
import net.skhu.dto.StationMidpointResponse;

@Service
public class FairLocationService {

    private final StationSearchService stationSearchService;
    private final StationMidpointService stationMidpointService;
    private final OdsayService odsayService;
    private final PlaceAutoCompleteService coordinateSearchService;

    public FairLocationService(
        StationSearchService stationSearchService,
        StationMidpointService stationMidpointService,
        OdsayService odsayService,
        PlaceAutoCompleteService coordinateSearchService
    ) {
        this.stationSearchService = stationSearchService;
        this.stationMidpointService = stationMidpointService;
        this.odsayService = odsayService;
        this.coordinateSearchService = coordinateSearchService;
    }

    public FairLocationResponse calculateFairLocation(FairLocationRequest request) {
        // 1. 각 좌표 → 가장 가까운 역
        List<StationDto> nearestStations = request.getStartPoints().stream()
            .map(coord -> stationSearchService.findNearestStation(coord.getLatitude(), coord.getLongitude()))
            .collect(Collectors.toList());

        // 2. 이름 정제
        List<String> stationNames = nearestStations.stream()
            .map(this::normalizeStationName)
            .collect(Collectors.toList());

        // 3. 중간역 이름 계산
        StationMidpointResponse midpointResponse;
        try {
            midpointResponse = stationMidpointService.findMidStation(stationNames);
        } catch (NoSuchRecordException e) {
            throw new RuntimeException("중간역을 찾을 수 없습니다. 입력된 역 정보가 충분한지 확인해주세요.", e);
        }

        String midpointName = midpointResponse.getBalancedMidpoint();

        // 4. 중간역 좌표 조회
        CoordinateDto midpointCoord = coordinateSearchService.getCoordinate(midpointName);
        StationDto midpointStation = new StationDto(midpointName, midpointCoord.getLatitude(), midpointCoord.getLongitude());

        // 5. 각 출발역에서 중간역까지 단일 경로 계산
        List<FairLocationRouteDetail> routes = nearestStations.stream()
            .map(start -> {
                OdsayRouteResponse route = odsayService.fetchRoute(
                    start.getLongitude(), start.getLatitude(),
                    midpointStation.getLongitude(), midpointStation.getLatitude()
                );
                return new FairLocationRouteDetail(start, route);
            })
            .collect(Collectors.toList());

        return new FairLocationResponse(midpointStation, routes);
    }

    private String normalizeStationName(StationDto stationDto) {
        String name = stationDto.getName();
        return name.substring(0, name.indexOf("역")+1);
    }
}
