import 'package:cloud_firestore/cloud_firestore.dart';

class Libro {
  final String id;
  final String uid;
  final String titulo;
  final String autor;
  final String imagen;
  final bool leido;
  final String? archivoUrl; // Storage URL o null
  final String? localPath;  // Ruta local
  final String tipoArchivo;   // 'pdf' o 'epub'

  Libro(this.tipoArchivo, {
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
      id: doc.id,
      data['tipoArchivo'] ?? '', // Add this line
      uid: data['uid'] ?? '',
      titulo: data['titulo'] ?? '',
      autor: data['autor'] ?? '',
      imagen: data['imagen'],
      leido: data['leido'] ?? false,
    );
  }

  Libro copyWith({String? id, String? uid, String? titulo, String? autor, String? imagen, bool? leido}) {
    return Libro(
      tipoArchivo,
      id: id ?? this.id,
      uid: uid ?? this.uid,
      titulo: titulo ?? this.titulo,
      autor: autor ?? this.autor,
      imagen: imagen ?? this.imagen,
      leido: leido ?? this.leido,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'titulo': titulo,
      'autor': autor,
      'imagen': imagen,
      'leido': leido,
    };
  }
}
