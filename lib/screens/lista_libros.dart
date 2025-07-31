import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/libro.dart';
import '../services/libros_service.dart';
import 'agregar_libro_screen.dart';
import 'libros_leidos_screen.dart';
import 'perfil_usuario.dart';
import 'login_screen.dart';
import '../theme.dart';
import 'book_card.dart' as book_card_widget;
import 'package:bookapps/widgets/pdf_view_screen.dart';
import 'package:bookapps/widgets/epub_view_screen.dart';

class ListaLibros extends StatefulWidget {
  const ListaLibros({super.key});

  @override
  State<ListaLibros> createState() => _ListaLibrosState();
}

class _ListaLibrosState extends State<ListaLibros> {
  List<Libro> _libros = [];
  String nombreCompleto = '';

  @override
  void initState() {
    super.initState();
    _loadLibros();
    _cargarNombreUsuario();
  }

  Future<void> _cargarNombreUsuario() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    if (doc.exists) {
      setState(() {
        nombreCompleto = '${doc['nombre'] ?? ''} ${doc['apellido'] ?? ''}'.trim();
      });
    }
  }

  Future<void> _loadLibros() async {
    final libros = await LibrosService.getLibros();
    setState(() => _libros = libros.where((l) => !l.leido).toList());
  }

  void _agregarLibro() async {
    final libro = await Navigator.push<Libro>(
      context,
      MaterialPageRoute(builder: (_) => const AgregarLibroScreen(libro: null)),
    );
    if (libro != null) {
      await LibrosService.addLibro(libro);
      _loadLibros();
    }
  }

  void _abrirLibrosLeidos() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LibrosLeidosScreen()),
    );
    _loadLibros();
  }

  void _abrirPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PerfilUsuario()),
    );
  }

  void _cerrarSesion() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  /// Abrir visor PDF o EPUB
  void _abrirLibro(Libro libro) {
    if (libro.archivoUrl != null && libro.archivoUrl!.endsWith('.pdf')) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => PDFViewScreen(url: libro.archivoUrl),
      ));
    } else if (libro.localPath != null && libro.localPath!.endsWith('.pdf')) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => PDFViewScreen(path: libro.localPath),
      ));
    } else if (libro.archivoUrl != null && libro.archivoUrl!.endsWith('.epub')) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => EpubViewScreen(url: libro.archivoUrl),
      ));
    } else if (libro.localPath != null && libro.localPath!.endsWith('.epub')) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => EpubViewScreen(path: libro.localPath),
      ));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formato no soportado o falta archivo.')),
      );
    }
  }

  Future<void> _confirmarEliminar(Libro libro) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este libro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await LibrosService.deleteLibro(libro.id);
      _loadLibros();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Libro eliminado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          nombreCompleto.isNotEmpty ? 'Hola, $nombreCompleto' : 'Mis Libros',
        ),
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: _abrirPerfil,
          ),
        ],
      ),
      drawer: canPop
          ? null
          : Drawer(
              child: Container(
                color: AdminLteColors.sidebar,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: const BoxDecoration(color: AdminLteColors.dark),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.account_circle, color: Colors.white, size: 42),
                          const SizedBox(height: 12),
                          Text(
                            nombreCompleto.isNotEmpty ? nombreCompleto : 'Usuario',
                            style: Theme.of(context)
                                .appBarTheme
                                .titleTextStyle
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.add, color: Colors.white),
                      title: const Text('Agregar libro', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.of(context).pop();
                        _agregarLibro();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.check_circle_outline, color: Colors.white),
                      title: const Text('Libros leídos', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.of(context).pop();
                        _abrirLibrosLeidos();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.white),
                      title: const Text('Perfil', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.of(context).pop();
                        _abrirPerfil();
                      },
                    ),
                    const Divider(color: Colors.white70),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: const Text('Cerrar sesión', style: TextStyle(color: Colors.redAccent)),
                      onTap: () {
                        Navigator.of(context).pop();
                        _cerrarSesion();
                      },
                    ),
                  ],
                ),
              ),
            ),
      body: _libros.isEmpty
          ? const Center(child: Text('No tienes libros aún.'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _libros.length,
              itemBuilder: (context, i) {
                final libro = _libros[i];
                return book_card_widget.BookCard(
                  libro: libro,
                  onMarkRead: libro.leido
                      ? null
                      : () async {
                          final actualizado = libro.copyWith(leido: true);
                          await LibrosService.updateLibro(actualizado);
                          _loadLibros();
                        },
                  onTap: () => _abrirLibro(libro),
                  onEdit: () async {
                    final libroActualizado = await Navigator.push<Libro>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AgregarLibroScreen(libro: libro),
                      ),
                    );
                    if (libroActualizado != null) {
                      await LibrosService.updateLibro(libroActualizado);
                      _loadLibros();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Libro actualizado')),
                      );
                    }
                  },
                  onDelete: () => _confirmarEliminar(libro),
                );
              },
            ),
    );
  }
}
  //floatingActionButton: FloatingActionButton(
      //  backgroundColor: AdminLteColors.accent,
      //  onPressed: _agregarLibro,
      //  child: const Icon(Icons.add),
      //),
