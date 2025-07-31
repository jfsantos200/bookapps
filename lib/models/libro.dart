import 'package:cloud_firestore/cloud_firestore.dart';

class Libro {
  final String tipoArchivo; // pdf o epub
  final String id;
  final String uid;
  final String titulo;
  final String autor;
  final String imagen;
  final bool leido;
  final String? archivoUrl; // URL en Storage
  final String? localPath;  // Ruta local en dispositivo

  Libro({
    required this.tipoArchivo,
    required this.id,
    required this.uid,
    required this.titulo,
    required this.autor,
    required this.imagen,
    required this.leido,
    this.archivoUrl,
    this.localPath,
  });

  factory Libro.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Libro(
      tipoArchivo: data['tipoArchivo'] ?? '',
      id: doc.id,
      uid: data['uid'] ?? '',
      titulo: data['titulo'] ?? '',
      autor: data['autor'] ?? '',
      imagen: data['imagen'] ?? '',
      leido: data['leido'] ?? false,
      archivoUrl: data['archivoUrl'],
      localPath: data['localPath'],
    );
  }

  Libro copyWith({
    String? tipoArchivo,
    String? id,
    String? uid,
    String? titulo,
    String? autor,
    String? imagen,
    bool? leido,
    String? archivoUrl,
    String? localPath,
  }) {
    return Libro(
      tipoArchivo: tipoArchivo ?? this.tipoArchivo,
      id: id ?? this.id,
      uid: uid ?? this.uid,
      titulo: titulo ?? this.titulo,
      autor: autor ?? this.autor,
      imagen: imagen ?? this.imagen,
      leido: leido ?? this.leido,
      archivoUrl: archivoUrl ?? this.archivoUrl,
      localPath: localPath ?? this.localPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipoArchivo': tipoArchivo,
      'uid': uid,
      'titulo': titulo,
      'autor': autor,
      'imagen': imagen,
      'leido': leido,
      'archivoUrl': archivoUrl,
      'localPath': localPath,
    };
  }
}
