import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  bool _loading = false;
  String? _errorMessage;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
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

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'nombre': nombre,
        'apellido': apellido,
        'edad': edad,
        'email': email,
        'creado': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ListaLibros()),
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
        await _pedirDatosExtrasGoogle(userCredential.user!);
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

  Future<void> _pedirDatosExtrasGoogle(User user) async {
    String nombre = '';
    String apellido = '';
    String edadStr = '';
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Completa tu perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                await FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(user.uid)
                    .set({
                  'nombre': nombre,
                  'apellido': apellido,
                  'edad': int.tryParse(edadStr),
                  'email': user.email,
                  'creado': FieldValue.serverTimestamp(),
                });
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
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
                    Icon(Icons.person_add, size: 56, color: AdminLteColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      "Crear Cuenta",
                      style: GoogleFonts.sourceSans3(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: AdminLteColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nombre
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    // Apellido
                    TextFormField(
                      controller: _apellidoController,
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    // Edad
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

                    // Email
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

                    // Contraseña
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

                    // Confirmar contraseña
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
                            : const Text("Registrarse"),
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
                        label: const Text("Registrarse con Google"),
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
                        "¿Ya tienes cuenta? Inicia sesión",
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
