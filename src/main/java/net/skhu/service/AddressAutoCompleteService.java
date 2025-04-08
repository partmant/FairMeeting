package net.skhu.service;

import java.util.HashMap;
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

@Service
public class AddressAutoCompleteService {

    @Value("${kakao.rest.api.key}")
    private String kakaoRestApiKey;

    public List<Map<String, Object>> getAutoComplete(String query) {
        // Kakao API 호출 URL (여기서는 추가적인 좌표나 반경 파라미터 없이 오직 query만 사용)
        System.out.println(query);			// 디버깅용 코드
    	String url = String.format(
            "https://dapi.kakao.com/v2/local/search/keyword.json?query=%s",
            query
        );

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "KakaoAK " + kakaoRestApiKey);
        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();

        try {
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);
            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                Map<String, Object> body = response.getBody();
                List<Map<String, Object>> documents = (List<Map<String, Object>>) body.get("documents");
                // 각 문서에서 장소 이름(place_name), 위도(y), 경도(x)만 필터링
                return documents.stream().map(doc -> {
                    Map<String, Object> result = new HashMap<>();
                    result.put("name", doc.get("place_name"));
                    result.put("lat", Double.parseDouble(doc.get("y").toString()));
                    result.put("lng", Double.parseDouble(doc.get("x").toString()));
                    return result;
                }).collect(Collectors.toList());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
