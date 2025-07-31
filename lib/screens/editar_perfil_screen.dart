import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../theme.dart';
import '../services/auth_service.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _edadController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String photoUrl = '';
  bool _loading = false;
  String? _error;
  bool loadingFoto = false;
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      _nombreController.text = data['nombre'] ?? user!.displayName?.split(' ').first ?? '';
      _apellidoController.text = data['apellido'] ?? ((user!.displayName?.split(' ').length ?? 0) > 1
          ? user!.displayName?.split(' ').sublist(1).join(' ')
          : '');
      _edadController.text = data['edad']?.toString() ?? '';
      _emailController.text = data['email'] ?? user!.email ?? '';
      photoUrl = data['photoUrl'] ?? user!.photoURL ?? '';
      setState(() {});
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final edad = int.tryParse(_edadController.text.trim()) ?? 0;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Llama el método global
    final res = await AuthService().actualizarDatosUsuario(
      nombre: nombre,
      apellido: apellido,
      edad: edad,
      email: email,
      photoUrl: photoUrl,
      password: password.isNotEmpty ? password : null,
    );

    setState(() { _loading = false; });

    if (res == null) {
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Perfil actualizado!')),
      );
    } else {
      setState(() { _error = res; });
    }
  }

  Future<void> _cambiarFotoPerfil() async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tomar foto'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _seleccionarFoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Elegir de galería'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _seleccionarFoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _seleccionarFoto(ImageSource origen) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: origen, imageQuality: 75);
    if (pickedFile != null) {
      setState(() => loadingFoto = true);
      try {
        user = FirebaseAuth.instance.currentUser;
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_profiles')
            .child('${user!.uid}.jpg');
        await storageRef.putFile(File(pickedFile.path));
        final url = await storageRef.getDownloadURL();
        setState(() {
          photoUrl = url;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto actualizada (aún no guardada)')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir foto: $e')),
        );
      }
      setState(() => loadingFoto = false);
    }
  }

  Future<void> _enviarVerificacionEmail() async {
    try {
      await user!.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo de verificación enviado.')),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar correo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final verificado = user?.emailVerified ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AdminLteColors.primary,
                      backgroundImage: (photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                      child: (photoUrl.isEmpty)
                          ? const Icon(Icons.person, color: Colors.white, size: 48)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
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
              const SizedBox(height: 24),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _edadController,
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  final n = int.tryParse(v);
                  if (n == null || n < 0) return 'Edad no válida';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  if (!v.contains('@')) return 'Correo no válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Nueva contraseña (opcional)'),
                obscureText: true,
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(
                    verificado ? Icons.verified : Icons.verified_outlined,
                    color: verificado ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    verificado ? 'Correo verificado' : 'Correo no verificado',
                    style: TextStyle(color: verificado ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (!verificado)
                    TextButton.icon(
                      onPressed: _enviarVerificacionEmail,
                      icon: const Icon(Icons.email),
                      label: const Text('Verificar'),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: AdminLteColors.danger)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _guardar,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
