import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    if (doc.exists) {
      setState(() {
        nombre = doc['nombre'] ?? '';
        apellido = doc['apellido'] ?? '';
        edad = doc['edad'] ?? 0;
        email = doc['email'] ?? '';
      });
    }
  }

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
            CircleAvatar(
              radius: 48,
              backgroundColor: AdminLteColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 48),
            ),
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
