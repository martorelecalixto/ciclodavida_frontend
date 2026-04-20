
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class EmailAttachmentWidget extends StatelessWidget {
  final List<PlatformFile> anexos;
  final ValueChanged<List<PlatformFile>> onChanged;

  const EmailAttachmentWidget({
    super.key,
    required this.anexos,
    required this.onChanged,
  });

  Future<void> _adicionarAnexo(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      onChanged([...anexos, ...result.files]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum arquivo selecionado.')),
      );
    }
  }

  String _formatFileSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    int unitIndex = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Anexos', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (anexos.isNotEmpty)
          ...anexos.map((file) {
            final size = _formatFileSize(file.size);
            return ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
              title: Text(file.name),
              subtitle: Text(size),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  final novos = List<PlatformFile>.from(anexos)..remove(file);
                  onChanged(novos);
                },
              ),
            );
          }),
        const SizedBox(height: 8),
        Center(
          child: OutlinedButton.icon(
            onPressed: () => _adicionarAnexo(context),
            icon: const Icon(Icons.attach_file),
            label: const Text('Adicionar Anexos'),
          ),
        ),
      ],
    );
  }
}












/*Versao 2
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class EmailAttachmentWidget extends StatelessWidget {
  final List<File> anexos;
  final ValueChanged<List<File>> onChanged;

  const EmailAttachmentWidget({
    super.key,
    required this.anexos,
    required this.onChanged,
  });

  Future<void> _adicionarAnexo(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      final newFiles = <File>[];

      for (var file in result.files) {
        if (file.path != null) {
          // Caminho físico disponível (Android/Desktop)
          newFiles.add(File(file.path!));
        } else if (file.bytes != null) {
          // Caminho ausente (ex: Flutter Web)
          final tempDir = Directory.systemTemp;
          final tempFile = File('${tempDir.path}/${file.name}');
          await tempFile.writeAsBytes(file.bytes!);
          newFiles.add(tempFile);
        }
      }

      if (newFiles.isNotEmpty) {
        onChanged([...anexos, ...newFiles]);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum arquivo válido selecionado.')),
        );
      }
    }
  }

  String _formatFileSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    int unitIndex = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Anexos', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (anexos.isNotEmpty)
          ...anexos.map((file) {
            final size = file.existsSync() ? _formatFileSize(file.lengthSync()) : '—';
            return ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
              title: Text(file.path.split('/').last),
              subtitle: Text(size),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  final novos = List<File>.from(anexos)..remove(file);
                  onChanged(novos);
                },
              ),
            );
          }),
        const SizedBox(height: 8),
        Center(
          child: OutlinedButton.icon(
            onPressed: () => _adicionarAnexo(context),
            icon: const Icon(Icons.attach_file),
            label: const Text('Adicionar Anexos'),
          ),
        ),
      ],
    );
  }
}
*/





/*Versao 3
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

class EmailAttachmentWidget extends StatelessWidget {
  final List<File> anexos;
  final ValueChanged<List<File>> onChanged;

  const EmailAttachmentWidget({
    super.key,
    required this.anexos,
    required this.onChanged,
  });

  Future<void> _adicionarAnexo(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      final newFiles = <File>[];

      for (var file in result.files) {
        if (file.path != null) {
          // Caminho físico disponível (Android/Desktop)
          newFiles.add(File(file.path!));
        } else if (file.bytes != null) {
          // Caminho ausente (ex: Flutter Web)
          final tempDir = Directory.systemTemp;
          final tempFile = File('${tempDir.path}/${file.name}');
          await tempFile.writeAsBytes(file.bytes!);
          newFiles.add(tempFile);
        }
      }

      if (newFiles.isNotEmpty) {
        onChanged([...anexos, ...newFiles]);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum arquivo válido selecionado.')),
        );
      }
    }
  }

  /// Formata o tamanho do arquivo em KB/MB
  String _formatFileSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    int unitIndex = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// Retorna ícone de acordo com o tipo de arquivo
  IconData _getFileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.xls':
      case '.xlsx':
        return Icons.grid_on;
      case '.zip':
      case '.rar':
        return Icons.archive;
      case '.mp4':
      case '.avi':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Verifica se é uma imagem suportada
  bool _isImage(String ext) {
    const imageExts = ['.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp'];
    return imageExts.contains(ext.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Anexos', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        // Mostra anexos com visual moderno
        if (anexos.isNotEmpty)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: anexos.map((file) {
              final ext = p.extension(file.path);
              final name = p.basename(file.path);
              final size = file.existsSync() ? _formatFileSize(file.lengthSync()) : '—';

              return Container(
                width: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Preview da imagem ou ícone
                        Container(
                          height: 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            color: Colors.white,
                          ),
                          child: _isImage(ext)
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.file(
                                    file,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 40),
                                  ),
                                )
                              : Icon(_getFileIcon(ext), size: 50, color: Colors.blueGrey),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, color: textColor),
                              ),
                              const SizedBox(height: 2),
                              Text(size, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: GestureDetector(
                        onTap: () {
                          final novos = List<File>.from(anexos)..remove(file);
                          onChanged(novos);
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(3),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

        const SizedBox(height: 16),

        Center(
          child: OutlinedButton.icon(
            onPressed: () => _adicionarAnexo(context),
            icon: const Icon(Icons.attach_file),
            label: const Text('Adicionar Anexos'),
          ),
        ),
      ],
    );
  }
}
*/






/*versao 1
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class EmailAttachmentWidget extends StatelessWidget {
  final List<File> anexos;
  final ValueChanged<List<File>> onChanged;

  const EmailAttachmentWidget({
    super.key,
    required this.anexos,
    required this.onChanged,
  });

  Future<void> _adicionarAnexo() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      final files = result.paths.map((path) => File(path!)).toList();
      onChanged([...anexos, ...files]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Anexos', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ...anexos.map(
              (file) => Chip(
                label: Text(file.path.split('/').last),
                onDeleted: () {
                  final novos = List<File>.from(anexos)..remove(file);
                  onChanged(novos);
                },
              ),
            ),
            ActionChip(
              label: const Text('Adicionar'),
              avatar: const Icon(Icons.attach_file),
              onPressed: _adicionarAnexo,
            ),
          ],
        ),
      ],
    );
  }
}
*/