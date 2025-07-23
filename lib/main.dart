import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'screens/register_screen.dart';
import 'screens/lista_libros.dart';
import 'screens/perfil_usuario.dart';
import 'screens/libros_leidos_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';  
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BookApps',
      theme: adminLteTheme,
      home: const SplashScreen(),  
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const ListaLibros(),
        '/profile': (_) => const PerfilUsuario(),
        '/read': (_) => const LibrosLeidosScreen(),
      },
    );
  }
}
