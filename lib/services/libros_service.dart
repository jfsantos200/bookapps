
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/libro.dart';

class LibrosService {
  static const String key = 'libros_list';

  static Future<List<Libro>> getLibros() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((j) => Libro.fromJson(j)).toList();
  }

  static Future<void> saveLibros(List<Libro> libros) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(libros.map((l) => l.toJson()).toList());
    await prefs.setString(key, data);
  }

  static Future<void> addLibro(Libro libro) async {
    final libros = await getLibros();
    libros.add(libro);
    await saveLibros(libros);
  }

  static Future<void> updateLibro(Libro libro) async {
    final libros = await getLibros();
    final idx = libros.indexWhere((l) => l.id == libro.id);
    if (idx >= 0) {
      libros[idx] = libro;
      await saveLibros(libros);
    }
  }
}
