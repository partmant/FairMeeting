package net.skhu.util;

import java.util.List;

import lombok.Data;

@Data
public class OdsaySubPath {
    private int trafficType;
    private String startName;
    private String endName;
    private String startCoord;
    private String endCoord;
    private int sectionTime;
    private int distance; // 도보 시 거리
    private int stationCount; // 지하철일 때 정거장 수
    private String lineName; // 지하철 노선 이름
    private List<String> laneNames; // 버스 번호 리스트
}
