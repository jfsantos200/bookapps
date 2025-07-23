import 'dart:typed_data';

import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'dart:io' show File;
// For loading from assets or bytes

class EpubViewScreen extends StatefulWidget {
  final String? url;   // URL del archivo EPUB
  final String? path;  // Ruta local del archivo EPUB (ej. del almacenamiento del dispositivo)

  const EpubViewScreen({super.key, this.url, this.path});

  @override
  State<EpubViewScreen> createState() => _EpubViewScreenState();
}

class _EpubViewScreenState extends State<EpubViewScreen> {
  EpubController? _controller;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadEpub();
  }

  Future<void> _loadEpub() async {
    try {
      if (widget.path != null && widget.path!.isNotEmpty) {
        // For local files, read the file bytes
        final file = File(widget.path!);
        if (await file.exists()) {
          final Uint8List bytes = await file.readAsBytes();
          _controller = EpubController(
            document: EpubDocument.openData(bytes),
          );
        } else {
          _errorMessage = 'El archivo EPUB local no existe en la ruta: ${widget.path}';
        }
      } else if (widget.url != null && widget.url!.isNotEmpty) {
        // For URLs, EpubDocument.openData handles fetching from the URL
        _controller = EpubController(
          document: EpubDocument.openData(Uri.parse(widget.url!) as Uint8List),
        );
      } else {
        _errorMessage = 'No se proporcionó una URL ni una ruta local para el EPUB.';
      }
    } catch (e) {
      // Catch any errors during document loading (e.g., invalid file, network issues)
      _errorMessage = 'Error al cargar el EPUB: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ver EPUB')),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(_errorMessage)),
      );
    } else if (_controller == null) {
      // This case should ideally not be reached if _errorMessage is handled
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No se pudo inicializar el controlador del EPUB.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ver EPUB')),
      body: EpubView(
        controller: _controller!,
      ),
    );
  }
}