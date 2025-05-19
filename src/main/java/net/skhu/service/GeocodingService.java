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

import net.skhu.dto.GeocodingResponse;

@Service
public class GeocodingService {

    @Value("${kakao.rest.api.key}")
    private String restApiKey;

    /**
     * 좌표를 기반으로 주소 또는 건물이름을 반환하는 메서드
     * @param lat 위도
     * @param lng 경도
     * @return GeocodingResponse (건물이름 또는 주소명 포함)
     */
    public GeocodingResponse getAddressName(double lat, double lng) {

        System.out.println("[주소 변환 요청]: (" + lat + ", " + lng + ")");  // 로그 출력

        // Kakao 좌표-주소 변환 API URL 구성 (WGS84 좌표계 사용)
        String url = String.format(
            "https://dapi.kakao.com/v2/local/geo/coord2address.json?x=%f&y=%f&input_coord=WGS84",
            lng, lat
        );

        // Authorization 헤더 설정 ("KakaoAK {API_KEY}")
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "KakaoAK " + restApiKey);

        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();

        try {
            // GET 요청 수행 및 응답 수신 (Map 형태로 파싱)
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);

            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                // 응답 JSON에서 documents 배열 추출
                List<Map<String, Object>> docs = (List<Map<String, Object>>) response.getBody().get("documents");

                if (docs != null && !docs.isEmpty()) {
                    Map<String, Object> doc = docs.get(0);  // 응답 배열 중 도로명 주소가 포함된 첫 번째 요소를 사용
                    Map<String, Object> road = (Map<String, Object>) doc.get("road_address");
                    Map<String, Object> addr = (Map<String, Object>) doc.get("address");

                    // 건물이름 → 도로명주소 → 지번주소 순으로 우선순위 지정
                    String name = road != null && road.get("building_name") != null && !road.get("building_name").toString().isEmpty()
                        ? road.get("building_name").toString()
                        : road != null ? road.get("address_name").toString()
                        : addr != null ? addr.get("address_name").toString()
                        : "주소 정보 없음";
                    System.out.println(name);
                    return new GeocodingResponse(name);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return new GeocodingResponse("주소 정보 없음");
    }
}
