import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../theme.dart';
import 'lista_libros.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _edadController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  File? _pickedPhoto;
  String _photoUrl = '';
  bool _loading = false;
  String? _errorMessage;
  bool _enviadoCorreoVerificacion = false;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) setState(() => _pickedPhoto = File(picked.path));
  }

  Future<String?> _subirFoto(String uid) async {
    if (_pickedPhoto == null) return null;
    final storageRef = FirebaseStorage.instance.ref().child('user_profiles').child('$uid.jpg');
    await storageRef.putFile(_pickedPhoto!);
    return await storageRef.getDownloadURL();
  }

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _enviadoCorreoVerificacion = false;
    });
    try {
      final nombre = _nombreController.text.trim();
      final apellido = _apellidoController.text.trim();
      final edad = int.tryParse(_edadController.text.trim()) ?? 0;
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? urlFoto = await _subirFoto(userCredential.user!.uid);
      if (urlFoto != null) {
        await userCredential.user!.updatePhotoURL(urlFoto);
        _photoUrl = urlFoto;
      }
      await userCredential.user!.updateDisplayName('$nombre $apellido');

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'nombre': nombre,
        'apellido': apellido,
        'edad': edad,
        'email': email,
        'photoUrl': _photoUrl,
        'creado': FieldValue.serverTimestamp(),
      });

      await userCredential.user!.sendEmailVerification();
      setState(() {
        _enviadoCorreoVerificacion = true;
      });

      // Puedes mostrar un aviso al usuario que debe verificar su correo
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Verificación de correo'),
          content: const Text('Se ha enviado un correo para verificar tu cuenta. Verifica antes de continuar.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ListaLibros()),
                );
              },
              child: const Text('OK'),
            )
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Error inesperado: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // LOGIN/REGISTRO CON GOOGLE
  Future<void> _loginWithGoogle() async {
    setState(() { _loading = true; _errorMessage = null; });
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return; // usuario canceló
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).get();
      if (!doc.exists) {
        await _completarPerfilGoogle(userCredential.user!);
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ListaLibros()),
      );
    } catch (e) {
      setState(() => _errorMessage = 'Error con Google: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _completarPerfilGoogle(User user) async {
    String nombre = '';
    String apellido = '';
    String edadStr = '';
    File? localFoto;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Completa tu perfil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
                  if (picked != null) setDialogState(() => localFoto = File(picked.path));
                },
                child: CircleAvatar(
                  radius: 32,
                  backgroundImage: (localFoto != null)
                      ? FileImage(localFoto!)
                      : (user.photoURL != null ? NetworkImage(user.photoURL!) : null) as ImageProvider<Object>?,
                  child: localFoto == null && user.photoURL == null
                      ? const Icon(Icons.person, size: 32)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onChanged: (v) => nombre = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Apellido'),
                onChanged: (v) => apellido = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                onChanged: (v) => edadStr = v,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nombre.isNotEmpty && apellido.isNotEmpty && int.tryParse(edadStr) != null) {
                  String? urlFoto = user.photoURL;
                  if (localFoto != null) {
                    final storageRef = FirebaseStorage.instance
                        .ref()
                        .child('user_profiles')
                        .child('${user.uid}.jpg');
                    await storageRef.putFile(localFoto!);
                    urlFoto = await storageRef.getDownloadURL();
                    await user.updatePhotoURL(urlFoto);
                  }
                  await FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(user.uid)
                      .set({
                    'nombre': nombre,
                    'apellido': apellido,
                    'edad': int.tryParse(edadStr),
                    'email': user.email,
                    'photoUrl': urlFoto,
                    'creado': FieldValue.serverTimestamp(),
                  });
                  await user.updateDisplayName('$nombre $apellido');
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminLteColors.light,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Card(
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Foto de perfil
                    GestureDetector(
                      onTap: _pickPhoto,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: (_pickedPhoto != null)
                            ? FileImage(_pickedPhoto!)
                            : null,
                        child: _pickedPhoto == null
                            ? const Icon(Icons.add_a_photo, size: 40, color: AdminLteColors.primary)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Crear Cuenta',
                      style: GoogleFonts.sourceSans3(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: AdminLteColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _apellidoController,
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _edadController,
                      decoration: const InputDecoration(
                        labelText: 'Edad',
                        prefixIcon: Icon(Icons.cake),
                      ),
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
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingrese su correo';
                        if (!value.contains('@')) return 'Correo no válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingrese su contraseña';
                        if (value.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _confirmController,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar contraseña',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value != _passwordController.text) return 'No coincide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.sourceSans3(color: AdminLteColors.danger),
                        ),
                      ),
                    if (_enviadoCorreoVerificacion)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Correo de verificación enviado. Revisa tu bandeja antes de continuar.',
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading
                            ? null
                            : () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  _register();
                                }
                              },
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : const Text('Registrarse'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botón de Google
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: Image.asset(
                          'assets/google_logo.png',
                          height: 24,
                          width: 24,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.login),
                        ),
                        label: const Text('Registrarse con Google'),
                        onPressed: _loading ? null : _loginWithGoogle,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: GoogleFonts.sourceSans3(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '¿Ya tienes cuenta? Inicia sesión',
                        style: GoogleFonts.sourceSans3(color: AdminLteColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
