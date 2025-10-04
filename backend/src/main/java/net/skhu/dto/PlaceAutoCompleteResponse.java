package net.skhu.dto;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PlaceAutoCompleteResponse {
    private String placeName;
    private String roadAddress;
    private double latitude;
    private double longitude;
}
