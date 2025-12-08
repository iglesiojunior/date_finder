import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class PlacesService {
  static const String baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const MethodChannel _channel = MethodChannel('com.example.date_finder/api_key');
  static String? _cachedApiKey;

  static Future<String?> _getApiKey() async {
    if (_cachedApiKey != null) {
      return _cachedApiKey;
    }

    // Primeiro tenta ler do Android nativo via MethodChannel
    try {
      if (Platform.isAndroid) {
        final key = await _channel.invokeMethod<String>('getGoogleMapsApiKey');
        if (key != null && key.isNotEmpty) {
          _cachedApiKey = key;
          return _cachedApiKey;
        }
      }
    } catch (e) {
      // Se falhar, continua tentando ler do arquivo
    }

    // Se não conseguir do Android, tenta ler do arquivo local.properties (desenvolvimento)
    try {
      final possiblePaths = [
        path.join(Directory.current.path, 'android', 'local.properties'),
        path.join(Directory.current.path, '..', 'android', 'local.properties'),
        path.normalize(path.join(Directory.current.path, 'android', 'local.properties')),
      ];

      for (final filePath in possiblePaths) {
        final localPropertiesFile = File(filePath);
        
        if (await localPropertiesFile.exists()) {
          final content = await localPropertiesFile.readAsString();
          final lines = content.split('\n');
          
          for (final line in lines) {
            final trimmedLine = line.trim();
            if (trimmedLine.startsWith('GOOGLE_MAPS_API_KEY=')) {
              final keyValue = trimmedLine.substring('GOOGLE_MAPS_API_KEY='.length).trim();
              _cachedApiKey = keyValue;
              return _cachedApiKey;
            }
          }
        }
      }
    } catch (e) {
      // Se não conseguir ler, retorna null
      return null;
    }

    return null;
  }

  static Future<String> get apiKey async {
    return await _getApiKey() ?? '';
  }

  static Future<List<PlacePrediction>> getPlacePredictions(String input) async {
    if (input.isEmpty) {
      return [];
    }

    final key = await apiKey;
    if (key.isEmpty) {
      return [];
    }

    try {
      final url = Uri.parse(
        '$baseUrl/autocomplete/json?input=$input&key=$key&language=pt-BR',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['predictions'] != null) {
          return (data['predictions'] as List)
              .map((prediction) => PlacePrediction.fromJson(prediction))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    final key = await apiKey;
    if (key.isEmpty) {
      return null;
    }

    try {
      final url = Uri.parse(
        '$baseUrl/details/json?place_id=$placeId&key=$key&language=pt-BR',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['result'] != null) {
          return PlaceDetails.fromJson(data['result']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class PlacePrediction {
  final String description;
  final String placeId;

  PlacePrediction({
    required this.description,
    required this.placeId,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      description: json['description'] ?? '',
      placeId: json['place_id'] ?? '',
    );
  }
}

class PlaceDetails {
  final String name;
  final double latitude;
  final double longitude;
  final String? formattedAddress;

  PlaceDetails({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.formattedAddress,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] ?? {};
    final location = geometry['location'] ?? {};
    
    return PlaceDetails(
      name: json['name'] ?? '',
      latitude: (location['lat'] ?? 0.0).toDouble(),
      longitude: (location['lng'] ?? 0.0).toDouble(),
      formattedAddress: json['formatted_address'],
    );
  }
}

