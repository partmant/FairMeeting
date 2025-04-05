package net.skhu.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import net.skhu.model.Coordinate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CoordinateDto {
    private double lat;
    private double lng;

    // DTO -> Model 변환
    public Coordinate toEntity() {
        return new Coordinate(lat, lng);
    }

    // Model -> DTO 변환
    public static CoordinateDto fromEntity(Coordinate coordinate) {
        return new CoordinateDto(coordinate.getLat(), coordinate.getLng());
    }
}
