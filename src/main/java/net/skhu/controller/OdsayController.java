package net.skhu.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import net.skhu.dto.OdsayRouteResponse;
import net.skhu.service.OdsayService;

@RestController
@RequestMapping("/odsay")
@RequiredArgsConstructor
public class OdsayController {

    private final OdsayService odsayService;

    @GetMapping("/route")
    public ResponseEntity<List<OdsayRouteResponse>> getRoute(
            @RequestParam double sx,
            @RequestParam double sy,
            @RequestParam double ex,
            @RequestParam double ey
    ) {
        try {
            List<OdsayRouteResponse> routes = odsayService.fetchRoutes(sx, sy, ex, ey);
            return ResponseEntity.ok(routes);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }
}
