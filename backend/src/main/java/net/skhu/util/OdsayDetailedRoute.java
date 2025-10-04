package net.skhu.util;

import java.util.List;

import lombok.Data;

@Data
public class OdsayDetailedRoute {
    private String startName;
    private String startCoord;
    private String endName;
    private String endCoord;
    private int totalTime;
    private int payment;
    private int subwayTransitCount;
    private int busTransitCount;
    private List<OdsaySubPath> subPaths;
}
