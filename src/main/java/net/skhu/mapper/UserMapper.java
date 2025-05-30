package net.skhu.mapper;

import net.skhu.dto.UserDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserMapper {
    UserDto findByKakaoId(@Param("kakaoId") String kakaoId);
    void insert(UserDto user);
}
