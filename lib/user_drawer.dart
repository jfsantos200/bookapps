import 'package:bookapps/screens/login_screen.dart';
import 'package:bookapps/screens/perfil_usuario.dart';
import 'package:bookapps/screens/buscar_libro_google.dart'; // <-- Agrega el import
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserDrawer extends StatelessWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onPerfil;

  const UserDrawer({super.key, this.onLogout, this.onPerfil});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String? photoUrl = user?.photoURL;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.orange,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                photoUrl != null
                    ? CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage(photoUrl),
                      )
                    : const CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40, color: Colors.orange),
                      ),
                const SizedBox(height: 12),
                Text(
                  user?.email ?? 'Sin correo',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: onPerfil ??
                () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PerfilUsuario()));
                },
          ),
          ListTile(
            leading: const Icon(Icons.search, color: Colors.blue),
            title: const Text('Buscar libros online', style: TextStyle(color: Colors.blue)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BuscarLibroGoogleScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
            onTap: onLogout ??
                () async {
                  await FirebaseAuth.instance.signOut();
                  try {
                    await GoogleSignIn().signOut();
                  } catch (_) {}
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
          ),
        ],
      ),
    );
  }
}
