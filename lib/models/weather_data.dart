class WeatherData {
  final double temperature;
  final int weatherCode;
  final List<double> dailyMaxTemp;
  final List<double> dailyMinTemp;
  final List<double> dailyPrecipitation;
  final List<String> dailyTime;

  WeatherData({
    required this.temperature,
    required this.weatherCode,
    required this.dailyMaxTemp,
    required this.dailyMinTemp,
    required this.dailyPrecipitation,
    required this.dailyTime,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['current_weather']['temperature']?.toDouble() ?? 0.0,
      weatherCode: json['current_weather']['weathercode'] ?? 0,
      dailyMaxTemp: List<double>.from(json['daily']['temperature_2m_max']?.map((x) => x.toDouble()) ?? []),
      dailyMinTemp: List<double>.from(json['daily']['temperature_2m_min']?.map((x) => x.toDouble()) ?? []),
      dailyPrecipitation: List<double>.from(json['daily']['precipitation_sum']?.map((x) => x.toDouble()) ?? []),
      dailyTime: List<String>.from(json['daily']['time'] ?? []),
    );
  }

  String getWeatherDescription() {
    // WMO Weather interpretation codes
    switch (weatherCode) {
      case 0: return 'Clear sky';
      case 1: case 2: case 3: return 'Partly cloudy';
      case 45: case 48: return 'Fog';
      case 51: case 53: case 55: return 'Drizzle';
      case 61: case 63: case 65: return 'Rain';
      case 71: case 73: case 75: return 'Snow';
      case 95: case 96: case 99: return 'Thunderstorm';
      default: return 'Unknown';
    }
  }

  String getWeatherIcon() {
    switch (weatherCode) {
      case 0: return '☀️';
      case 1: case 2: case 3: return '⛅';
      case 45: case 48: return '🌫️';
      case 51: case 53: case 55: return '🌧️';
      case 61: case 63: case 65: return '🌧️';
      case 71: case 73: case 75: return '❄️';
      case 95: case 96: case 99: return '⛈️';
      default: return '☁️';
    }
  }
}
