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
        nombreCompleto = '${doc['nombre'] ?? ''} ${doc['apellido'] ?? ''}';
      });
    }
  }

  Future<void> _loadLibros() async {
    final libros = await LibrosService.getLibros();
    setState(() => _libros = libros);
  }

  void _agregarLibro() async {
    final libro = await Navigator.push<Libro>(
      context,
      MaterialPageRoute(builder: (_) => const AgregarLibroScreen()),
    );
    if (libro != null) {
      await LibrosService.addLibro(libro);
      _loadLibros();
    }
  }

  void _abrirLibrosLeidos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LibrosLeidosScreen()),
    );
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

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          nombreCompleto.isNotEmpty
              ? 'Hola, $nombreCompleto'
              : 'Mis Libros',
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
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
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
                      decoration: BoxDecoration(color: AdminLteColors.dark),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.account_circle, color: Colors.white, size: 42),
                          const SizedBox(height: 12),
                          Text(
                            nombreCompleto.isNotEmpty
                                ? nombreCompleto
                                : 'Usuario',
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
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Acciones', style: TextStyle(color: Colors.white, fontSize: 22)),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Agregar libro'),
              onTap: () {
                Navigator.of(context).pop();
                _agregarLibro();
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Libros leídos'),
              onTap: () {
                Navigator.of(context).pop();
                _abrirLibrosLeidos();
              },
            ),
          ],
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
                  title: libro.titulo,
                  author: libro.autor,
                  imageUrl: libro.imagen ?? '',
                  isRead: libro.leido,
                  onMarkRead: libro.leido
                      ? null
                      : () async {
                          final actualizado = libro.copyWith(leido: true);
                          await LibrosService.updateLibro(actualizado);
                          _loadLibros();
                        },
                  onTap: () {},
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AdminLteColors.accent,
        child: const Icon(Icons.add),
        onPressed: _agregarLibro,
      ),
    );
  }
}
