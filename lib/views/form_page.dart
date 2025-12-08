import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/date_spot_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/date_spot_model.dart';
import '../services/places_service.dart';

class FormPage extends StatefulWidget {
  final LatLng point;

  const FormPage({super.key, required this.point});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final DateSpotController _dateSpotController = DateSpotController();
  final AuthController _authController = AuthController();

  double _rating = 3.0;
  DateTime _selectedDate = DateTime.now();
  LatLng _selectedLocation = const LatLng(0, 0);
  List<PlacePrediction> _placePredictions = [];
  bool _isLoadingPlaces = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _placeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.point;
    _nameController.addListener(_onPlaceNameChanged);
    _placeFocusNode.addListener(() {
      if (!_placeFocusNode.hasFocus) {
        _hideOverlay();
      }
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_onPlaceNameChanged);
    _nameController.dispose();
    _notesController.dispose();
    _placeFocusNode.dispose();
    _hideOverlay();
    super.dispose();
  }

  void _onPlaceNameChanged() async {
    final query = _nameController.text;
    if (query.length > 2) {
      setState(() {
        _isLoadingPlaces = true;
      });

      final predictions = await PlacesService.getPlacePredictions(query);
      setState(() {
        _placePredictions = predictions;
        _isLoadingPlaces = false;
      });

      if (predictions.isNotEmpty && _placeFocusNode.hasFocus) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    } else {
      setState(() {
        _placePredictions = [];
      });
      _hideOverlay();
    }
  }

  void _showOverlay() {
    if (!mounted) return;
    _hideOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    var size = renderBox?.size ?? const Size(300, 50);

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: _isLoadingPlaces
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _placePredictions.isEmpty
                      ? const SizedBox.shrink()
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _placePredictions.length,
                          itemBuilder: (context, index) {
                            final prediction = _placePredictions[index];
                            return ListTile(
                              leading: const Icon(Icons.place),
                              title: Text(prediction.description),
                              onTap: () => _selectPlace(prediction),
                            );
                          },
                        ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectPlace(PlacePrediction prediction) async {
    _nameController.text = prediction.description;
    _hideOverlay();
    _placeFocusNode.unfocus();

    final details = await PlacesService.getPlaceDetails(prediction.placeId);
    if (details != null) {
      setState(() {
        _selectedLocation = LatLng(details.latitude, details.longitude);
        if (_nameController.text.isEmpty) {
          _nameController.text = details.name;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Date Spot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CompositedTransformTarget(
                link: _layerLink,
                child: TextFormField(
                  controller: _nameController,
                  focusNode: _placeFocusNode,
                  decoration: const InputDecoration(
                    labelText: "Nome do Lugar (use autocomplete do Google Places)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.place),
                    hintText: "Digite o nome ou endereço do lugar",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome do lugar';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Localização selecionada: ${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16.0),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: _chooseDate,

              ),
              const Divider(),
              
              const Text(
                "Your Rating(0 to 5):"
              ),
              Slider(
                value: _rating,
                min: 0,
                max: 5,
                divisions: 5,
                label: _rating.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _rating = value;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  );
                }),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Notes describe what you ate, how your experience was at the place",
                  border: OutlineInputBorder(),  
                ),
              ),
              const SizedBox(height: 24.0),

              FilledButton.icon(onPressed: _save, label: const Text("Save on Map"), icon: const Icon(Icons.save), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),),
              
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _chooseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Lógica de Salvar
  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final userId = _authController.currentUser?.id;
      final newPlace = DateSpot(
        name: _nameController.text,
        date: _selectedDate.toString(),
        rating: _rating,
        notes: _notesController.text,
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        userId: userId,
      );

      await _dateSpotController.addDateSpot(newPlace);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lugar salvo com sucesso!')),
        );
      }
    }
  }
}
