package net.skhu.dto;

import java.util.List;
import java.util.stream.Collectors;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import net.skhu.model.StationSearchResult;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StationSearchResultDto {
    private CoordinateDto coordinate;
    private List<StationDto> stations;

    // Model -> DTO 변환
    public static StationSearchResultDto fromEntity(StationSearchResult result) {
        CoordinateDto coordinateDto = CoordinateDto.fromEntity(result.getCoordinate());
        List<StationDto> stationDtos = result.getStations().stream()
                .map(StationDto::fromEntity)
                .collect(Collectors.toList());
        return StationSearchResultDto.builder()
                .coordinate(coordinateDto)
                .stations(stationDtos)
                .build();
    }
}
