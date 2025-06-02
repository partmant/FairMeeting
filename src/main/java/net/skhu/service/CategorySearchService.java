package net.skhu.service;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;
import net.skhu.dto.CategoryResponse;
@Service
@RequiredArgsConstructor
public class CategorySearchService {

    @Value("${kakao.rest.api.key}")
    private String restApiKey;

    private final RestTemplate restTemplate = new RestTemplate();
    private static final int FIXED_RADIUS = 600;           // 고정 반경
    private static final String SORT_BY_DISTANCE = "distance";
    private static final int MAX_PAGE = 3;                  // 최대 3페이지까지 조회

    public List<CategoryResponse> searchByCategory(String categoryCode, double x, double y) {
        String url = "https://dapi.kakao.com/v2/local/search/category.json";
        List<CategoryResponse> allResults = new ArrayList<>();

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "KakaoAK " + restApiKey);
        HttpEntity<Void> entity = new HttpEntity<>(headers);

        for (int page = 1; page <= MAX_PAGE; page++) {
            UriComponentsBuilder uriBuilder = UriComponentsBuilder
                    .fromUriString(url)                                  // 기존 fromUriString 사용
                    .queryParam("category_group_code", categoryCode)
                    .queryParam("x", x)
                    .queryParam("y", y)
                    .queryParam("radius", FIXED_RADIUS)
                    .queryParam("sort", SORT_BY_DISTANCE)
                    .queryParam("page", page);                           // 새로 추가한 page 파라미터

            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                    uriBuilder.toUriString(),
                    HttpMethod.GET,
                    entity,
                    new ParameterizedTypeReference<>() {}
            );

            Object documents = response.getBody().get("documents");
            List<CategoryResponse> pageResults = new ObjectMapper().convertValue(
                    documents,
                    new TypeReference<List<CategoryResponse>>() {}
            );

            if (pageResults.isEmpty()) {
                break;
            }
            allResults.addAll(pageResults);
        }

        return allResults;
    }
}
