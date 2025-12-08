import 'package:flutter/material.dart';
import '../controllers/date_spot_controller.dart';
import '../controllers/auth_controller.dart';

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  final DateSpotController _dateSpotController = DateSpotController();
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final userId = _authController.currentUser?.id;
    if (userId != null) {
      await _dateSpotController.loadDateSpots(userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Avaliações'),
      ),
      body: ListenableBuilder(
        listenable: _dateSpotController,
        builder: (context, child) {
          if (_dateSpotController.dateSpots.isEmpty) {
            return const Center(
              child: Text('Nenhuma avaliação encontrada'),
            );
          }

          return ListView.builder(
            itemCount: _dateSpotController.dateSpots.length,
            itemBuilder: (context, index) {
              final spot = _dateSpotController.dateSpots[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.place,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    spot.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < spot.rating.round()
                                ? Icons.star
                                : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          );
                        }),
                      ),
                      if (spot.notes.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          spot.notes,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'Data: ${_formatDate(spot.date)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmar exclusão'),
                          content: const Text(
                            'Deseja realmente excluir esta avaliação?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Excluir'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && mounted) {
                        await _dateSpotController.deleteDateSpot(
                          spot.id!,
                          userId: _authController.currentUser?.id,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Avaliação excluída com sucesso'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

