import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker_widget;

class FilePickerWidget extends StatefulWidget {
  final void Function(String path, String? extension, file_picker_widget.PlatformFile file)? onFileSelected;

  const FilePickerWidget({super.key, required this.onFileSelected});

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  String? _fileName;

  Future<void> _pickFile() async {
    final result = await file_picker_widget.FilePicker.platform.pickFiles(
      type: file_picker_widget.FileType.custom,
      allowedExtensions: ['pdf', 'epub', 'docx'],
      withData: true, // Si necesitas acceder a los bytes en web
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _fileName = file.name;
      });
      widget.onFileSelected!(
        file.path ?? '', // Vacío si es web, usa file.bytes
        file.extension,
        file,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: const Text('Seleccionar archivo'),
          onPressed: _pickFile,
        ),
        if (_fileName != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Archivo seleccionado: $_fileName'),
          ),
      ],
    );
  }
}
