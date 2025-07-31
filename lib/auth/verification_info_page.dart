import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Pantalla que explica al usuario que debe verificar su email
class VerificationInfoPage extends StatefulWidget {
  const VerificationInfoPage({super.key});

  @override
  State<VerificationInfoPage> createState() => _VerificationInfoPageState();
}

class _VerificationInfoPageState extends State<VerificationInfoPage> {
  bool _sending = false;
  bool _sent = false;

  Future<void> _sendVerificationEmail() async {
    setState(() { _sending = true; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      setState(() { _sent = true; });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error enviando correo: $e')),
      );
    } finally {
      setState(() { _sending = false; });
    }
  }

  Future<void> _checkVerification() async {
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo aún no verificado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Verifica tu correo')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            Text(
              'Te hemos enviado un correo de verificación a:\n${user?.email ?? ''}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 18),
            _sent
                ? const Text(
                    '¡Correo enviado! Revisa tu bandeja.',
                    style: TextStyle(color: Colors.green),
                  )
                : ElevatedButton.icon(
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send),
                    label: const Text('Reenviar correo'),
                    onPressed: _sending ? null : _sendVerificationEmail,
                  ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Ya verifiqué, continuar'),
              onPressed: _checkVerification,
            ),
            const SizedBox(height: 18),
            TextButton(
              child: const Text('Cerrar sesión'),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
