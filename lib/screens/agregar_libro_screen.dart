import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

import '../models/libro.dart';
import '../services/libros_service.dart';

class AgregarLibroScreen extends StatefulWidget {
  const AgregarLibroScreen({super.key, required libro});

  @override
  State<AgregarLibroScreen> createState() => _AgregarLibroScreenState();
}

class _AgregarLibroScreenState extends State<AgregarLibroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  final _imagenController = TextEditingController();

  final _busquedaController = TextEditingController();
  String _fuente = 'Google Books';
  bool _loading = false;
  List<dynamic> _resultados = [];

  // Para archivos
  String? _archivoLocalPath;
  String? _archivoStorageUrl;
  String? _archivoTipo;
  PlatformFile? _archivoSeleccionado;

  int _selectedTab = 0;

  // ----------- Búsqueda por API -------------
  Future<void> _buscarLibro(String texto) async {
    setState(() { _loading = true; _resultados = []; });
    if (_fuente == 'Google Books') {
      final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(texto)}');
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        final data = json.decode(respuesta.body);
        setState(() { _resultados = data['items'] ?? []; });
      }
    } else {
      final url = Uri.parse('https://openlibrary.org/search.json?q=${Uri.encodeComponent(texto)}');
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        final data = json.decode(respuesta.body);
        setState(() { _resultados = data['docs'] ?? []; });
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _agregarLibroAPI(dynamic libroData) async {
    Libro nuevoLibro;
    if (_fuente == 'Google Books') {
      final libro = libroData['volumeInfo'];
      nuevoLibro = Libro(
        uid: FirebaseAuth.instance.currentUser!.uid,
        id: '',
        titulo: libro['title'] ?? 'Sin título',
        autor: (libro['authors'] != null ? (libro['authors'] as List).join(', ') : 'Desconocido'),
        imagen: (libro['imageLinks'] != null) ? (libro['imageLinks']['thumbnail'] ?? '') : '',
        leido: false,
        archivoUrl: null,
        localPath: null,
      );
    } else {
      nuevoLibro = Libro(
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
    }
    await LibrosService.addLibro(nuevoLibro);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Libro agregado a tu colección!')),
    );
  }

  // ----------- Guardar Manual -------------
  void _guardarManual() {
    if (_formKey.currentState?.validate() ?? false) {
      final libro = Libro(
        id: '',
        uid: FirebaseAuth.instance.currentUser!.uid,
        titulo: _tituloController.text,
        autor: _autorController.text,
        imagen: _imagenController.text,
        leido: false,
        archivoUrl: null,
        localPath: null,
      );
      Navigator.of(context).pop(libro);
    }
  }

  // ----------- Selección y subida de archivo (Soporta web y móvil) -------------
  Future<void> _pickLocalFileAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'epub'],
      withData: kIsWeb, // Necesario para web
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      setState(() {
        _archivoLocalPath = file.path;
        _archivoTipo = file.extension;
        _archivoSeleccionado = file;
      });

      // SUBIR A STORAGE (distinto en web/móvil)
      try {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        final storageRef = FirebaseStorage.instance
            .ref('libros/${FirebaseAuth.instance.currentUser!.uid}/$fileName');

        UploadTask uploadTask;
        if (kIsWeb) {
          uploadTask = storageRef.putData(file.bytes!);
        } else {
          uploadTask = storageRef.putFile(File(file.path!));
        }
        final snapshot = await uploadTask;
        final url = await snapshot.ref.getDownloadURL();
        setState(() {
          _archivoStorageUrl = url;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Archivo subido y listo para usar!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir archivo: $e')),
        );
      }
    }
  }

  void _agregarLibroArchivo() {
    if (_archivoStorageUrl == null) return;
    final libro = Libro(
      id: '',
      uid: FirebaseAuth.instance.currentUser!.uid,
      titulo: _tituloController.text.isNotEmpty ? _tituloController.text : 'Sin título',
      autor: _autorController.text.isNotEmpty ? _autorController.text : 'Desconocido',
      imagen: _imagenController.text,
      leido: false,
      archivoUrl: _archivoStorageUrl,
      localPath: _archivoLocalPath,
    );
    Navigator.of(context).pop(libro);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: _selectedTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agregar Libro'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.edit), text: 'Manual'),
              Tab(icon: Icon(Icons.search), text: 'Buscar'),
              Tab(icon: Icon(Icons.file_present), text: 'Archivo'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 1) MANUAL
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        prefixIcon: Icon(Icons.book),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _autorController,
                      decoration: const InputDecoration(
                        labelText: 'Autor',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imagenController,
                      decoration: const InputDecoration(
                        labelText: 'URL de imagen',
                        prefixIcon: Icon(Icons.image),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar'),
                        onPressed: _guardarManual,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 2) API GOOGLE BOOKS / OPENLIBRARY
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
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
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _fuente,
                        items: const [
                          DropdownMenuItem(value: 'Google Books', child: Text('Google Books')),
                          DropdownMenuItem(value: 'Open Library', child: Text('Open Library')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _fuente = v);
                        },
                      ),
                    ],
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
                                    onPressed: () => _agregarLibroAPI(_resultados[i]),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
            // 3) ARCHIVO LOCAL / STORAGE
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.file_present),
                    label: const Text('Seleccionar y subir PDF/EPUB'),
                    onPressed: _pickLocalFileAndUpload,
                  ),
                  if (_archivoSeleccionado != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text('Archivo seleccionado: ${_archivoSeleccionado!.name} (${_archivoTipo})'),
                    ),
                  if (_archivoStorageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Enlace Storage: $_archivoStorageUrl', style: const TextStyle(fontSize: 12, color: Colors.green)),
                    ),
                  const SizedBox(height: 16),
                  if (_archivoStorageUrl != null)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Agregar libro con archivo'),
                      onPressed: _agregarLibroArchivo,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
