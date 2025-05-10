package net.skhu.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class StationMidpointResponse {
    private String source;
    private String target;
    private String balancedMidpoint;
    private double timeFromSourceToMid;
    private double timeFromTargetToMid;
    private double timeDifference;
}
