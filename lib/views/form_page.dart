import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/date_spot_controller.dart';
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

  double _rating = 3.0;
  DateTime _selectedDate = DateTime.now();

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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Place Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.place),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a place name';
                  }
                  return null;
                },
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
  void _save() {
    if (_formKey.currentState!.validate()) {
      // 1. Cria o objeto com os dados da tela + coordenadas recebidas
      final newPlace = DateSpot(
        name: _nameController.text,
        date: _selectedDate.toString(),
        rating: _rating,
        notes: _notesController.text,
        latitude: widget.point.latitude,   // AQUI ESTÁ A MÁGICA
        longitude: widget.point.longitude, // Pega a posição do mapa
      );

      // 2. Chama o Controller para salvar no banco
      DateSpotController().addDateSpot(newPlace);

      // 3. Volta para o mapa e mostra mensagem
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lugar salvo com sucesso!')),
      );
    }
  }
}
