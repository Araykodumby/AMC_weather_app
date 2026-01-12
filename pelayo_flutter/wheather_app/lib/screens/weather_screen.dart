import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // Controller: Manages text input from the search field
  final TextEditingController _cityController = TextEditingController();

  // Future: Holds the asynchronous weather data fetch
  late Future<Weather> _weatherFuture;

  @override
  void initState() {
    super.initState();
    // Load weather for a default city when the app starts
    _weatherFuture = WeatherService.getWeather('Caloocan') as Future<Weather>;
  }

  // Function: Handle search button press
  void _searchWeather() {
    final String city = _cityController.text.trim();

    // Validate input: Don't allow empty searches
    if (city.isEmpty) {
      _showSnackBar('Please enter a city name', Colors.orange);
      return;
    }

    // Update the Future to fetch new weather data, only if the widget is still mounted
    if (mounted) {
      setState(() {
        _weatherFuture = WeatherService.getWeather(city) as Future<Weather>;
      });
    }
  }

  // Helper: Display notification messages
  void _showSnackBar(String message, Color backgroundColor) {
    // Before showing a SnackBar, check if the widget is still in the tree
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up: Always dispose controllers to prevent memory leaks
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar at the top
      appBar: AppBar(
        title: const Text('🌤️ Weather App'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade400,
        foregroundColor: Colors.white, // Ensures title text is white
      ),

      // Main content area
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ===== SEARCH INPUT SECTION =====
            Row(
              children: [
                // Text input field
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      hintText: 'Enter city name...',
                      prefixIcon: const Icon(Icons.location_city),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    // Allow pressing Enter to search
                    onSubmitted: (_) => _searchWeather(),
                  ),
                ),
                const SizedBox(width: 8),

                // Search button
                ElevatedButton.icon(
                  onPressed: _searchWeather,
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    backgroundColor: Colors.blue.shade400,
                    foregroundColor: Colors.white, // Ensures icon and label are white
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ===== WEATHER DISPLAY SECTION =====
            FutureBuilder<Weather>(
              future: _weatherFuture,
              builder: (context, snapshot) {
                // STATE 1: Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // STATE 2: Error
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          snapshot.error.toString().replaceFirst('Exception: ', ''),
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // STATE 3: Success
                if (snapshot.hasData) {
                  final weather = snapshot.data!;
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade300, Colors.blue.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // City name
                        Text(
                          weather.city,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Temperature (main focus)
                        Text(
                          '${weather.temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Weather description
                        Text(
                          weather.description,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Additional info (Humidity & Wind)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            WeatherInfoCard(
                              icon: Icons.opacity,
                              label: 'Humidity',
                              value: '${weather.humidity}%',
                            ),
                            WeatherInfoCard(
                              icon: Icons.air,
                              label: 'Wind Speed',
                              value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                // STATE 4: No data
                return const Center(
                  child: Text('No data available'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ===== REUSABLE WIDGET =====
class WeatherInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
