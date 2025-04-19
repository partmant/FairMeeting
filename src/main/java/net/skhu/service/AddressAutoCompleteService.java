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
    	System.out.println("[주소 자동완성 요청] query: " + query);	// 확인용 출력문
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
                if (documents == null) {
                    return null;
                }
                // "category_group_code"가 "SW8"(지하철)인 항목을 우선 정렬
                List<Map<String, Object>> sortedDocuments = documents.stream()
                    .sorted((doc1, doc2) -> {
                        String cat1 = doc1.get("category_group_code") != null ?
                                      doc1.get("category_group_code").toString() : "";
                        String cat2 = doc2.get("category_group_code") != null ?
                                      doc2.get("category_group_code").toString() : "";
                        if (cat1.equals("SW8") && !cat2.equals("SW8")) {
							return -1;
						} else if (!cat1.equals("SW8") && cat2.equals("SW8")) {
							return 1;
						}
                        return 0;
                    })
                    .collect(Collectors.toList());

                // 각 문서에서 place_name, y(위도), x(경도) 필드만 추출
                List<Map<String, Object>> filtered = sortedDocuments.stream().map(doc -> {
                    Map<String, Object> result = new HashMap<>();
                    result.put("name", doc.get("place_name"));
                    result.put("lat", Double.parseDouble(doc.get("y").toString()));
                    result.put("lng", Double.parseDouble(doc.get("x").toString()));
                    return result;
                }).collect(Collectors.toList());

                return filtered;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
