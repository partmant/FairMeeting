package net.skhu.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class PlaceDto {
    private String name;
    private double latitude;
    private double longitude;
}
