package net.skhu.dto;

import java.util.List;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StationMidpointRequest {

    @NotEmpty(message = "출발역을 적어주세요.")
    @Size(min = 2, message = "출발역은 2개 이상이어야 합니다.")
    private List<String> sources;

}
