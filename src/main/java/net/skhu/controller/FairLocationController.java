package net.skhu.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import net.skhu.dto.FairLocationRequest;
import net.skhu.dto.FairLocationResponse;
import net.skhu.service.FairLocationService;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/fair-location")
public class FairLocationController {

    private final FairLocationService fairLocationService;

    @PostMapping
    public ResponseEntity<FairLocationResponse> getFairLocation(@Valid @RequestBody FairLocationRequest request) {
        FairLocationResponse response = fairLocationService.calculateFairLocation(request);
        return ResponseEntity.ok(response);
    }
}
