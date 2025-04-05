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

import net.skhu.model.Coordinate;
import net.skhu.model.Station;
import net.skhu.model.StationSearchResult;

@Service
public class StationSearchService {

    @Value("${kakao.rest.api.key}")
    private String restApiKey;

    /*
     *  @param coordinates 여러 개의 위도와 경도를 포함한 객체 리스트
     * @return 각 좌표에 대한 StationSearchResult 객체 리스트
     */
    public List<StationSearchResult> getNearbyStations(List<Coordinate> coordinates) {
        List<StationSearchResult> results = new ArrayList<>();
        // 카테고리 그룹 코드 "SW8": 지하철역
        String categoryGroupCode = "SW8";
        int radius = 2000; // (단위: 미터)

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "KakaoAK " + restApiKey);
        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();

        for (Coordinate coordinate : coordinates) {
            String url = String.format(
                    "https://dapi.kakao.com/v2/local/search/category.json?category_group_code=%s&x=%f&y=%f&radius=%d",
                    categoryGroupCode, coordinate.getLng(), coordinate.getLat(), radius
            );

            try {
                ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);
                List<Station> stations = new ArrayList<>();
                if (response.getStatusCode() == HttpStatus.OK) {
                    Map<String, Object> body = response.getBody();
                    List<Map<String, Object>> documents = (List<Map<String, Object>>) body.get("documents");
                    for (Map<String, Object> doc : documents) {
                        String placeName = (String) doc.get("place_name");
                        double x = Double.parseDouble(doc.get("x").toString());
                        double y = Double.parseDouble(doc.get("y").toString());
                        stations.add(new Station(placeName, y, x)); // y: 위도, x: 경도
                    }
                }
                results.add(new StationSearchResult(coordinate, stations));
            } catch (Exception e) {
                e.printStackTrace();
                // 예외 발생 시 빈 리스트를 결과에 추가
                results.add(new StationSearchResult(coordinate, new ArrayList<>()));
            }
        }
        return results;
    }
}
