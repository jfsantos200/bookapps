import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/perfil_usuario.dart';
import 'screens/libros_leidos_screen.dart';
import 'screens/lista_libros.dart';
import 'auth/auth_wrapper.dart';
import 'auth/verification_info_page.dart';


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
      initialRoute: '/', // Siempre splash
      routes: {
        '/': (_) => const SplashScreen(),
        '/auth': (_) => const AuthWrapper(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(modoCompletarPerfil: false,),
        '/home': (_) => const ListaLibros(),
        '/profile': (_) => const PerfilUsuario(),
        '/read': (_) => const LibrosLeidosScreen(),
        '/verification': (_) => const VerificationInfoPage(),
      },
    );
  }
}
