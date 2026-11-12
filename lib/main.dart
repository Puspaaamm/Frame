import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/app_engine.dart';
import 'services/file_scanner.dart';

void main() {
  runApp(const FrameApp());
}

class FrameApp extends StatefulWidget {
  const FrameApp({super.key});

  @override
  State<FrameApp> createState() => _FrameAppState();
}

class _FrameAppState extends State<FrameApp> {
  AppThemeMode _themeMode = AppThemeMode.dark;
  String? _userName = "Pushpam";

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeIndex = prefs.getInt('theme_mode') ?? 1;
    setState(() {
      _themeMode = AppThemeMode.values[savedThemeIndex];
    });
  }

  Future<void> _cycleTheme() async {
    final nextIndex = (_themeMode.index + 1) % AppThemeMode.values.length;
    setState(() {
      _themeMode = AppThemeMode.values[nextIndex];
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', nextIndex);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frame',
      debugShowCheckedModeBanner: false,
      theme: AppEngine.getThemeData(_themeMode),
      home: FrameHomeScreen(
        userName: _userName,
        currentTheme: _themeMode,
        onCycleTheme: _cycleTheme,
      ),
    );
  }
}

class FrameHomeScreen extends StatefulWidget {
  final String? userName;
  final AppThemeMode currentTheme;
  final VoidCallback onCycleTheme;

  const FrameHomeScreen({
    super.key,
    required this.userName,
    required this.currentTheme,
    required this.onCycleTheme,
  });

  @override
  State<FrameHomeScreen> createState() => _FrameHomeScreenState();
}

class _FrameHomeScreenState extends State<FrameHomeScreen> {
  int _selectedIndex = 0;
  bool _isOnline = true;
  bool _isLoading = true;
  List<PsdAsset> _psdFiles = [];
  List<File> _fontFiles = [];

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _requestPermissionsAndScan();
  }

  void _initConnectivity() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      setState(() {
        _isOnline = results.isNotEmpty && !results.contains(ConnectivityResult.none);
      });
    });
  }

  Future<void> _requestPermissionsAndScan() async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();

    final psds = await FileScannerService.scanPsdFiles();
    final fonts = await FileScannerService.scanFontFiles();

    setState(() {
      _psdFiles = psds;
      _fontFiles = fonts;
      _isLoading = false;
    });
  }

  void _showRenameDialog(PsdAsset asset) {
    final controller = TextEditingController(text: asset.name.replaceAll('.psd', ''));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename PSD File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter new file name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final renamed = await FileScannerService.renameFile(asset.file, controller.text.trim());
              if (renamed != null) {
                _requestPermissionsAndScan();
              }
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final greeting = AppEngine.getGreeting(widget.userName);
    final festivalWish = AppEngine.getFestivalWish(widget.userName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frame', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Chip(
            label: Text(_isOnline ? 'Online' : 'Offline Mode', style: const TextStyle(fontSize: 11)),
            backgroundColor: _isOnline ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
          ),
          IconButton(
            icon: Icon(
              widget.currentTheme == AppThemeMode.light
                  ? Icons.light_mode
                  : widget.currentTheme == AppThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.nights_stay,
            ),
            tooltip: 'Switch Theme',
            onPressed: widget.onCycleTheme,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              greeting,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          if (festivalWish != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(festivalWish, style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedIndex == 0
                    ? _buildPsdList()
                    : _selectedIndex == 1
                        ? _buildFontList()
                        : _buildCloudTab(),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.layers), label: 'PSD Files'),
          NavigationDestination(icon: Icon(Icons.font_download), label: 'Fonts'),
          NavigationDestination(icon: Icon(Icons.cloud_sync), label: 'Cloud'),
        ],
      ),
    );
  }

  Widget _buildPsdList() {
    if (_psdFiles.isEmpty) {
      return const Center(child: Text('No .psd files found in local storage.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _psdFiles.length,
      itemBuilder: (ctx, idx) {
        final psd = _psdFiles[idx];
        final sizeMb = (psd.sizeBytes / (1024 * 1024)).toStringAsFixed(2);
        return Card(
          child: ListTile(
            leading: const Icon(Icons.image, size: 36),
            title: Text(psd.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('$sizeMb MB • Modified: ${psd.modified.toString().split(' ')[0]}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showRenameDialog(psd),
            ),
            onTap: () => _openPsdInspector(psd),
          ),
        );
      },
    );
  }

  Widget _buildFontList() {
    if (_fontFiles.isEmpty) {
      return const Center(child: Text('No .ttf, .otf, or .zip fonts detected.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _fontFiles.length,
      itemBuilder: (ctx, idx) {
        final font = _fontFiles[idx];
        final name = font.path.split('/').last;
        return Card(
          child: ListTile(
            leading: Icon(name.endsWith('.zip') ? Icons.folder_zip : Icons.text_fields),
            title: Text(name),
            subtitle: const Text('The quick brown fox jumps over the lazy dog'),
          ),
        );
      },
    );
  }

  Widget _buildCloudTab() {
    if (!_isOnline) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'You are currently Offline.\nConnect to the internet to sync Google Drive and Dropbox files.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.add_to_drive, color: Colors.blue),
            title: const Text('Connect Google Drive'),
            subtitle: const Text('Sync remote .psd and font folders'),
            trailing: ElevatedButton(onPressed: () {}, child: const Text('Connect')),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.cloud, color: Colors.indigo),
            title: const Text('Connect Dropbox'),
            subtitle: const Text('Access design assets from Dropbox'),
            trailing: ElevatedButton(onPressed: () {}, child: const Text('Connect')),
          ),
        ),
      ],
    );
  }

  void _openPsdInspector(PsdAsset psd) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final data = await FileScannerService.inspectPsd(psd.file);
    if (!mounted) return;
    Navigator.pop(context);

    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to parse this PSD file.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(psd.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(data['pngBytes'], height: 200, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 12),
            Text('Dimensions: ${data['width']} x ${data['height']} px • Channels: ${data['channels']}'),
            const SizedBox(height: 8),
            const Text('Extracted Color Palette:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: (data['palette'] as List<Color>).map((color) {
                return Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Export PNG'),
                    onPressed: () async {
                      final outPath = psd.file.path.replaceAll('.psd', '_export.png');
                      await FileScannerService.exportAsset(data['image'], outPath, asPng: true);
                      if (mounted) Navigator.pop(ctx);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Export JPEG'),
                    onPressed: () async {
                      final outPath = psd.file.path.replaceAll('.psd', '_export.jpg');
                      await FileScannerService.exportAsset(data['image'], outPath, asPng: false);
                      if (mounted) Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
