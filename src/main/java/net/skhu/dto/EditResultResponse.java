package net.skhu.dto;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * 중간지점 정보(이름, 좌표)와
 * 해당 중간지점까지의 경로 리스트를 함께 담는 DTO
 */

@Data
@AllArgsConstructor
public class EditResultResponse {
	private PlaceDto midpoint;                  // 중간지점 이름 및 좌표
    private List<OdsayRouteResponse> routes;    // 출발지들로부터 중간지점까지의 경로 리스트

}

