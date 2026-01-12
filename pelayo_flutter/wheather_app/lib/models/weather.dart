class Weather {
  //properties (field) that hold our weather data
  final String city;
  final double temperature;
  final String description;
  final int humidity;
  final double windSpeed;

  //Constructor :Initialize all fields
  Weather({
    required this.city,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['name'] ?? 'Unknown',
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      description: json['weather'][0]['main'] ?? 'Unknown',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed']?? 0).toDouble(),
    );
  }

}