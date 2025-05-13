package net.skhu.dto;

import java.util.List;

import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class FairLocationRequest {

	@Size(min = 2, message = "최소 2개의 출발 지점이 필요합니다.")
    private List<CoordinateDto> startPoints;
}
