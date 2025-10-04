package net.skhu.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import net.skhu.dto.PlaceDto;
import net.skhu.service.StationSearchService;

@RestController
@RequestMapping("/api/station")
public class StationSearchController {

    @Autowired
    private StationSearchService stationSearchService;

    /**
     * 쿼리 스트링으로 받은 위도와 경도를 기준으로 주변 지하철역을 조회한다.
     *
     * @param latitude 위도
     * @param longitude 경도
     * @return 인근 지하철역 목록
     */
    @GetMapping("/search")
    public ResponseEntity<PlaceDto> getNearbyStations(
            @RequestParam double lat,
            @RequestParam double lng) {
        PlaceDto result = stationSearchService.findNearestStation(lat, lng);
        return ResponseEntity.ok(result);
    }
}
