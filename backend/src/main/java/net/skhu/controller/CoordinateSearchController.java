package net.skhu.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import net.skhu.dto.CoordinateDto;
import net.skhu.service.PlaceAutoCompleteService;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/coordinate")
public class CoordinateSearchController {

    private final PlaceAutoCompleteService placeAutoCompleteService;

    /**
     * 자동완성 결과 리스트의 첫 번째 원소를 좌표로 변환하여 반환 (지하철역)
     */
    @GetMapping("/search")
    public ResponseEntity<CoordinateDto> getFirstCoordinate(@RequestParam String query) {
        if (query == null || query.trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        try {
            CoordinateDto coordinate = placeAutoCompleteService.getCoordinate(query);
            return ResponseEntity.ok(coordinate);
        } catch (RuntimeException e) {
            return ResponseEntity.noContent().build(); // 결과 없음
        }
    }
}
