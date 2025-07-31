import 'dart:async';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
// Keep this import for clarity

class PDFViewScreen extends StatefulWidget {
  final String? url;   // Can be a URL from the internet or storage
  final String? path;  // Local path on Android/iOS

  const PDFViewScreen({super.key, this.url, this.path});

  @override
  State<PDFViewScreen> createState() => _PDFViewScreenState();
}

class _PDFViewScreenState extends State<PDFViewScreen> {
  PdfControllerPinch? _pdfController;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      if (widget.path != null && widget.path!.isNotEmpty) {
        // For local files, use openFile
        _pdfController = PdfControllerPinch(document: PdfDocument.openFile(widget.path!));
      } else if (widget.url != null && widget.url!.isNotEmpty) {
        // For URLs, use openData and pass the URL directly.
        // pdfx handles fetching the data from the URL internally.
        _pdfController = PdfControllerPinch(document: PdfDocument.openData(Uri.parse(widget.url!) as FutureOr<Uint8List>));
      } else {
        _errorMessage = 'No se proporcionó una URL ni una ruta local para el PDF.';
      }
    } catch (e) {
      // Catch any errors during document loading (e.g., invalid file, network issues)
      _errorMessage = 'Error al cargar el PDF: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ver PDF')),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(_errorMessage)),
      );
    } else if (_pdfController == null) {
      // This case should ideally not be reached if _errorMessage is handled
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No se pudo inicializar el controlador del PDF.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ver PDF')),
      body: PdfViewPinch(
        controller: _pdfController!,
      ),
    );
  }
}