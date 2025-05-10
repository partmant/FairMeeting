package net.skhu.service;

import java.util.ArrayList;
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
     * 주어진 위도와 경도를 기준으로 주변 지하철역을 조회한다.
     *
     * @param latitude 위도
     * @param longitude 경도
     * @return 인근 지하철역 리스트
     */
    public List<StationDto> getNearbyStations(double latitude, double longitude) {
        List<StationDto> stations = new ArrayList<>();

        String categoryGroupCode = "SW8";
        int radius = 2000;

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

                for (Map<String, Object> doc : docs) {
                    String name = (String) doc.get("place_name");
                    double x = Double.parseDouble(doc.get("x").toString());
                    double y = Double.parseDouble(doc.get("y").toString());

                    stations.add(new StationDto(name, y, x));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return stations;
    }
}
