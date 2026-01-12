import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  // Replace with your actual OpenWeatherMap API key
  static const String _apiKey = 'ca285bc6949ae99ac94a5322523ae2df';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  /// Fetches weather data for a given city
  /// Returns a Weather object or throws an exception
  static Future<Weather> getWeather(String city) async {
    if (city.isEmpty) {
      throw Exception('City name cannot be empty');
    }

    try {
      // Build the API URL with city name and API key
      final url = Uri.parse('$_baseUrl?q=$city&appid=$_apiKey&units=metric');

      // Make the HTTP GET request
      final response = await http.get(url);

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(response.body);
        return Weather.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('City not found. Please check the spelling.');
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your configuration.');
      } else {
        throw Exception('Failed to load weather data. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: Please check your internet connection');
    }
  }
}