import 'package:flutter/material.dart';
import '../models/libro.dart';
import '../services/libros_service.dart';
import '../theme.dart';
import 'book_card.dart' as book_card_widget;

class LibrosLeidosScreen extends StatefulWidget {
  const LibrosLeidosScreen({super.key});

  @override
  State<LibrosLeidosScreen> createState() => _LibrosLeidosScreenState();
}

class _LibrosLeidosScreenState extends State<LibrosLeidosScreen> {
  List<Libro> _librosLeidos = [];

  @override
  void initState() {
    super.initState();
    _loadLibrosLeidos();
  }

  Future<void> _loadLibrosLeidos() async {
    final libros = await LibrosService.getLibros();
    setState(() => _librosLeidos = libros.where((l) => l.leido).toList());
  }

  void _marcarNoLeido(Libro libro) async {
    final actualizado = libro.copyWith(leido: false);
    await LibrosService.updateLibro(actualizado);
    setState(() {
      _librosLeidos.removeWhere((l) => l.id == libro.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Libros Leídos')),
      body: _librosLeidos.isEmpty
          ? const Center(
              child: Text('No hay libros leídos.',
                  style: TextStyle(color: AdminLteColors.gray)),
            )
          : ListView.builder(
              itemCount: _librosLeidos.length,
              itemBuilder: (context, i) {
                final libro = _librosLeidos[i];
                return book_card_widget.BookCard(
                  title: libro.titulo,
                  author: libro.autor,
                  imageUrl: libro.imagen ?? '',
                  isRead: true,
                  onMarkRead: () => _marcarNoLeido(libro), // desmarcar como leído
                  onTap: () {},
                  libro: libro,
                  onEdit: null,
                  onDelete: null,
                );
              },
            ),
    );
  }
}
