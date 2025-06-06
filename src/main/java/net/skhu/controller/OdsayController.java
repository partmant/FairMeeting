// OdsayController.java
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
@RequestMapping("api/odsay")
@RequiredArgsConstructor
public class OdsayController {

    private final OdsayService odsayService;

    /**
     * GET /api/odsay/routes
     * @param mx 중간지점 경도
     * @param my 중간지점 위도
     * @param sx 출발지 경도 리스트
     * @param sy 출발지 위도 리스트
     */
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
            List<OdsayRouteResponse> routes = odsayService.fetchRoutesToMidpoint(mx, my, sx, sy);
            return ResponseEntity.ok(routes);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * GET /api/odsay/route
     * @param sx 출발지 경도
     * @param sy 출발지 위도
     * @param ex 도착지 경도
     * @param ey 도착지 위도
     */
    @GetMapping("/route")
    public ResponseEntity<List<OdsayRouteResponse>> getRoute(
            @RequestParam double sx,
            @RequestParam double sy,
            @RequestParam double ex,
            @RequestParam double ey
    ) {
        try {
            // fetchRoutes를 호출해서 전체 경로 리스트를 반환
            List<OdsayRouteResponse> routes = odsayService.fetchRoutes(sx, sy, ex, ey);
            return ResponseEntity.ok(routes);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }
}
