package net.skhu.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import net.skhu.dto.StationMidpointRequest;
import net.skhu.dto.StationMidpointResponse;
import net.skhu.service.StationMidpointService;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/station")
@Validated
public class StationMidpointController {

    private final StationMidpointService stationService;

    /**
     * 여러 출발역을 바디로 받아서 하나의 균형 기반 중간역 정보를 반환한다.
     */
    @PostMapping("/midpoint")
    public ResponseEntity<StationMidpointResponse> getMidStation(
            @Valid @RequestBody StationMidpointRequest request
    ) {
        List<String> sources = request.getSources();
        StationMidpointResponse response = stationService.findBestMidpoint(sources);

        if (response == null) {
            return ResponseEntity.internalServerError().build();
        }
        return ResponseEntity.ok(response);
    }
}
