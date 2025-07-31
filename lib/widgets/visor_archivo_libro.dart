
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:epub_view/epub_view.dart';
import 'package:http/http.dart' as http;

class VisorArchivoLibro extends StatefulWidget {
  final String? archivoUrl;   // URL remoto
  final String? localPath;    // Ruta local
  final String tipoArchivo;   // 'pdf' o 'epub'

  const VisorArchivoLibro({
    super.key,
    this.archivoUrl,
    this.localPath,
    required this.tipoArchivo,
  });

  @override
  State<VisorArchivoLibro> createState() => _VisorArchivoLibroState();
}

class _VisorArchivoLibroState extends State<VisorArchivoLibro> {
  PdfControllerPinch? _pdfController;
  EpubController? _epubController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDocumento();
  }

  Future<void> _cargarDocumento() async {
    try {
      if (widget.tipoArchivo == 'pdf') {
        // PDF desde URL
        if (widget.archivoUrl != null && widget.archivoUrl!.startsWith('http')) {
          _pdfController = PdfControllerPinch(
            document: PdfDocument.openData(await http.readBytes(Uri.parse(widget.archivoUrl!))),
          );
        }
        // PDF local
        else if (widget.localPath != null && widget.localPath!.isNotEmpty) {
          if (!kIsWeb && File(widget.localPath!).existsSync()) {
            _pdfController = PdfControllerPinch(
              document: PdfDocument.openFile(widget.localPath!),
            );
          } else {
            _error = 'PDF local no soportado en Web.';
          }
        } else {
          _error = 'Archivo PDF no encontrado.';
        }
      }

      else if (widget.tipoArchivo == 'epub') {
        // EPUB desde URL
        if (widget.archivoUrl != null && widget.archivoUrl!.startsWith('http')) {
          final response = await http.get(Uri.parse(widget.archivoUrl!));
          if (response.statusCode == 200) {
            _epubController = EpubController(
              document: EpubDocument.openData(response.bodyBytes),
            );
          } else {
            _error = 'No se pudo descargar el EPUB remoto.';
          }
        }
        // EPUB local
        else if (widget.localPath != null && widget.localPath!.isNotEmpty) {
          if (!kIsWeb && File(widget.localPath!).existsSync()) {
            _epubController = EpubController(
              document: EpubDocument.openFile(widget.localPath! as File),
            );
          } else {
            _error = 'EPUB local no soportado en Web.';
          }
        } else {
          _error = 'Archivo EPUB no encontrado.';
        }
      } else {
        _error = 'Tipo de archivo no soportado.';
      }

      setState(() {});
    } catch (e) {
      setState(() => _error = 'Error al cargar archivo: $e');
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _epubController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visor de archivo')),
        body: Center(child: Text(_error!, textAlign: TextAlign.center)),
      );
    }

    if (widget.tipoArchivo == 'pdf' && _pdfController != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visor PDF')),
        body: PdfViewPinch(controller: _pdfController!),
      );
    } else if (widget.tipoArchivo == 'epub' && _epubController != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visor EPUB')),
        body: EpubView(controller: _epubController!),
      );
    } else {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
  }
}
