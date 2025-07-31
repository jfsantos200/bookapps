import 'package:permission_handler/permission_handler.dart';

Future<void> solicitarPermisos() async {
  // Por ejemplo, permiso de almacenamiento:
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    status = await Permission.storage.request();
  }

  // Puedes solicitar varios permisos juntos:
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.photos,
    Permission.microphone,
  ].request();

  if (statuses[Permission.camera]!.isGranted) {
    // El permiso fue otorgado
  } else {
    // El permiso fue denegado
  }
}
