package net.skhu.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import net.skhu.dto.StationDto;

@Service
public class StationSearchService {

    @Value("${kakao.rest.api.key}")
    private String restApiKey;

    /**
     * 주어진 좌표를 기준으로 가장 가까운 지하철역을 반환
     *
     * @param latitude 위도
     * @param longitude 경도
     * @return 가장 가까운 역 정보
     */
    public StationDto findNearestStation(double latitude, double longitude) {
        String categoryGroupCode = "SW8";
        int radius = 3000;

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "KakaoAK " + restApiKey);
        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();

        String url = String.format(
            "https://dapi.kakao.com/v2/local/search/category.json?category_group_code=%s&x=%f&y=%f&radius=%d",
            categoryGroupCode, longitude, latitude, radius
        );

        try {
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);
            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                List<Map<String, Object>> docs = (List<Map<String, Object>>) response.getBody().get("documents");

                if (!docs.isEmpty()) {
                    Map<String, Object> doc = docs.get(0); // 가장 가까운 역
                    String name = (String) doc.get("place_name");
                    double x = Double.parseDouble(doc.get("x").toString());
                    double y = Double.parseDouble(doc.get("y").toString());

                    return new StationDto(name, y, x);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        throw new RuntimeException("가까운 지하철역을 찾을 수 없습니다.");
    }
}
