import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/libro.dart';

class LibrosService {
  static Future<List<Libro>> getLibros() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final query = await FirebaseFirestore.instance
        .collection('libros')
        .where('uid', isEqualTo: uid)
        .get();
    return query.docs.map((doc) => Libro.fromFirestore(doc)).toList();
  }

  static Future<void> updateLibro(Libro libro) async {
    await FirebaseFirestore.instance
        .collection('libros')
        .doc(libro.id)
        .update(libro.toMap());
  }

  static Future<void> deleteLibro(String id) async {
    await FirebaseFirestore.instance.collection('libros').doc(id).delete();
  }

  static Future<void> addLibro(Libro libro) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final _ = await FirebaseFirestore.instance.collection('libros').add({
      ...libro.toMap(),
      'uid': uid,
    });
  }
}
