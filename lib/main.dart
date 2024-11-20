import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WeatherScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;

  // API key for OpenWeather
  static const String _apiKey = '5646e22f2cd7bde1f805de5b3292bd96';

  // Function to fetch weather data from the API
  Future<void> fetchWeather(String city) async {
    if (city.isEmpty) {
      _showSnackBar('Please enter a city name.');
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey&units=metric',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = jsonDecode(response.body);
        });
      } else if (response.statusCode == 404) {
        _showSnackBar('City not found. Please check the name and try again.');
      } else {
        _showSnackBar('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showSnackBar('Failed to fetch weather data. Please try again later.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Function to display a SnackBar with a custom message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Enter City',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              onSubmitted: fetchWeather,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => fetchWeather(_cityController.text),
              icon: Icon(Icons.search),
              label: Text('Fetch Weather'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _weatherData != null
                ? WeatherInfo(weatherData: _weatherData!)
                : Text(
              'Enter a city name and press "Fetch Weather" to see results.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget to display weather information
class WeatherInfo extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const WeatherInfo({Key? key, required this.weatherData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'City: ${weatherData['name']}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          'Temperature: ${weatherData['main']['temp']}°C',
          style: TextStyle(fontSize: 18),
        ),
        Text(
          'Weather: ${weatherData['weather'][0]['description']}',
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
