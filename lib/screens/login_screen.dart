import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'register_screen.dart';
import 'lista_libros.dart';
import '../services/auth_service.dart'; // Importa tu AuthService

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    final auth = AuthService();
    final error = await auth.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (error == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ListaLibros()),
      );
    } else {
      setState(() => _errorMessage = error);
    }
    setState(() => _loading = false);
  }

  Future<void> _recuperarContrasena() async {
    final emailController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar contraseña'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Ingresa tu correo',
          ),
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(emailController.text),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final auth = AuthService();
      final error = await auth.sendPasswordReset(result.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Correo enviado para recuperar contraseña'),
        ),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() { _loading = true; _errorMessage = null; });
    final auth = AuthService();
    final error = await auth.signInWithGoogle();
    if (error == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ListaLibros()),
      );
    } else {
      setState(() => _errorMessage = error);
    }
    setState(() => _loading = false);
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
                    Image.asset('assets/logo.png', height: 200, width: 200),
                    const SizedBox(height: 0),
                    Text(
                      'Iniciar Sesión',
                      style: GoogleFonts.sourceSans3(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: AdminLteColors.dark,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                                  _login();
                                }
                              },
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : const Text('Entrar'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      icon: Image.asset('assets/google_logo.png', height: 22),
                      label: const Text('Iniciar con Google'),
                      onPressed: _loading ? null : _loginWithGoogle,
                    ),
                    TextButton(
                      onPressed: _recuperarContrasena,
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: AdminLteColors.info),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => RegisterScreen(modoCompletarPerfil: false,)),
                        );
                      },
                      child: Text(
                        '¿No tienes cuenta? Regístrate',
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
