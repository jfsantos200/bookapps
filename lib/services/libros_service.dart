import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/libro.dart';

class LibrosService {
  /// Obtener todos los libros del usuario autenticado
  static Future<List<Libro>> getLibros() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final query = await FirebaseFirestore.instance
        .collection('libros')
        .where('uid', isEqualTo: uid)
        .get();

    return query.docs.map((doc) => Libro.fromFirestore(doc)).toList();
  }

  /// Actualizar un libro existente
  static Future<void> updateLibro(Libro libro) async {
    await FirebaseFirestore.instance
        .collection('libros')
        .doc(libro.id)
        .update(libro.toMap());
  }

  /// Eliminar un libro por ID
  static Future<void> deleteLibro(String id) async {
    await FirebaseFirestore.instance.collection('libros').doc(id).delete();
  }

  /// Agregar un libro nuevo y asignarle el ID del documento
  static Future<void> addLibro(Libro libro) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Crear referencia con ID autogenerado
    final docRef = FirebaseFirestore.instance.collection('libros').doc();

    // Guardar el libro con el ID incluido
    await docRef.set(libro.copyWith(
      id: docRef.id,
      uid: uid,
    ).toMap());
  }
}
