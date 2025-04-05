package net.skhu.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Coordinate {	// 사용자 위도, 경도
    private double lat;
    private double lng;
}
