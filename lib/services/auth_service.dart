import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// STREAM de cambios de usuario (útil para detectar login/logout en toda la app)
  Stream<User?> get userChanges => _auth.userChanges();

  /// USUARIO autenticado actual
  User? get currentUser => _auth.currentUser;

  /// REGISTRO con email, password y datos personales.
  Future<String?> registerWithEmail({
    required String nombre,
    required String apellido,
    required int edad,
    required String email,
    required String password,
    String? photoUrl,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Actualiza displayName y photoURL en Auth
      await cred.user!.updateDisplayName('$nombre $apellido');
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await cred.user!.updatePhotoURL(photoUrl);
      }
      // Guarda los datos en Firestore
      await _db.collection('usuarios').doc(cred.user!.uid).set({
        'nombre': nombre,
        'apellido': apellido,
        'edad': edad,
        'email': email,
        'photoUrl': photoUrl ?? '',
        'creado': FieldValue.serverTimestamp(),
      });
      // Envía email de verificación
      await cred.user!.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return _traducirError(e);
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  /// LOGIN con email y password
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (!cred.user!.emailVerified) {
        await _auth.signOut();
        return 'Debes verificar tu correo antes de ingresar.';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _traducirError(e);
    }
  }

  /// RECUPERAR contraseña por correo
  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _traducirError(e);
    }
  }

  /// LOGIN con Google (y crea usuario en Firestore si es nuevo)
  Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return 'Inicio cancelado por el usuario.';
      final googleAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(cred);

      // Si es nuevo usuario, pide completar perfil después y crea documento
      if (result.additionalUserInfo?.isNewUser ?? false) {
        await _db.collection('usuarios').doc(result.user!.uid).set({
          'nombre': result.user?.displayName ?? '',
          'apellido': '',
          'edad': 0,
          'email': result.user?.email ?? '',
          'photoUrl': result.user?.photoURL ?? '',
          'creado': FieldValue.serverTimestamp(),
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _traducirError(e);
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  /// CIERRA SESIÓN global (incluye Google)
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  /// ACTUALIZA cualquier dato del usuario (nombre, apellido, email, foto, edad, contraseña)
  Future<String?> actualizarDatosUsuario({
    String? nombre,
    String? apellido,
    int? edad,
    String? email,
    String? photoUrl,
    String? password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return 'No hay usuario autenticado';
    try {
      // Auth: nombre y apellido
      if (nombre != null || apellido != null) {
        await user.updateDisplayName('${nombre ?? ''} ${apellido ?? ''}'.trim());
      }
      // Auth: email
      if (email != null && email.isNotEmpty && email != user.email) {
        await user.updateEmail(email);
      }
      // Auth: password
      if (password != null && password.isNotEmpty) {
        await user.updatePassword(password);
      }
      // Auth: foto
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await user.updatePhotoURL(photoUrl);
      }
      // Firestore
      Map<String, dynamic> updateData = {};
      if (nombre != null) updateData['nombre'] = nombre;
      if (apellido != null) updateData['apellido'] = apellido;
      if (edad != null) updateData['edad'] = edad;
      if (email != null) updateData['email'] = email;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      if (updateData.isNotEmpty) {
        await _db.collection('usuarios').doc(user.uid).update(updateData);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _traducirError(e);
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  /// Enviar email de verificación
  Future<String?> enviarEmailVerificacion() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'No hay usuario autenticado';
      await user.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return _traducirError(e);
    }
  }

  /// Traducción básica de errores de Firebase a español
  String _traducirError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Correo inválido.';
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'El correo ya está en uso.';
      case 'weak-password':
        return 'Contraseña demasiado débil (mínimo 6 caracteres).';
      case 'network-request-failed':
        return 'Sin conexión a Internet.';
      case 'user-disabled':
        return 'Cuenta deshabilitada, contacta soporte.';
      default:
        return e.message ?? 'Error desconocido.';
    }
  }

  /// STREAM del documento del usuario para refresco en tiempo real (para perfil reactivo)
  Stream<DocumentSnapshot<Map<String, dynamic>>> userDocStream(String uid) {
    return _db.collection('usuarios').doc(uid).snapshots();
  }
}
