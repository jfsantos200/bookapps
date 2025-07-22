import 'package:flutter/material.dart';
import '../models/libro.dart';
import '../services/libros_service.dart';
import '../theme.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Libros Leídos')),
      body: _librosLeidos.isEmpty
          ? Center(
              child: Text('No hay libros leídos.',
                  style: TextStyle(color: AdminLteColors.gray)),
            )
          : ListView.builder(
              itemCount: _librosLeidos.length,
              itemBuilder: (context, i) {
                final libro = _librosLeidos[i];
                return BookCard.fromLibro(
                  title: libro.titulo,
                  author: libro.autor,
                  imageUrl: libro.imagen ?? '',
                  isRead: true,
                  onMarkRead: null,
                  onTap: () {},
                );
              },
            ),
    );
  }
}

class BookCard {
  static fromLibro({required String title, required String author, required imageUrl, required bool isRead, required onMarkRead, required Null Function() onTap}) {}
}
