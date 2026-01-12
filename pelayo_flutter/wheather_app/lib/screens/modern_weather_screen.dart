import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';
import 'dart:math' as math;

class ModernWeatherScreen extends StatefulWidget {
  const ModernWeatherScreen({super.key});

  @override
  State<ModernWeatherScreen> createState() => _ModernWeatherScreenState();
}

class _ModernWeatherScreenState extends State<ModernWeatherScreen>
    with TickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  late Future<Weather> _weatherFuture;
  late AnimationController _floatController;
  late AnimationController _rotateController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _weatherFuture = WeatherService.getWeather('London');

    // Float animation
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Rotate animation for sun
    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _floatController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _searchWeather() {
    final String city = _cityController.text.trim();
    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a city name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (mounted) {
      setState(() {
        _weatherFuture = WeatherService.getWeather(city);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A148C),
              Color(0xFF6A1B9A),
              Color(0xFF8E24AA),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '1:41',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Row(
                      children: List.generate(
                        4,
                            (index) => Container(
                          margin: const EdgeInsets.only(left: 4),
                          width: 4,
                          height: 12,
                          decoration: BoxDecoration(
                            color: index < 3 ? Colors.white : Colors.white30,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: TextField(
                    controller: _cityController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search city...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white70),
                        onPressed: _searchWeather,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _searchWeather(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Main Content
              Expanded(
                child: FutureBuilder<Weather>(
                  future: _weatherFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                snapshot.error
                                    .toString()
                                    .replaceFirst('Exception: ', ''),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final weather = snapshot.data!;

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Animated Weather Icon
                          SizedBox(
                            height: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow effect
                                AnimatedBuilder(
                                  animation: _floatAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, _floatAnimation.value),
                                      child: Container(
                                        width: 180,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(60),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(0.4),
                                              blurRadius: 60,
                                              spreadRadius: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // Main cloud
                                AnimatedBuilder(
                                  animation: _floatAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, _floatAnimation.value),
                                      child: _buildWeatherIcon(weather.description),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Temperature
                          Text(
                            '${weather.temperature.toStringAsFixed(0)}°',
                            style: const TextStyle(
                              fontSize: 96,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Description
                          Text(
                            weather.description,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Color(0xFF64B5F6),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Min/Max
                          Text(
                            'Max: ${weather.temperature.toStringAsFixed(0)}° Min: ${(weather.temperature - 5).toStringAsFixed(0)}°',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // House Illustration
                          _buildHouseIllustration(),

                          const SizedBox(height: 30),

                          // Date
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Today',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  _getCurrentDate(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Weather Details Cards
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    'Humidity',
                                    '${weather.humidity}%',
                                    Icons.opacity,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoCard(
                                    'Wind',
                                    '${weather.windSpeed.toStringAsFixed(1)} m/s',
                                    Icons.air,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Bottom Navigation
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildNavIcon(Icons.location_on),
                                _buildNavIcon(Icons.add_circle_outline),
                                _buildNavIcon(Icons.menu),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherIcon(String description) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Cloud
        Container(
          width: 160,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),

        // Sun
        Positioned(
          top: -10,
          left: 10,
          child: AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateController.value * 2 * math.pi,
                child: const Icon(
                  Icons.wb_sunny,
                  size: 60,
                  color: Color(0xFFFDD835),
                ),
              );
            },
          ),
        ),

        // Rain drops
        if (description.toLowerCase().contains('rain') ||
            description.toLowerCase().contains('cloud'))
          Positioned(
            bottom: -10,
            child: Row(
              children: [
                _buildRainDrop(0),
                const SizedBox(width: 8),
                _buildRainDrop(200),
                const SizedBox(width: 8),
                _buildRainDrop(400),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRainDrop(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Opacity(
          opacity: 1 - value,
          child: Transform.translate(
            offset: Offset(0, value * 30),
            child: Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF64B5F6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
    );
  }

  Widget _buildHouseIllustration() {
    return SizedBox(
      width: 180,
      height: 140,
      child: Stack(
        children: [
          // House body
          Positioned(
            bottom: 0,
            left: 15,
            child: Container(
              width: 150,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),

          // Roof
          Positioned(
            top: 20,
            left: 0,
            child: CustomPaint(
              size: const Size(180, 50),
              painter: RoofPainter(),
            ),
          ),

          // Chimney
          Positioned(
            top: 10,
            left: 80,
            child: Container(
              width: 20,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Windows
          Positioned(
            top: 50,
            left: 30,
            child: _buildWindow(),
          ),
          Positioned(
            top: 50,
            right: 45,
            child: _buildWindow(),
          ),

          // Door
          Positioned(
            bottom: 0,
            left: 75,
            child: Container(
              width: 30,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: const Align(
                alignment: Alignment(0.5, 0),
                child: CircleAvatar(
                  radius: 2,
                  backgroundColor: Color(0xFFFDD835),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWindow() {
    return Container(
      width: 32,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFFDD835),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF0D47A1), width: 2)),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: Color(0xFF0D47A1), width: 2)),
                    ),
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
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
      ),
    );
  }

  Widget _buildNavIcon(IconData icon) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 28),
      onPressed: () {},
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]}, ${now.day}';
  }
}

class RoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1565C0)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.1, size.height)
      ..lineTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.9, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // Snow on roof
    final snowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.5, 0), 8, snowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}