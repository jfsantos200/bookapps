import 'package:bookapps/widgets/visor_archivo_libro.dart';
import 'package:flutter/material.dart';
import '../models/libro.dart';

class BookCard extends StatelessWidget {
  final Libro libro;
  final VoidCallback? onMarkRead;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const BookCard({
    super.key,
    required this.libro,
    this.onMarkRead,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          // --- INICIO: Lógica para visor PDF/EPUB, local y remoto ---
          String? path;
          String? ext;
          if ((libro.archivoUrl != null && libro.archivoUrl!.isNotEmpty)) {
            path = libro.archivoUrl;
          } else if ((libro.localPath != null && libro.localPath!.isNotEmpty)) {
            path = libro.localPath;
          }
          if (path != null) {
            final lower = path.toLowerCase();
            if (lower.endsWith('.pdf')) ext = 'pdf';
            if (lower.endsWith('.epub')) ext = 'epub';
          }
          if (path != null && ext != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VisorArchivoLibro(
                  archivoUrl: libro.archivoUrl, // puede ser null si es local
                  localPath: libro.localPath,   // puede ser null si es remoto
                  tipoArchivo: ext!,
                ),
              ),
            );
          } else if (onTap != null) {
            onTap!();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Archivo no soportado.')),
            );
          }
          // --- FIN: Visor PDF/EPUB ---
        },
        leading: libro.imagen.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  libro.imagen,
                  width: 48,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.book, size: 48),
                ),
              )
            : const Icon(Icons.book, size: 48),
        title: Text(libro.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(libro.autor, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (libro.leido)
              const Text('LEÍDO', style: TextStyle(color: Colors.green)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!libro.leido && onMarkRead != null)
              IconButton(
                icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                tooltip: 'Marcar como leído',
                onPressed: onMarkRead,
              ),
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                tooltip: 'Editar libro',
                onPressed: onEdit,
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Eliminar libro',
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
