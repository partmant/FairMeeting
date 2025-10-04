package net.skhu.service;

import java.util.List;
import java.util.stream.Collectors;

import org.neo4j.driver.exceptions.NoSuchRecordException;
import org.springframework.stereotype.Service;

import lombok.Data;
import net.skhu.dto.CoordinateDto;
import net.skhu.dto.FairLocationRequest;
import net.skhu.dto.FairLocationResponse;
import net.skhu.dto.FairLocationRouteDetail;
import net.skhu.dto.OdsayRouteResponse;
import net.skhu.dto.PlaceDto;
import net.skhu.dto.StationMidpointResponse;

@Service
@Data
public class FairLocationService {

	private final StationSearchService stationSearchService;
	private final StationMidpointService stationMidpointService;
	private final OdsayService odsayService;
	private final PlaceAutoCompleteService coordinateSearchService;

	public FairLocationResponse calculateFairLocation(FairLocationRequest request) {
		// 1. 각 좌표 → 가장 가까운 역
		List<PlaceDto> originalPoints = request.getStartPoints();
		List<PlaceDto> nearestStations = originalPoints.stream()
				.map(p -> stationSearchService.findNearestStation(p.getLatitude(), p.getLongitude()))
				.collect(Collectors.toList());

		System.out.println("nearestStations(역 이름): " + nearestStations);

		// 2. 이름 정제
		List<String> stationNames = nearestStations.stream().map(this::normalizeStationName)
				.collect(Collectors.toList());

		System.out.println(stationNames);

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
		PlaceDto midpointStation = new PlaceDto(midpointName, midpointCoord.getLatitude(),
				midpointCoord.getLongitude());

		// 5. 각 출발역에서 중간역까지 단일 경로 계산
		List<FairLocationRouteDetail> routes = nearestStations.stream().map(start -> {
			OdsayRouteResponse route = odsayService.fetchRoute(start.getLongitude(), start.getLatitude(),
					midpointStation.getLongitude(), midpointStation.getLatitude());
			return new FairLocationRouteDetail(start, route);
		}).collect(Collectors.toList());

		// 6. 소요 시간 0분 예외 처리 (출발지 2개인 경우에만)
		if (routes.size() == 2) {
		    boolean hasZeroTime = routes.stream()
		        .anyMatch(route -> route.getRoute().getTotalTime() == 0);

		    if (hasZeroTime) {
		        throw new IllegalArgumentException("소요 시간이 0분인 출발지가 존재합니다. 출발지를 다시 설정해주세요.");
		    }
		}

		// 요청으로 받은 출발지점 이름으로 덮어쓰기
		for (int i = 0; i < routes.size(); i++) {
            PlaceDto original = originalPoints.get(i);
            FairLocationRouteDetail detail = routes.get(i);
            detail.getFromStation().setLatitude(original.getLatitude());
            detail.getFromStation().setLongitude(original.getLongitude());
            detail.getFromStation().setName(original.getName());
        }

		return new FairLocationResponse(midpointStation, routes);
	}

	private String normalizeStationName(PlaceDto stationDto) {
		String name = stationDto.getName();
		return name.substring(0, name.indexOf("역") + 1);
	}
}
