class LogResponse {
  final String status;
  final String datetime;
  final String time;

  LogResponse({
    required this.status,
    required this.datetime,
    required this.time,
  });

  LogResponse copyWith({
    String? status,
    String? datetime,
    String? time,
  }) {
    return LogResponse(
      status: status ?? this.status,
      datetime: datetime ?? this.datetime,
      time: time ?? this.time,
    );
  }

  factory LogResponse.fromJson(Map<String, dynamic> json) => LogResponse(
        status: json["status"],
        datetime: json["datetime"],
        time: json["time"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "datetime": datetime,
        "time": time,
      };
}
