import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../theme.dart';
import 'editar_perfil_screen.dart';

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({super.key});

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  String nombre = '';
  String apellido = '';
  int edad = 0;
  String email = '';
  String photoUrl = '';
  bool loadingFoto = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();

    setState(() {
      final firestoreData = doc.data() ?? {};
      nombre = firestoreData['nombre'] ??
          (user?.displayName?.split(' ').first ?? '');
      apellido = firestoreData['apellido'] ??
          ((user?.displayName?.split(' ').length ?? 0) > 1
              ? user?.displayName?.split(' ').sublist(1).join(' ')
              : '');
      edad = firestoreData['edad'] ?? 0;
      email = firestoreData['email'] ?? user?.email ?? '';
      photoUrl = firestoreData['photoUrl'] ?? user?.photoURL ?? '';
    });
  }

  // --- INICIO: NUEVO MÉTODO PARA CAMBIAR FOTO ---
  Future<void> _cambiarFotoPerfil() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);

    if (pickedFile != null) {
      setState(() => loadingFoto = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_profiles')
            .child('${user!.uid}.jpg');

        // Sube la foto a Firebase Storage
        await storageRef.putFile(File(pickedFile.path));
        final url = await storageRef.getDownloadURL();

        // Actualiza en Auth
        await user.updatePhotoURL(url);

        // Actualiza en Firestore
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .update({'photoUrl': url});

        setState(() {
          photoUrl = url;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Foto de perfil actualizada!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar foto: $e')),
        );
      }
      setState(() => loadingFoto = false);
    }
  }
  // --- FIN: NUEVO MÉTODO PARA CAMBIAR FOTO ---

  Future<void> _editarPerfil() async {
    final actualizado = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditarPerfilScreen()),
    );
    if (actualizado == true) {
      _cargarDatos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- INICIO: CÍRCULO AVATAR CON BOTÓN DE CAMBIAR FOTO ---
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AdminLteColors.primary,
                    backgroundImage: (photoUrl.isNotEmpty)
                        ? NetworkImage(photoUrl)
                        : null,
                    child: (photoUrl.isEmpty)
                        ? const Icon(Icons.person, color: Colors.white, size: 48)
                        : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: InkWell(
                      onTap: loadingFoto ? null : _cambiarFotoPerfil,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: loadingFoto
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // --- FIN: CÍRCULO AVATAR CON BOTÓN DE CAMBIAR FOTO ---
            const SizedBox(height: 24),
            Text('$nombre $apellido', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AdminLteColors.dark)),
            const SizedBox(height: 8),
            Text('Edad: $edad', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AdminLteColors.gray)),
            const SizedBox(height: 8),
            Text(email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AdminLteColors.gray)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _editarPerfil,
              icon: const Icon(Icons.edit),
              label: const Text('Editar perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
