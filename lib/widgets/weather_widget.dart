import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';
import 'package:intl/intl.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  WeatherData? _weatherData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final data = await WeatherService.fetchWeather();
    if (mounted) {
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF2D5A27)));
    }

    if (_weatherData == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2D5A27).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kotturu Weather',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D5A27),
                ),
              ),
              Text(
                _weatherData!.getWeatherIcon(),
                style: const TextStyle(fontSize: 32),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${_weatherData!.temperature.toStringAsFixed(1)}°C',
                style: GoogleFonts.outfit(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _weatherData!.getWeatherDescription(),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '3-Day Forecast',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D5A27),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              if (index >= _weatherData!.dailyTime.length) return const SizedBox.shrink();
              
              DateTime date = DateTime.parse(_weatherData!.dailyTime[index]);
              String dayName = index == 0 ? 'Today' : DateFormat('EEE').format(date);
              
              return Column(
                children: [
                  Text(
                    dayName,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${_weatherData!.dailyMinTemp[index].round()}° / ${_weatherData!.dailyMaxTemp[index].round()}°',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.water_drop, size: 12, color: Colors.blue),
                      Text(
                        '${_weatherData!.dailyPrecipitation[index]}mm',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
