import 'package:flutter_test/flutter_test.dart';
import 'package:wheather_app/Models/weather.dart';

void main() {
  group('Weather Model Tests', () {
    test('fromJson should parse realistic Manila weather data correctly', () {
      // Realistic Manila weather response from OpenWeatherMap API
      final Map<String, dynamic> manilaJson = {
        "coord": {"lon": 120.9822, "lat": 14.6042},
        "weather": [
          {
            "id": 803,
            "main": "Clouds",
            "description": "broken clouds",
            "icon": "04d"
          }
        ],
        "base": "stations",
        "main": {
          "temp": 30.5,
          "feels_like": 35.2,
          "temp_min": 29.8,
          "temp_max": 31.2,
          "pressure": 1010,
          "humidity": 74
        },
        "visibility": 10000,
        "wind": {"speed": 4.12, "deg": 270},
        "clouds": {"all": 75},
        "dt": 1705046400,
        "sys": {
          "type": 2,
          "id": 2002597,
          "country": "PH",
          "sunrise": 1705017842,
          "sunset": 1705059684
        },
        "timezone": 28800,
        "id": 1701668,
        "name": "Manila",
        "cod": 200
      };

      final weather = Weather.fromJson(manilaJson);

      expect(weather.city, 'Manila');
      expect(weather.temperature, 30.5);
      expect(weather.description, 'Clouds');
      expect(weather.humidity, 74);
      expect(weather.windSpeed, 4.12);
    });

    test('fromJson should handle rainy Manila weather correctly', () {
      final Map<String, dynamic> rainyManilaJson = {
        "coord": {"lon": 120.9822, "lat": 14.6042},
        "weather": [
          {
            "id": 501,
            "main": "Rain",
            "description": "moderate rain",
            "icon": "10d"
          }
        ],
        "base": "stations",
        "main": {
          "temp": 27.3,
          "feels_like": 31.8,
          "temp_min": 26.5,
          "temp_max": 28.1,
          "pressure": 1008,
          "humidity": 88
        },
        "visibility": 8000,
        "wind": {"speed": 6.5, "deg": 240},
        "rain": {"1h": 5.2},
        "clouds": {"all": 90},
        "dt": 1705046400,
        "sys": {
          "type": 2,
          "id": 2002597,
          "country": "PH",
          "sunrise": 1705017842,
          "sunset": 1705059684
        },
        "timezone": 28800,
        "id": 1701668,
        "name": "Manila",
        "cod": 200
      };

      final weather = Weather.fromJson(rainyManilaJson);

      expect(weather.city, 'Manila');
      expect(weather.temperature, 27.3);
      expect(weather.description, 'Rain');
      expect(weather.humidity, 88);
      expect(weather.windSpeed, 6.5);
    });

    test('fromJson should handle clear Manila weather correctly', () {
      final Map<String, dynamic> clearManilaJson = {
        "coord": {"lon": 120.9822, "lat": 14.6042},
        "weather": [
          {
            "id": 800,
            "main": "Clear",
            "description": "clear sky",
            "icon": "01d"
          }
        ],
        "base": "stations",
        "main": {
          "temp": 32.8,
          "feels_like": 38.5,
          "temp_min": 31.9,
          "temp_max": 33.5,
          "pressure": 1012,
          "humidity": 65
        },
        "visibility": 10000,
        "wind": {"speed": 3.1, "deg": 180},
        "clouds": {"all": 0},
        "dt": 1705046400,
        "sys": {
          "type": 2,
          "id": 2002597,
          "country": "PH",
          "sunrise": 1705017842,
          "sunset": 1705059684
        },
        "timezone": 28800,
        "id": 1701668,
        "name": "Manila",
        "cod": 200
      };

      final weather = Weather.fromJson(clearManilaJson);

      expect(weather.city, 'Manila');
      expect(weather.temperature, 32.8);
      expect(weather.description, 'Clear');
      expect(weather.humidity, 65);
      expect(weather.windSpeed, 3.1);
    });

    test('fromJson should handle thunderstorm Manila weather', () {
      final Map<String, dynamic> thunderstormJson = {
        "coord": {"lon": 120.9822, "lat": 14.6042},
        "weather": [
          {
            "id": 211,
            "main": "Thunderstorm",
            "description": "thunderstorm",
            "icon": "11d"
          }
        ],
        "main": {
          "temp": 26.5,
          "feels_like": 30.2,
          "humidity": 92,
          "pressure": 1006
        },
        "wind": {"speed": 7.8, "deg": 250},
        "clouds": {"all": 85},
        "sys": {
          "country": "PH",
          "sunrise": 1705017842,
          "sunset": 1705059684
        },
        "timezone": 28800,
        "id": 1701668,
        "name": "Manila",
        "cod": 200
      };

      final weather = Weather.fromJson(thunderstormJson);

      expect(weather.city, 'Manila');
      expect(weather.description, 'Thunderstorm');
      expect(weather.temperature, 26.5);
      expect(weather.humidity, 92);
      expect(weather.windSpeed, 7.8);
    });

    test('fromJson should handle missing optional fields with defaults', () {
      final Map<String, dynamic> incompleteJson = {
        "weather": [
          {"main": "Clouds"}
        ],
        "main": {
          "temp": 28.0,
          "humidity": 70
        },
        "wind": {},
        "name": "Manila"
      };

      final weather = Weather.fromJson(incompleteJson);

      expect(weather.city, 'Manila');
      expect(weather.temperature, 28.0);
      expect(weather.description, 'Clouds');
      expect(weather.humidity, 70);
      expect(weather.windSpeed, 0.0);
    });

    test('fromJson should handle completely missing fields with defaults', () {
      final Map<String, dynamic> minimalJson = {
        "weather": [{}],
        "main": {},
        "wind": {}
      };

      final weather = Weather.fromJson(minimalJson);

      expect(weather.city, 'Unknown');
      expect(weather.temperature, 0.0);
      expect(weather.description, 'Unknown');
      expect(weather.humidity, 0);
      expect(weather.windSpeed, 0.0);
    });

    test('fromJson should handle integer temperature values', () {
      final Map<String, dynamic> jsonWithIntTemp = {
        "coord": {"lon": 120.9822, "lat": 14.6042},
        "weather": [
          {"id": 800, "main": "Clear", "description": "clear sky"}
        ],
        "main": {
          "temp": 30,
          "humidity": 70
        },
        "wind": {"speed": 5},
        "name": "Manila"
      };

      final weather = Weather.fromJson(jsonWithIntTemp);

      expect(weather.temperature, 30.0);
      expect(weather.windSpeed, 5.0);
    });

    test('fromJson should handle hot summer Manila weather', () {
      final Map<String, dynamic> hotManilaJson = {
        "coord": {"lon": 120.9822, "lat": 14.6042},
        "weather": [
          {
            "id": 800,
            "main": "Clear",
            "description": "clear sky",
            "icon": "01d"
          }
        ],
        "main": {
          "temp": 35.2,
          "feels_like": 42.8,
          "temp_min": 34.1,
          "temp_max": 36.0,
          "pressure": 1011,
          "humidity": 58
        },
        "visibility": 10000,
        "wind": {"speed": 2.5, "deg": 90},
        "clouds": {"all": 5},
        "dt": 1715846400,
        "sys": {
          "type": 2,
          "id": 2002597,
          "country": "PH",
          "sunrise": 1715817842,
          "sunset": 1715861284
        },
        "timezone": 28800,
        "id": 1701668,
        "name": "Manila",
        "cod": 200
      };

      final weather = Weather.fromJson(hotManilaJson);

      expect(weather.city, 'Manila');
      expect(weather.temperature, 35.2);
      expect(weather.description, 'Clear');
      expect(weather.humidity, 58);
      expect(weather.windSpeed, 2.5);
    });

    test('fromJson should handle hazy Manila weather', () {
      final Map<String, dynamic> hazyManilaJson = {
        "coord": {"lon": 120.9822, "lat": 14.6042},
        "weather": [
          {
            "id": 721,
            "main": "Haze",
            "description": "haze",
            "icon": "50d"
          }
        ],
        "main": {
          "temp": 29.8,
          "feels_like": 34.5,
          "humidity": 78
        },
        "wind": {"speed": 2.8, "deg": 180},
        "visibility": 5000,
        "name": "Manila"
      };

      final weather = Weather.fromJson(hazyManilaJson);

      expect(weather.city, 'Manila');
      expect(weather.temperature, 29.8);
      expect(weather.description, 'Haze');
      expect(weather.humidity, 78);
      expect(weather.windSpeed, 2.8);
    });
  });
}