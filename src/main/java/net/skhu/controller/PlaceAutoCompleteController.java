package net.skhu.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import net.skhu.dto.PlaceAutoCompleteResponse;
import net.skhu.service.PlaceAutoCompleteService;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/places")
public class PlaceAutoCompleteController {

    @Autowired
    private PlaceAutoCompleteService placeAutoCompleteService;

    /**
     * @param query 검색어
     * @return 자동완성 결과 리스트
     */
    @GetMapping("/autocomplete")
    public ResponseEntity<List<PlaceAutoCompleteResponse>> getAutoComplete(@RequestParam String query) {
        if (query == null || query.trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        List<PlaceAutoCompleteResponse> result = placeAutoCompleteService.getAutoComplete(query);
        return result != null ? ResponseEntity.ok(result) : ResponseEntity.internalServerError().build();
    }
}
