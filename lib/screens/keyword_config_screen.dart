import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/secure_storage_service.dart';

/// Pantalla de configuración de la palabra clave del borrado remoto.
///
/// Permite al usuario guardar su `wipe_keyword`, cargar datos de prueba para
/// poder demostrar el borrado, y ver si hay datos sensibles almacenados.
class KeywordConfigScreen extends StatefulWidget {
  const KeywordConfigScreen({super.key});

  @override
  State<KeywordConfigScreen> createState() => _KeywordConfigScreenState();
}

class _KeywordConfigScreenState extends State<KeywordConfigScreen> {
  final SecureStorageService _storage = SecureStorageService();
  final TextEditingController _keywordController = TextEditingController();

  bool _loading = true;
  bool _hasData = false;
  bool _hasKeyword = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  /// Recarga el estado (palabra clave guardada + si hay datos sensibles).
  Future<void> _refresh() async {
    try {
      final keyword =
          await _storage.read(SecureStorageService.kWipeKeyword) ?? '';
      final hasData = await _storage.hasSensitiveData();
      if (!mounted) return;
      setState(() {
        _keywordController.text = keyword;
        _hasKeyword = keyword.trim().isNotEmpty;
        _hasData = hasData;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack('Error leyendo el almacenamiento seguro: $e');
    }
  }

  Future<void> _saveKeyword() async {
    final value = _keywordController.text.trim();
    if (value.isEmpty) {
      _snack('Escribe una palabra clave antes de guardar.');
      return;
    }
    try {
      await _storage.write(SecureStorageService.kWipeKeyword, value);
      await _refresh();
      _snack('Palabra clave guardada de forma segura.');
    } catch (e) {
      _snack('No se pudo guardar la palabra clave: $e');
    }
  }

  Future<void> _seedDemoData() async {
    try {
      await _storage.seedDemoData();
      await _refresh();
      _snack('Datos de prueba cargados.');
    } catch (e) {
      _snack('No se pudieron cargar los datos de prueba: $e');
    }
  }

  Future<void> _wipeNow() async {
    try {
      await _storage.deleteAll();
      await _refresh();
      _snack('Datos sensibles borrados (manual).');
    } catch (e) {
      _snack('No se pudieron borrar los datos: $e');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  /// SOLO DEBUG/DEMO: lee todas las claves del secure storage y las muestra en
  /// un diálogo. No usar en producción: revela datos sensibles en pantalla.
  Future<void> _dumpStored() async {
    const keys = <String>[
      SecureStorageService.kWipeKeyword,
      SecureStorageService.kJwtAccessToken,
      SecureStorageService.kJwtRefreshToken,
      SecureStorageService.kSqlcipherKey,
      SecureStorageService.kClienteDatos,
    ];

    final lines = <Widget>[];
    try {
      for (final key in keys) {
        final value = await _storage.read(key);
        // También lo dejamos en consola para verlo con `flutter run`.
        debugPrint('[secure_storage] $key = ${value ?? "(vacío)"}');
        lines.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(key,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(value ?? '(vacío)'),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      _snack('Error leyendo el almacenamiento: $e');
      return;
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Contenido del almacenamiento seguro'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lines,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Borrado remoto — Configuración')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Palabra clave de seguridad',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Si tu dispositivo recibe un comando de borrado remoto con '
                    'esta palabra clave, todos los datos sensibles se eliminarán.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _keywordController,
                    decoration: const InputDecoration(
                      labelText: 'Palabra clave',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.vpn_key),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _saveKeyword,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar palabra clave'),
                  ),
                  const Divider(height: 40),

                  // --- Estado actual ---
                  _StatusTile(
                    icon: _hasKeyword
                        ? Icons.check_circle
                        : Icons.error_outline,
                    color: _hasKeyword ? Colors.green : Colors.orange,
                    label: _hasKeyword
                        ? 'Palabra clave configurada'
                        : 'Sin palabra clave',
                  ),
                  _StatusTile(
                    icon: _hasData
                        ? Icons.inventory_2
                        : Icons.inbox_outlined,
                    color: _hasData ? Colors.blue : Colors.grey,
                    label: _hasData
                        ? 'Hay datos sensibles guardados'
                        : 'No hay datos sensibles guardados',
                  ),
                  const Divider(height: 40),

                  // --- Acciones de demo ---
                  OutlinedButton.icon(
                    onPressed: _seedDemoData,
                    icon: const Icon(Icons.science),
                    label: const Text('Cargar datos de prueba'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _hasData ? _wipeNow : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Borrar ahora (manual)'),
                  ),
                  const SizedBox(height: 8),
                  // SOLO DEBUG/DEMO: vuelca lo guardado para inspeccionarlo.
                  if (kDebugMode)
                    OutlinedButton.icon(
                      onPressed: _dumpStored,
                      icon: const Icon(Icons.bug_report),
                      label: const Text('Ver datos guardados (debug)'),
                    ),
                ],
              ),
            ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _StatusTile({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
