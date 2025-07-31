// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import '../models/libro.dart';
import '../services/libros_service.dart';
import '../theme.dart';
import 'book_card.dart' as book_card_widget;
import 'package:bookapps/widgets/pdf_view_screen.dart';
import 'package:bookapps/widgets/epub_view_screen.dart';

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

  Future<void> _marcarNoLeido(Libro libro) async {
    final actualizado = libro.copyWith(leido: false);
    await LibrosService.updateLibro(actualizado);

    setState(() {
      _librosLeidos.removeWhere((l) => l.id == libro.id);
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Libro marcado como no leído')),
    );

    if (_librosLeidos.isEmpty) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _verLibro(Libro libro) async {
    // Abre visor PDF o EPUB según corresponda
    if ((libro.archivoUrl?.endsWith('.pdf') ?? false) || (libro.localPath?.endsWith('.pdf') ?? false)) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => PDFViewScreen(
          url: libro.archivoUrl,
          path: libro.localPath,
        ),
      ));
    } else if ((libro.archivoUrl?.endsWith('.epub') ?? false) || (libro.localPath?.endsWith('.epub') ?? false)) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => EpubViewScreen(
          url: libro.archivoUrl,
          path: libro.localPath,
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Archivo no disponible o formato no soportado')),
      );
    }
  }

  Future<void> _eliminarLibro(Libro libro) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: Text('¿Seguro que quieres eliminar "${libro.titulo}" de tu colección?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await LibrosService.deleteLibro(libro.id);
      setState(() => _librosLeidos.removeWhere((l) => l.id == libro.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Libro eliminado')),
      );
      if (_librosLeidos.isEmpty && mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Libros Leídos')),
      body: _librosLeidos.isEmpty
          ? const Center(
              child: Text(
                'No hay libros leídos.',
                style: TextStyle(color: AdminLteColors.gray),
              ),
            )
          : ListView.builder(
              itemCount: _librosLeidos.length,
              itemBuilder: (context, i) {
                final libro = _librosLeidos[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    // ignore: unnecessary_null_comparison
                    leading: (libro.imagen != null && libro.imagen.isNotEmpty)
                        ? Image.network(libro.imagen, width: 42, fit: BoxFit.cover)
                        : const Icon(Icons.book, size: 36),
                    title: Text(libro.titulo),
                    subtitle: Text(libro.autor),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ver libro
                        IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.green),
                          tooltip: 'Ver libro',
                          onPressed: () => _verLibro(libro),
                        ),
                        // Marcar como no leído
                        IconButton(
                          icon: const Icon(Icons.undo, color: Colors.blueAccent),
                          tooltip: 'Marcar como NO leído',
                          onPressed: () => _marcarNoLeido(libro),
                        ),
                        // Eliminar libro
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Eliminar libro',
                          onPressed: () => _eliminarLibro(libro),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
