class AppointmentDto {
  final int? id;
  final int userId;
  final DateTime date;
  final String time;
  final String location;

  AppointmentDto({
    this.id,
    required this.userId,
    required this.date,
    required this.time,
    required this.location,
  });

  factory AppointmentDto.fromJson(Map<String, dynamic> json) {
    return AppointmentDto(
      id: json['id'] as int?,
      userId: json['userId'] as int,
      date: DateTime.parse(json['date']),
      time: json['time'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'time': time,
      'location': location,
    };
  }
}
