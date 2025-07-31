import 'package:flutter/material.dart';
import '../models/libro.dart';
import '../services/libros_service.dart';
import '../theme.dart';

class EditarLibroScreen extends StatefulWidget {
  final Libro libro;
  const EditarLibroScreen({super.key, required this.libro});

  @override
  State<EditarLibroScreen> createState() => _EditarLibroScreenState();
}

class _EditarLibroScreenState extends State<EditarLibroScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _autorController;
  late TextEditingController _imagenController;
  bool _leido = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.libro.titulo);
    _autorController = TextEditingController(text: widget.libro.autor);
    _imagenController = TextEditingController(text: widget.libro.imagen);
    _leido = widget.libro.leido;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final actualizado = widget.libro.copyWith(
        titulo: _tituloController.text.trim(),
        autor: _autorController.text.trim(),
        imagen: _imagenController.text.trim(),
        leido: _leido,
      );
      await LibrosService.updateLibro(actualizado);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar libro')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _autorController,
                decoration: const InputDecoration(labelText: 'Autor'),
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imagenController,
                decoration: const InputDecoration(labelText: 'URL de imagen de portada'),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('¿Marcar como leído?'),
                value: _leido,
                onChanged: (v) => setState(() => _leido = v),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: AdminLteColors.danger)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _guardar,
                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
