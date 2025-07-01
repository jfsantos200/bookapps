import 'package:flutter/material.dart';
import '../models/libro.dart';
import '../services/libros_service.dart';
import 'libros_leidos_screen.dart';
import 'agregar_libro_screen.dart';
import 'perfil_usuario.dart';

class ListaLibros extends StatefulWidget {
  const ListaLibros({super.key});

  @override
  State<ListaLibros> createState() => _ListaLibrosState();
}

class _ListaLibrosState extends State<ListaLibros> {
  List<Libro> _libros = [];

  @override
  void initState() {
    super.initState();
    _loadLibros();
  }

  Future<void> _loadLibros() async {
    final libros = await LibrosService.getLibros();
    setState(() => _libros = libros);
  }

  void _agregarLibro() async {
    final libro = await Navigator.push<Libro>(
      context,
      MaterialPageRoute(builder: (_) => const AgregarLibroScreen()),
    );
    if (libro != null) {
      await LibrosService.addLibro(libro);
      _loadLibros();
    }
  }

  void _marcarLeido(Libro libro) async {
    final actualizado = libro.copyWith(leido: true);
    await LibrosService.updateLibro(actualizado);
    _loadLibros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Libros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Ver leídos',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LibrosLeidosScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar libro',
            onPressed: _agregarLibro,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PerfilUsuario()),
            ),
          ),
        ],
      ),
      body: _libros.isEmpty
          ? const Center(child: Text('No tienes libros aún.'))
          : ListView.builder(
              itemCount: _libros.length,
              itemBuilder: (context, i) {
                final libro = _libros[i];
                return ListTile(
                  leading: libro.leido
                      ? const Icon(Icons.check, color: Colors.green)
                      : const Icon(Icons.book),
                  title: Text(libro.titulo),
                  subtitle: Text(libro.autor),
                  trailing: libro.leido
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.check_circle_outline),
                          tooltip: 'Marcar como leído',
                          onPressed: () => _marcarLeido(libro),
                        ),
                );
              },
            ),
    );
  }
}
