package net.skhu.service;

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
    private static final int FIXED_RADIUS = 1000; // 고정 반경

    public List<CategoryResponse> searchByCategory(String categoryCode, double x, double y) {
        String url = "https://dapi.kakao.com/v2/local/search/category.json";

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "KakaoAK " + restApiKey);
        HttpEntity<Void> entity = new HttpEntity<>(headers);

        UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromUriString(url)
        	    .queryParam("category_group_code", categoryCode)
        	    .queryParam("x", x)
        	    .queryParam("y", y)
        	    .queryParam("radius", FIXED_RADIUS);

        ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                uriBuilder.toUriString(),
                HttpMethod.GET,
                entity,
                new ParameterizedTypeReference<>() {}
        );

        Object documents = response.getBody().get("documents");

        System.out.println(documents);

        return new ObjectMapper().convertValue(documents, new TypeReference<List<CategoryResponse>>() {});
    }
}
