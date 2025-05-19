package net.skhu.service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import net.skhu.dto.CoordinateDto;
import net.skhu.dto.PlaceAutoCompleteResponse;

@Service
public class PlaceAutoCompleteService {

    @Value("${kakao.rest.api.key}")
    private String restApiKey;

    private final RestTemplate restTemplate = new RestTemplate();

    public List<PlaceAutoCompleteResponse> getAutoComplete(String query) {
        String url = "https://dapi.kakao.com/v2/local/search/keyword.json?query=" + query;

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "KakaoAK " + restApiKey);
        HttpEntity<String> entity = new HttpEntity<>(headers);

        ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);

        if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
            List<Map<String, Object>> documents = (List<Map<String, Object>>) response.getBody().get("documents");

            // 1. category_group_code가 SW8인 항목을 우선 정렬
            List<Map<String, Object>> sorted = documents.stream()
                .sorted(Comparator.comparing((Map<String, Object> doc) -> {
                    Object category = doc.get("category_group_code");
                    return "SW8".equals(category) ? 0 : 1;
                }))
                .collect(Collectors.toList());

            // 2. 변환
            List<PlaceAutoCompleteResponse> result = new ArrayList<>();

            for (Map<String, Object> doc : sorted) {
                String placeName = (String) doc.get("place_name");
                String roadAddress = (String) doc.get("road_address_name");
                double x = Double.parseDouble((String) doc.get("x"));
                double y = Double.parseDouble((String) doc.get("y"));

                result.add(new PlaceAutoCompleteResponse(placeName, roadAddress, y, x));
            }

            return result;
        }

        return Collections.emptyList();
    }

    /**
     * 자동완성 결과 리스트에서 가장 첫 번째 결과의 좌표를 CoordinateDto로 반환
     */
    public CoordinateDto getCoordinate(String query) {
        List<PlaceAutoCompleteResponse> results = getAutoComplete(query);

        if (results != null && !results.isEmpty()) {
            PlaceAutoCompleteResponse first = results.get(0);
            return new CoordinateDto(first.getLatitude(), first.getLongitude());
        }

        throw new RuntimeException("좌표를 찾을 수 없습니다: " + query);
    }
}
