import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_manager/file_manager.dart';
import 'package:open_file/open_file.dart';   // FIXED: replaced open_file_plus
import 'package:permission_handler/permission_handler.dart';

class InternalStorageScreen extends StatefulWidget {
  @override
  _InternalStorageScreenState createState() => _InternalStorageScreenState();
}

class _InternalStorageScreenState extends State<InternalStorageScreen> {
  final FileManagerController controller = FileManagerController();

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  Future<void> requestPermission() async {
    await Permission.storage.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Internal Storage",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FileManager(
        controller: controller,
        builder: (context, snapshot) {
          final List<FileSystemEntity> entities = snapshot;
          return ListView.builder(
            itemCount: entities.length,
            itemBuilder: (context, index) {
              final entity = entities[index];
              final String path = entity.path;
              final String name = FileManager.basename(entity);

              return ListTile(
                leading: FileManager.isFile(entity)
                    ? const Icon(Icons.insert_drive_file)
                    : const Icon(Icons.folder),
                title: Text(name),
                onTap: () async {
                  if (FileManager.isDirectory(entity)) {
                    controller.openDirectory(entity);
                  } else {
                    // FIXED → use open_file instead of open_file_plus
                    await OpenFile.open(path);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
