package net.skhu.controller;

import java.util.ArrayList;
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
@RequestMapping("api/odsay")
@RequiredArgsConstructor
public class OdsayController {

    private final OdsayService odsayService;

    @GetMapping("/routes")
    public ResponseEntity<List<OdsayRouteResponse>> getRoutesToMidpoint(
            @RequestParam double mx,
            @RequestParam double my,
            @RequestParam List<Double> sx,
            @RequestParam List<Double> sy
    ) {
        if (sx.size() != sy.size()) {
            return ResponseEntity.badRequest().build();
        }

        try {
            List<OdsayRouteResponse> routes = new ArrayList<>();
            for (int i = 0; i < sx.size(); i++) {
                routes.add(odsayService.fetchRoute(sx.get(i), sy.get(i), mx, my));
            }
            return ResponseEntity.ok(routes);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

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
