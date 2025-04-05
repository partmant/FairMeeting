package net.skhu.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import net.skhu.model.Station;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StationDto {
    private String name;
    private double lat;
    private double lng;

    // DTO -> Model 변환 (빌더 사용)
    public Station toEntity() {
        return Station.builder()
                .name(name)
                .lat(lat)
                .lng(lng)
                .build();
    }

    // Model -> DTO 변환 (빌더 사용)
    public static StationDto fromEntity(Station station) {
        return StationDto.builder()
                .name(station.getName())
                .lat(station.getLat())
                .lng(station.getLng())
                .build();
    }
}
