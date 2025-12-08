import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/date_spot_controller.dart';
import '../controllers/auth_controller.dart';
import 'form_page.dart';
import 'my_reviews_page.dart';
import 'nearby_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  final DateSpotController _dateSpotController = DateSpotController();
  final AuthController _authController = AuthController();
  GoogleMapController? _mapController;
  Position? _currentPosition;

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-5.096122405359325, -42.80230723420346),
    zoom: 15.0,
  );

  @override
  void initState(){
    super.initState();
    _loadSpots();
    _checkLocationPermission();
    _getCurrentLocation();
  }

  Future<void> _loadSpots() async {
    final userId = _authController.currentUser?.id;
    await _dateSpotController.loadDateSpots(userId: userId);
  }
  
  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
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
          CameraUpdate.newLatLngZoom(
            LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            15.0,
          ),
        );
      }
    } catch (e) {
      // Silenciosamente falha se não conseguir obter localização
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Spot Finder'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              _authController.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _dateSpotController,
        builder: (context, child) {
          return GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              if (_currentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    15.0,
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
                    zoom: 15.0,
                  )
                : _initialCameraPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            markers: _dateSpotController.dateSpots.map((place) {
              return Marker(
                markerId: MarkerId(place.id.toString()),
                position: LatLng(place.latitude, place.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
                infoWindow: InfoWindow(
                  title: place.name,
                  snippet: 'Rating: ${place.rating.toStringAsFixed(1)}★',
                ),
                anchor: const Offset(0.5, 0.5),
              );
            }).toSet(),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyReviewsPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NearbyPage(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Minhas Avaliações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.near_me),
            label: 'Próximos a Mim',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          LatLng target = const LatLng(-5.0920, -42.8038);
          
          if (_mapController != null) {
            final cameraRegion = await _mapController!.getVisibleRegion();
            final centerLat = (cameraRegion.northeast.latitude + cameraRegion.southwest.latitude) / 2;
            final centerLng = (cameraRegion.northeast.longitude + cameraRegion.southwest.longitude) / 2;
            target = LatLng(centerLat, centerLng);
          } else if (_currentPosition != null) {
            target = LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            );
          }
          
          if (mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormPage(point: target),
              ),
            );

            await _loadSpots();
          }
        },
        label: const Text('New Spot Here'),
        icon: const Icon(Icons.add_location_alt),
      ),
    );
  }
}