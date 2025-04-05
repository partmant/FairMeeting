package net.skhu.controller;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import net.skhu.dto.CoordinateDto;
import net.skhu.dto.StationSearchResultDto;
import net.skhu.service.StationSearchService;

@RestController
@RequestMapping("/api")
public class StationSearchController {

    @Autowired
    private StationSearchService stationSearchService;

    /**
     * @param coordinateDtos 여러 개의 위도와 경도를 포함한 DTO 객체 리스트
     * @return 각 좌표에 대한 StationSearchResultDto 객체 리스트
     */
    @PostMapping("/nearby-stations")
    public ResponseEntity<List<StationSearchResultDto>> getNearbyStations(
            @RequestBody List<CoordinateDto> coordinateDtos) {
        if (coordinateDtos == null || coordinateDtos.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        // DTO -> 모델 변환, Service 호출, 그리고 모델 -> DTO 변환을 한 줄로 처리
        List<StationSearchResultDto> resultDtos = stationSearchService
            .getNearbyStations(
                coordinateDtos.stream()
                              .map(CoordinateDto::toEntity)
                              .collect(Collectors.toList())
            )
            .stream()
            .map(StationSearchResultDto::fromEntity)
            .collect(Collectors.toList());

        return ResponseEntity.ok(resultDtos);
    }
}
