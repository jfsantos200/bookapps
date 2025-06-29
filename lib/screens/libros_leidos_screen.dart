import 'package:flutter/material.dart';
import '../models/libro.dart';
import '../services/libros_service.dart';

class LibrosLeidosScreen extends StatelessWidget {
  const LibrosLeidosScreen({super.key});

  Future<List<Libro>> _getLibrosLeidos() async {
    final todos = await LibrosService.getLibros();
    return todos.where((l) => l.leido).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Libros Leídos')),
      body: FutureBuilder<List<Libro>>(
        future: _getLibrosLeidos(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          if (snap.data!.isEmpty) return const Center(child: Text('No has leído libros aún.'));
          return ListView(
            children: snap.data!
                .map((libro) => ListTile(
                      leading: const Icon(Icons.check, color: Colors.green),
                      title: Text(libro.titulo),
                      subtitle: Text(libro.autor),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
