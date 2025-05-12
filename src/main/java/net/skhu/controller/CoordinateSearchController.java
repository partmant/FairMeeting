package net.skhu.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import net.skhu.dto.CoordinateDto;
import net.skhu.dto.PlaceAutoCompleteResponse;
import net.skhu.service.PlaceAutoCompleteService;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/coordinate")
public class CoordinateSearchController {

    private final PlaceAutoCompleteService placeAutoCompleteService;

    @GetMapping("/search")
    public ResponseEntity<CoordinateDto> getFirstCoordinate(@RequestParam String query) {
        if (query == null || query.trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        String modifiedQuery = query;

        List<PlaceAutoCompleteResponse> results = placeAutoCompleteService.getAutoComplete(modifiedQuery);

        if (results != null && !results.isEmpty()) {
            PlaceAutoCompleteResponse first = results.get(0);
            CoordinateDto coordinate = new CoordinateDto(first.getLatitude(), first.getLongitude());
            return ResponseEntity.ok(coordinate);
        }

        return ResponseEntity.noContent().build();
    }
}
