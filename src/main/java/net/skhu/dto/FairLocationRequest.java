package net.skhu.dto;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class FairLocationRequest {
    private List<CoordinateDto> startPoints;
}
