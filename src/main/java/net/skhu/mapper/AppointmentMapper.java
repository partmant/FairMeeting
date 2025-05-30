package net.skhu.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import net.skhu.dto.AppointmentDto;

@Mapper
public interface AppointmentMapper {
    List<AppointmentDto> findByUserId(int userId);
    AppointmentDto findByUserIdAndDate(@Param("userId") int userId,
                                       @Param("date")   String date);
    /** id 로 단일 약속 조회 */
    AppointmentDto findById(@Param("id") int id);

    void insert(AppointmentDto appointment);

    void update(AppointmentDto appointment);
    void delete(int id);
}
