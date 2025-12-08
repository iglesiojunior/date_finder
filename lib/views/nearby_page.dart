import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/date_spot_controller.dart';
import '../models/date_spot_model.dart';

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  final DateSpotController _dateSpotController = DateSpotController();
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-5.096122405359325, -42.80230723420346),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _dateSpotController.loadDateSpots();
  }

  Future<void> _initializeLocation() async {
    await _checkLocationPermission();
    await _getCurrentLocation();
    _loadNearbySpots();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão de localização negada'),
          ),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      if (_mapController != null && _currentPosition != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao obter localização: $e')),
        );
      }
    }
  }

  void _loadNearbySpots() {
    setState(() {
      _isLoading = false;
    });

    _dateSpotController.addListener(_updateMarkers);
    _updateMarkers();
  }

  void _updateMarkers() {
    final markers = <Marker>{};

    // Adicionar marcador da localização atual
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
          infoWindow: const InfoWindow(title: 'Minha Localização'),
        ),
      );
    }

    // Adicionar marcadores dos lugares próximos
    for (final spot in _dateSpotController.dateSpots) {
      if (_currentPosition != null) {
        final distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          spot.latitude,
          spot.longitude,
        );

        // Mostrar apenas lugares a menos de 10km
        if (distance <= 10000) {
          markers.add(
            Marker(
              markerId: MarkerId(spot.id.toString()),
              position: LatLng(spot.latitude, spot.longitude),
              infoWindow: InfoWindow(
                title: spot.name,
                snippet: 'Rating: ${spot.rating}★\nDistância: ${(distance / 1000).toStringAsFixed(1)} km',
              ),
              onTap: () {
                _showRouteOptions(spot);
              },
            ),
          );
        }
      } else {
        // Se não tiver localização, mostrar todos
        markers.add(
          Marker(
            markerId: MarkerId(spot.id.toString()),
            position: LatLng(spot.latitude, spot.longitude),
            infoWindow: InfoWindow(
              title: spot.name,
              snippet: 'Rating: ${spot.rating}★',
            ),
            onTap: () {
              if (_currentPosition != null) {
                _showRouteOptions(spot);
              }
            },
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  void _showRouteOptions(DateSpot spot) {
    if (_currentPosition == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              spot.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Rating: ${spot.rating}★'),
            if (spot.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(spot.notes),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.icon(
                  onPressed: () => _openRouteInMaps(spot),
                  icon: const Icon(Icons.directions),
                  label: const Text('Traçar Rota'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Fechar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openRouteInMaps(DateSpot spot) async {
    if (_currentPosition == null) return;

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${spot.latitude},${spot.longitude}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o mapa')),
        );
      }
    }
  }

  @override
  void dispose() {
    _dateSpotController.removeListener(_updateMarkers);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Próximos a Mim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: 'Atualizar localização',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListenableBuilder(
              listenable: _dateSpotController,
              builder: (context, child) {
                return GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (_currentPosition != null) {
                      controller.animateCamera(
                        CameraUpdate.newLatLng(
                          LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                        ),
                      );
                    }
                  },
                  initialCameraPosition: _currentPosition != null
                      ? CameraPosition(
                          target: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          zoom: 14.0,
                        )
                      : _initialCameraPosition,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _markers,
                  onTap: (LatLng position) {
                    // Atualizar marcadores quando o mapa for atualizado
                    _updateMarkers();
                  },
                );
              },
            ),
    );
  }
}

