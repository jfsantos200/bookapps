import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/libro.dart';
import 'package:uuid/uuid.dart';

class BuscarLibroGoogle extends StatefulWidget {
  const BuscarLibroGoogle({super.key});

  @override
  State<BuscarLibroGoogle> createState() => _BuscarLibroGoogleState();
}

class _BuscarLibroGoogleState extends State<BuscarLibroGoogle> {
  final _controller = TextEditingController();
  List<Libro> _resultados = [];
  bool _cargando = false;

  Future<void> _buscar() async {
    setState(() => _cargando = true);
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() => _cargando = false);
      return;
    }
    final url = 'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(query)}';
    final resp = await http.get(Uri.parse(url));
    final data = jsonDecode(resp.body);

    setState(() {
      _resultados = [];
      if (data['items'] != null) {
        _resultados = (data['items'] as List)
            .map((item) => Libro(
                  id: item['id'] ?? const Uuid().v4(),
                  titulo: item['volumeInfo']['title'] ?? '',
                  autor: (item['volumeInfo']['authors'] != null && (item['volumeInfo']['authors'] as List).isNotEmpty)
                      ? (item['volumeInfo']['authors'] as List).join(', ')
                      : 'Desconocido',
                ))
            .toList();
      }
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buscar libro en Google Books")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: "Título, autor, ISBN..."),
                    onSubmitted: (_) => _buscar(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _buscar,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_cargando)
              const Center(child: CircularProgressIndicator())
            else if (_resultados.isEmpty)
              const Text("Sin resultados")
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _resultados.length,
                  itemBuilder: (_, i) {
                    final libro = _resultados[i];
                    return ListTile(
                      title: Text(libro.titulo),
                      subtitle: Text(libro.autor),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        tooltip: "Agregar a mi biblioteca",
                        onPressed: () => Navigator.pop(context, libro),
                      ),
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}
