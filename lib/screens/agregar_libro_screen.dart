import 'package:flutter/material.dart';
import '../widgets/google_books_search.dart';
import '../models/libro.dart';
import 'package:uuid/uuid.dart';

class AgregarLibroScreen extends StatefulWidget {
  const AgregarLibroScreen({super.key});

  @override
  State<AgregarLibroScreen> createState() => _AgregarLibroScreenState();
}

class _AgregarLibroScreenState extends State<AgregarLibroScreen> {
  bool _modoGoogle = false;
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _autorCtrl = TextEditingController();

  void _agregarManual() {
    if (_formKey.currentState!.validate()) {
      final libro = Libro(
        id: const Uuid().v4(),
        titulo: _tituloCtrl.text,
        autor: _autorCtrl.text,
      );
      Navigator.pop(context, libro);
    }
  }

  void _agregarDesdeGoogle(Map<String, dynamic> datos) {
    final libro = Libro(
      id: datos['id'],
      titulo: datos['titulo'],
      autor: datos['autor'],
    );
    Navigator.pop(context, libro);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar libro")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Manual"),
                  selected: !_modoGoogle,
                  onSelected: (sel) => setState(() => _modoGoogle = !sel),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text("Google Books"),
                  selected: _modoGoogle,
                  onSelected: (sel) => setState(() => _modoGoogle = sel),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: !_modoGoogle
                  ? Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _tituloCtrl,
                            decoration: const InputDecoration(labelText: "Título"),
                            validator: (v) => v == null || v.isEmpty ? "Obligatorio" : null,
                          ),
                          TextFormField(
                            controller: _autorCtrl,
                            decoration: const InputDecoration(labelText: "Autor"),
                            validator: (v) => v == null || v.isEmpty ? "Obligatorio" : null,
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: _agregarManual,
                            child: const Text("Agregar"),
                          ),
                        ],
                      ),
                    )
                  : GoogleBooksSearch(
                      onSelected: _agregarDesdeGoogle,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
