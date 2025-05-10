package net.skhu.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import net.skhu.dto.StationMidpointResponse;
import net.skhu.service.StationMidpointService;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/station")
public class StationMidpointController {

    private final StationMidpointService stationService;

    /**
     * 출발지와 도착지를 쿼리로 받아 시간 균형 기반 중간역 정보를 반환한다.
     */
    @GetMapping("/midpoint")
    public ResponseEntity<StationMidpointResponse> getMidStation(
            @RequestParam String source,
            @RequestParam String target
    ) {
        StationMidpointResponse response = stationService.findMidpoint(source, target);

        if (response == null) {
            return ResponseEntity.internalServerError().build();
        }

        return ResponseEntity.ok(response);
    }
}
