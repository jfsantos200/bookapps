import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:epub_view/epub_view.dart';

class VisorArchivoLibro extends StatefulWidget {
  final String? archivoUrl;   // Remoto
  final String? localPath;    // Local
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

  @override
  void initState() {
    super.initState();
    if (widget.tipoArchivo == 'pdf') {
      if (widget.archivoUrl != null && (widget.archivoUrl!.startsWith('http') || widget.archivoUrl!.startsWith('https'))) {
        _pdfController = PdfControllerPinch(
          document: PdfDocument.fromURL(widget.archivoUrl!),
        );
      } else if (widget.localPath != null && widget.localPath!.isNotEmpty) {
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openFile(widget.localPath!),
        );
      }
    } else if (widget.tipoArchivo == 'epub') {
      if (widget.archivoUrl != null && widget.archivoUrl!.startsWith('http')) {
        _epubController = EpubController(
          document: EpubDocument.openRemote(widget.archivoUrl!),
        );
      } else if (widget.localPath != null && widget.localPath!.isNotEmpty) {
        if (!kIsWeb && File(widget.localPath!).existsSync()) {
          _epubController = EpubController(
            document: EpubDocument.openFile(widget.localPath!),
          );
        } else {
          // En web no hay acceso directo a archivos locales, mostrar error
        }
      }
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
    if (widget.tipoArchivo == 'pdf' && _pdfController != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visor PDF')),
        body: PdfViewPinch(
          controller: _pdfController!,
        ),
      );
    } else if (widget.tipoArchivo == 'epub' && _epubController != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visor EPUB')),
        body: EpubView(
          controller: _epubController!,
        ),
      );
    } else {
      return const Scaffold(
        body: Center(child: Text('Archivo no soportado o no encontrado.')),
      );
    }
  }
}
