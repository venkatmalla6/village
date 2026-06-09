import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  // Kotturu coordinates
  static const double lat = 17.181651;
  static const double lng = 82.114733;

  static Future<WeatherData?> fetchWeather() async {
    try {
      final url = 'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current_weather=true&daily=temperature_2m_max,temperature_2m_min,precipitation_sum&timezone=auto';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return WeatherData.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error fetching weather: $e');
    }
    return null;
  }
}
