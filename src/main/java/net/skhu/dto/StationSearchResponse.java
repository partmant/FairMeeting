package net.skhu.dto;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class StationSearchResponse {
    private double latitude;
    private double longitude;
    private List<StationDto> nearbyStations;
}
