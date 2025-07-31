import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/lista_libros.dart';
import '/screens/login_screen.dart';
import '/auth/verification_info_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        // Mientras carga, muestra un loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          // Usuario no autenticado
          return const LoginScreen();
        } else if (!user.emailVerified) {
          // Usuario autenticado pero no ha verificado el correo
          return const VerificationInfoPage();
        } else {
          // Usuario autenticado y verificado
          return const ListaLibros();
        }
      },
    );
  }
}
