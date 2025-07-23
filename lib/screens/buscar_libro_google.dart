import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../models/libro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/libros_service.dart';

class BuscarLibroGoogleScreen extends StatefulWidget {
  const BuscarLibroGoogleScreen({super.key});

  @override
  State<BuscarLibroGoogleScreen> createState() => _BuscarLibroGoogleScreenState();
}

class _BuscarLibroGoogleScreenState extends State<BuscarLibroGoogleScreen> {
  final _busquedaController = TextEditingController();
  List<dynamic> _resultados = [];
  bool _loading = false;
  String _fuente = 'Google Books';

  Future<void> _buscarLibro(String texto) async {
    setState(() {
      _loading = true;
      _resultados = [];
    });

    if (_fuente == 'Google Books') {
      final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(texto)}');
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        final data = json.decode(respuesta.body);
        setState(() {
          _resultados = data['items'] ?? [];
        });
      }
    } else {
      // OpenLibrary
      final url = Uri.parse('https://openlibrary.org/search.json?q=${Uri.encodeComponent(texto)}');
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        final data = json.decode(respuesta.body);
        setState(() {
          _resultados = data['docs'] ?? [];
        });
      }
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _agregarLibro(dynamic libroData) async {
    if (_fuente == 'Google Books') {
      final libro = libroData['volumeInfo'];
      final nuevoLibro = Libro(
        uid: FirebaseAuth.instance.currentUser!.uid,
        id: '',
        titulo: libro['title'] ?? 'Sin título',
        autor: (libro['authors'] != null ? (libro['authors'] as List).join(', ') : 'Desconocido'),
        imagen: (libro['imageLinks'] != null)
            ? (libro['imageLinks']['thumbnail'] ?? libro['imageLinks']['smallThumbnail'] ?? '')
            : '',
        leido: false,
        archivoUrl: null, // Cambia esto si quieres guardar una muestra PDF si existe
        localPath: null,
      );
      await LibrosService.addLibro(nuevoLibro);
    } else {
      // OpenLibrary
      final nuevoLibro = Libro(
        uid: FirebaseAuth.instance.currentUser!.uid,
        id: '',
        titulo: libroData['title'] ?? 'Sin título',
        autor: (libroData['author_name'] != null ? (libroData['author_name'] as List).join(', ') : 'Desconocido'),
        imagen: libroData['cover_i'] != null
            ? 'https://covers.openlibrary.org/b/id/${libroData['cover_i']}-M.jpg'
            : '',
        leido: false,
        archivoUrl: null,
        localPath: null,
      );
      await LibrosService.addLibro(nuevoLibro);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Libro agregado a tu colección!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Libro en Internet'),
        actions: [
          DropdownButton<String>(
            value: _fuente,
            dropdownColor: Colors.white,
            underline: Container(),
            onChanged: (v) {
              if (v != null) setState(() => _fuente = v);
            },
            items: const [
              DropdownMenuItem(value: 'Google Books', child: Text('Google Books')),
              DropdownMenuItem(value: 'Open Library', child: Text('Open Library')),
            ],
          ),
          const SizedBox(width: 16)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                labelText: 'Título, autor o ISBN',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _buscarLibro(_busquedaController.text),
                ),
              ),
              onSubmitted: _buscarLibro,
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _resultados.length,
                      itemBuilder: (context, i) {
                        String titulo, autores, img;
                        if (_fuente == 'Google Books') {
                          final libro = _resultados[i]['volumeInfo'];
                          titulo = libro['title'] ?? 'Sin título';
                          autores = (libro['authors'] ?? ['Desconocido']).join(', ');
                          img = (libro['imageLinks'] != null)
                              ? libro['imageLinks']['thumbnail'] ?? ''
                              : '';
                        } else {
                          final libro = _resultados[i];
                          titulo = libro['title'] ?? 'Sin título';
                          autores = (libro['author_name'] ?? ['Desconocido']).join(', ');
                          img = libro['cover_i'] != null
                              ? 'https://covers.openlibrary.org/b/id/${libro['cover_i']}-M.jpg'
                              : '';
                        }

                        return Card(
                          child: ListTile(
                            leading: img.isNotEmpty
                                ? Image.network(img, width: 40, fit: BoxFit.cover)
                                : const Icon(Icons.book),
                            title: Text(titulo),
                            subtitle: Text(autores),
                            trailing: IconButton(
                              icon: const Icon(Icons.add),
                              tooltip: 'Agregar a mi colección',
                              onPressed: () => _agregarLibro(_resultados[i]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
