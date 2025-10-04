package net.skhu.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import net.skhu.dto.GeocodingResponse;
import net.skhu.service.GeocodingService;

@RestController
@RequestMapping("/api/geocoding")
@RequiredArgsConstructor
public class GeocodingController {

    private final GeocodingService geocodingService;

    /**
     * 좌표를 받아 주소 또는 건물명 반환
     * @param lat 위도
     * @param lng 경도
     * @return GeocodingResponse (name 필드 포함)
     */
    @GetMapping("/address")
    public GeocodingResponse getAddressName(
            @RequestParam double lat,
            @RequestParam double lng
    ) {
        return geocodingService.getAddressName(lat, lng);
    }
}
