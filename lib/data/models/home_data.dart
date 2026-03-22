class HomeData {
  const HomeData({
    required this.message,
    required this.payload,
  });

  final String message;
  final Map<String, dynamic> payload;

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      message: json['message']?.toString() ?? json['detail']?.toString() ?? 'Respuesta recibida',
      payload: json,
    );
  }
}
