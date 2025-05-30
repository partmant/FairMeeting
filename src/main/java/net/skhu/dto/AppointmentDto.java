package net.skhu.dto;

import lombok.Data;

@Data
public class AppointmentDto {
    int id;
    int userId;
    String date;      // yyyy-MM-dd
    String time;      // HH:mm
    String location;
}
