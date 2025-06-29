# bookapps
# bookapps

# BookApps (Versión Local)

App de Biblioteca Personal en Flutter  
**Versión: Solo almacenamiento local**

---

## 📱 Descripción

**BookApps** es una aplicación para gestionar tu biblioteca personal. Puedes:
- Registrar libros de forma manual o buscarlos usando Google Books (incluyendo vista previa si está disponible).
- Marcar libros como leídos.
- Acceder a una lista de libros leídos.
- Autenticación segura mediante correo/contraseña o Google Sign-In (Firebase Auth).
- Recuperar contraseña y verificación de email.
- Guardar todos tus libros en el dispositivo de forma local.
- **No utiliza sincronización en la nube** (no usa Firestore).

---

## 🚀 Funcionalidades principales

- **Login y registro** con Firebase Authentication (email/password y Google).
- **Gestión de perfil** (verificar email, recuperar contraseña, cerrar sesión).
- **CRUD de libros**: agregar, marcar como leído, ver lista y leídos.
- **Búsqueda con Google Books** (con preview si existe).
- **Interfaz simple y adaptable a móvil o escritorio**.

---

## 🏗️ Estructura del proyecto

bookapps/
├── lib/
│ ├── main.dart
│ ├── firebase_options.dart # (generado con FlutterFire CLI)
│ ├── models/
│ │ └── libro.dart
│ ├── services/
│ │ └── libros_service.dart # Solo SharedPreferences, no Firestore
│ ├── widgets/
│ │ └── google_books_search.dart
│ └── screens/
│ ├── login_screen.dart
│ ├── perfil_usuario.dart
│ ├── recuperar_contrasena.dart
│ ├── lista_libros.dart
│ ├── agregar_libro_screen.dart
│ └── libros_leidos_screen.dart
├── pubspec.yaml

---

## ⚙️ Instalación y uso

1. **Clona el repositorio o copia los archivos.**
2. **Agrega tu archivo `firebase_options.dart`** generado por FlutterFire CLI en `/lib/`.
3. **Ejecuta:**
   ```bash
   flutter pub get
   flutter run
Crea tu cuenta o inicia sesión.

¡Empieza a agregar tus libros!

🔐 Notas de seguridad
Los libros se guardan solo en el dispositivo (no en la nube).

Si desinstalas la app o cambias de dispositivo, perderás tus libros (excepto credenciales, que están en Firebase).

Solo la autenticación usa Firebase.

🌎 Tecnologías utilizadas
Flutter 3.8.1

Firebase Auth

Shared Preferences

Google Books API

Google Fonts, UUID

url_launcher

✍️ Autor
Desarrollado por Jhonattan Santos, Pedro Luis Mateo y Leonardo Cuenca.

