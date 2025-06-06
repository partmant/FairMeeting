package net.skhu.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import net.skhu.dto.EditResultResponse;
import net.skhu.dto.GeocodingResponse;
import net.skhu.dto.OdsayRouteResponse;
import net.skhu.dto.PlaceDto;

@Service
public class EditResultService {

    private final OdsayService odsayService;
    private final GeocodingService geocodingService;

    @Autowired
    public EditResultService(
            OdsayService odsayService,
            GeocodingService geocodingService) {
        this.odsayService = odsayService;
        this.geocodingService = geocodingService;
    }

    /**
     * 중간지점 좌표(mx, my)와 출발지 좌표 리스트(sx, sy)를 받아
     * 각 출발지 → 중간지점 경로와 중간지점 이름을 포함한 EditResultResponse를 반환합니다.
     *
     * @param mx 중간지점 경도
     * @param my 중간지점 위도
     * @param sx 출발지 경도 리스트
     * @param sy 출발지 위도 리스트
     * @return EditResultResponse(PlaceDto midpoint, List<OdsayRouteResponse> routes)
     */
    public EditResultResponse getEditResult(
            double mx,
            double my,
            List<Double> sx,
            List<Double> sy
    ) {
        // 1) 각 출발지 → 중간지점 경로 조회
        List<OdsayRouteResponse> routes = new ArrayList<>();
        for (int i = 0; i < sx.size(); i++) {
            double startX = sx.get(i);
            double startY = sy.get(i);
            OdsayRouteResponse route = odsayService.fetchRoute(startX, startY, mx, my);
            routes.add(route);
        }

        // 2) 중간지점 좌표(my, mx)로 장소명 또는 주소 조회
        GeocodingResponse geoResp = geocodingService.getAddressName(my, mx);
        String centerName = geoResp.getName();

        // 3) PlaceDto 생성 (이름, 위도, 경도)
        PlaceDto midpoint = new PlaceDto(centerName, my, mx);

        // 4) EditResultResponse 반환
        return new EditResultResponse(midpoint, routes);
    }
}
