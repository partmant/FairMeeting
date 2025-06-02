package net.skhu.dto;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class FairLocationResponse {
    private PlaceDto midpointStation;
    private List<FairLocationRouteDetail> routes;
}