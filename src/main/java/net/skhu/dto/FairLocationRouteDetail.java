package net.skhu.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class FairLocationRouteDetail {
    private StationDto fromStation;
    private OdsayRouteResponse route;
}

