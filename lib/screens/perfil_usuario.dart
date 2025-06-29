import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({super.key});

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  late User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _refreshUser();
  }

  Future<void> _refreshUser() async {
    user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  Future<void> _enviarVerificacion() async {
    await user?.sendEmailVerification();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Correo de verificación enviado')),
    );
    _refreshUser();
  }

  Future<void> _enviarRecuperacion() async {
    if (user?.email == null) return;
    await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Correo de recuperación enviado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verificado = user?.emailVerified ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Correo: ${user?.email ?? ''}"),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "Estado: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                verificado
                    ? const Text("✔️ Verificado",
                        style: TextStyle(color: Colors.green))
                    : const Text("❌ No verificado",
                        style: TextStyle(color: Colors.red)),
              ],
            ),
            const SizedBox(height: 16),
            if (!verificado)
              ElevatedButton.icon(
                icon: const Icon(Icons.verified),
                label: const Text("Enviar correo de verificación"),
                onPressed: _enviarVerificacion,
              ),
            ElevatedButton.icon(
              icon: const Icon(Icons.lock_reset),
              label: const Text("Enviar recuperación de contraseña"),
              onPressed: _enviarRecuperacion,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Cerrar sesión"),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Actualizar estado"),
              onPressed: _refreshUser,
            ),
          ],
        ),
      ),
    );
  }
}
