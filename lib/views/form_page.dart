import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/date_spot_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/date_spot_model.dart';

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
  late LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.point;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Local'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Campo de texto simples, sem autocomplete
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nome do Lugar",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.place),
                  hintText: "Digite o nome do local",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do lugar';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              // Mostra a coordenada que veio do clique no mapa
              Text(
                'Localização (GPS): ${_selectedLocation.latitude.toStringAsFixed(5)}, ${_selectedLocation.longitude.toStringAsFixed(5)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16.0),
              
              // Seleção de Data
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Data: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: _chooseDate,
              ),
              const Divider(),
              
              // Avaliação
              const Text("Sua Avaliação (0 a 5):"),
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
              
              // Notas
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Notas",
                  hintText: "Descreva sua experiência...",
                  border: OutlineInputBorder(),  
                ),
              ),
              const SizedBox(height: 24.0),

              // Botão Salvar
              FilledButton.icon(
                onPressed: _save,
                label: const Text("Salvar no Mapa"),
                icon: const Icon(Icons.save),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
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

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      await _authController.ensureInitialized();
      final userId = _authController.currentUser?.id;

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Faça login para salvar seus reviews.')),
          );
        }
        return;
      }

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