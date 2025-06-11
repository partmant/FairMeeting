class AppointmentCreateResponse {
  final int id;
  final String message;

  AppointmentCreateResponse({
    required this.id,
    required this.message,
  });

  factory AppointmentCreateResponse.fromJson(Map<String, dynamic> json) {
    return AppointmentCreateResponse(
      id: json['id'] as int,
      message: json['message'] as String,
    );
  }
}