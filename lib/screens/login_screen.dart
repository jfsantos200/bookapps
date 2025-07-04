import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'lista_libros.dart';
import 'recuperar_contrasena.dart';

const Color primaryColor = Color.fromARGB(255, 243, 89, 33);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isRegisterMode = false;
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  void _toggleRegisterMode() {
    setState(() => _isRegisterMode = !_isRegisterMode);
  }

  String? _validateEmail(String? value) {
    if (value == null ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Correo inválido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (_isRegisterMode && (value == null || value.isEmpty)) {
      return 'Campo obligatorio';
    }
    return null;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ListaLibros()),
        );
      } catch (e) {
        _showError('Credenciales incorrectas o error de red');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        _showError('Cuenta creada. Inicia sesión.');
        _toggleRegisterMode();
      } catch (e) {
        _showError('Error al registrar. Tal vez ya existe.');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // Usa el clientId solo para web, en Android/iOS déjalo nulo.
      final googleSignIn = GoogleSignIn(
        clientId: kIsWeb
            ? '139849852555-vpr8b6o34k12bpuoivqqmnrvq6pfb5n1.apps.googleusercontent.com'
            : null,
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _showError('Inicio de sesión cancelado');
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        _showError('Error autenticando con Google (idToken no recibido)');
        setState(() => _isLoading = false);
        return;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ListaLibros()),
      );
    } catch (e) {
      _showError('Error al iniciar con Google');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _gotoRecuperar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecuperarContrasena()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.menu_book,
                          size: 80, color: primaryColor),
                      const SizedBox(height: 16),
                      Text(
                        'Bienvenido a Biblioteca Personal',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !_isRegisterMode
                                  ? primaryColor // Active color
                                  : Colors.grey, // Inactive color
                            ),
                            onPressed: _isRegisterMode
                                ? _toggleRegisterMode // Only clickable if in register mode
                                : null,
                            child: const Text("Iniciar Sesión"),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isRegisterMode
                                  ? primaryColor // Active color
                                  : Colors.grey, // Inactive color
                            ),
                            onPressed: !_isRegisterMode
                                ? _toggleRegisterMode // Only clickable if not in register mode
                                : null,
                            child: const Text("Crear Cuenta"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: _gotoRecuperar,
                          child: const Text("¿Olvidaste tu contraseña?"),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (_isRegisterMode)
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateName,
                              ),
                            if (_isRegisterMode)
                              const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Correo',
                                border: OutlineInputBorder(),
                              ),
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_showPassword,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(_showPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(() =>
                                      _showPassword = !_showPassword),
                                ),
                              ),
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                minimumSize: const Size.fromHeight(50),
                              ),
                              onPressed:
                                  _isRegisterMode ? _register : _login,
                              child: Text(_isRegisterMode
                                  ? 'Registrar'
                                  : 'Iniciar Sesión'),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _loginWithGoogle,
                              icon: const Icon(Icons.login),
                              label: const Text("Iniciar con Google"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
