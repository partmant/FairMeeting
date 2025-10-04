package net.skhu.dto;

import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class StationMidpointResponse {
    private List<String> sources;              			// 다수의 출발역 리스트
    @JsonProperty("midpoint")
    private String balancedMidpoint;           		 	// 최적 중간역 이름
    private Map<String, Double> timeFromSourceToMid; 	// 출발역별 중간역까지 소요시간 맵
    private double timeDifference;            			// 최대/최소 소요시간 차이    
    
    // 최고 소요시간을 계산해 반환
    public double getMaxTime() {
        return timeFromSourceToMid.values().stream()
                .max(Double::compare)
                .orElse(Double.POSITIVE_INFINITY);
    }
}