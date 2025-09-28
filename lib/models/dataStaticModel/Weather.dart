class Weather {
  final int weatherID;
  final String weatherDesc;

  Weather({required this.weatherID, required this.weatherDesc});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      weatherID: json['WeatherID'] ?? 0,

      // weatherID: json['WeatherID'] is int
      //     ? json['WeatherID']
      //     : int.tryParse(json['WeatherID'].toString()),
      weatherDesc: json['WeatherDesc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'WeatherID': weatherID, 'WeatherDesc': weatherDesc};
  }
}
