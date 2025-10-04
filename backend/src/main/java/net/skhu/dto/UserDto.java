package net.skhu.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class UserDto {
    int id;

    @JsonProperty("kakao_id")
    String kakaoId;

    String nickname;

    @JsonProperty("profile_image_url")
    String profileImageUrl;
}
