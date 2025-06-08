package net.skhu.controller;

import java.util.Arrays;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import net.skhu.dto.EditResultResponse;
import net.skhu.service.EditResultService;

@RestController
@RequestMapping("/api")
public class EditResultController {

	private final EditResultService editResultService;

	@Autowired
	public EditResultController(EditResultService editResultService) {
		this.editResultService = editResultService;
	}
	/**
	 * GET /api/edit/result
	 * 
	 * @param mx 중간지점 경도
	 * @param my 중간지점 위도
	 * @param sx 출발지 경도 리스트
	 * @param sy 출발지 위도 리스트
	 * @return EditResultResponse(PlaceDto midpoint, List<OdsayRouteResponse>
	 *         routes)
	 */
	@GetMapping("/edit/result")
	public ResponseEntity<EditResultResponse> getEditResult(
			@RequestParam("mx") double mx,
			@RequestParam("my") double my, 
			@RequestParam("sx") List<Double> sxList,
			@RequestParam("sy") List<Double> syList) {
		if (sxList.size() != syList.size()) {
			return ResponseEntity.badRequest().build();
		}

		try {
			EditResultResponse response = editResultService.getEditResult(mx, my, sxList, syList);
			return ResponseEntity.ok(response);
		} catch (Exception e) {
			e.printStackTrace();
			return ResponseEntity.internalServerError().build();
		}
	}
}
