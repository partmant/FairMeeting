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

import lombok.RequiredArgsConstructor;


@Service
@RequiredArgsConstructor
public class AddressService {

	@Value("${kakao.rest.api.key}")
    private String restApiKey;

    public Map<String, String> getAddressName(double lat, double lng) {

    	System.out.println("[주소 변환 요청]: (" + lat + ", " + lng + ")");	// 확인용 출력문

        String url = String.format(
            "https://dapi.kakao.com/v2/local/geo/coord2address.json?x=%f&y=%f&input_coord=WGS84",
            lng, lat
        );

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "KakaoAK " + restApiKey);
        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();

        try {
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);
            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                List<Map<String, Object>> docs = (List<Map<String, Object>>) response.getBody().get("documents");
                if (docs != null && !docs.isEmpty()) {
                    Map<String, Object> doc = docs.get(0);
                    Map<String, Object> road = (Map<String, Object>) doc.get("road_address");
                    Map<String, Object> addr = (Map<String, Object>) doc.get("address");

                    String name = road != null && road.get("building_name") != null && !road.get("building_name").toString().isEmpty()
                        ? road.get("building_name").toString()
                        : road != null ? road.get("address_name").toString()
                        : addr != null ? addr.get("address_name").toString()
                        : "주소 정보 없음";

                    return Map.of("name", name);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return Map.of("name", "주소 정보 없음");
    }
}

