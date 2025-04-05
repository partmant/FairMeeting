package net.skhu.model;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StationSearchResult {
    private Coordinate coordinate;
    private List<Station> stations;
}
