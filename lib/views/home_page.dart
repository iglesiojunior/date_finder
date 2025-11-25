import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/date_spot_controller.dart';
import '../models/date_spot_model.dart';
import 'form_page.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  final DateSpotController _dateSpotController = DateSpotController();
  GoogleMapController? _mapController;

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-5.096122405359325, -42.80230723420346),
    zoom: 14.0,
  );

  @override
  void initState(){
    super.initState();
    _dateSpotController.loadDateSpots();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Spot Finder'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListenableBuilder(listenable: _dateSpotController, builder: (context, child){
        return GoogleMap(onMapCreated: (controller) => _mapController = controller,
        initialCameraPosition: _initialCameraPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _dateSpotController.dateSpots.map((place){
          return Marker(
            markerId: MarkerId(place.id ?? place.name),
            position: LatLng(place.latitude, place.longitude),
            infoWindow: InfoWindow(
              title: place.name,
              snippet: 'Visited on: ${place.date}\nRating: ${place.rating}★',
            ),
          );
        }).toSet(),
        );
      }
      ),
      floatingActionButton: FloatingActionButton.extended(
  onPressed: () async {
    LatLng target = const LatLng(-5.0920, -42.8038);
    
    if (_mapController != null) {
      final cameraRegion = await _mapController!.getVisibleRegion();
      final centerLat = (cameraRegion.northeast.latitude + cameraRegion.southwest.latitude) / 2;
      final centerLng = (cameraRegion.northeast.longitude + cameraRegion.southwest.longitude) / 2;
      target = LatLng(centerLat, centerLng);
    }
    
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormPage(point: target),
        ),
      );

      _dateSpotController.loadDateSpots();
    }
  },
  label: const Text('New Spot Here'),
  icon: const Icon(Icons.add_location_alt),
    ),
    );
  }
}