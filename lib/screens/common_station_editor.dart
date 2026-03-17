import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metro_next_taipei/services/database.dart';

class CommonStationsEditor extends StatefulWidget {
  const CommonStationsEditor({super.key});
  @override
  State<CommonStationsEditor> createState() => _CommonStationsEditorState();
}

class _CommonStationsEditorState extends State<CommonStationsEditor> {
  List<Map<String, String>> stations = [];
  List<Map<String, String>> filtered = [];
  final TextEditingController _search = TextEditingController();
  Set<String> selected = {};

  @override
  void initState() {
    super.initState();
    _loadAllStations();
    _search.addListener(_onSearch);
    _loadSelected();
  }

  Future<void> _loadSelected() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList('commonStations') ?? [];
    setState(() {
      selected = items.toSet();
    });
  }

  void _onSearch() {
    final k = _search.text.trim();
    if (k.isEmpty) {
      setState(() => filtered = List.from(stations));
    } else {
      setState(() {
        filtered = stations.where((s) {
          final id = s['id'] ?? '';
          final name = s['name'] ?? '';
          return id.contains(k) || name.contains(k);
        }).toList();
      });
    }
  }

  Future<void> _loadAllStations() async {
    final List<Map<String, String>> parsed = [];
    metroDb.forEach((key, info) {
      final ids = (info['Services']?['StationIDs'] as List?)?.join('/') ?? '';
      final stationName = info['Station']?.toString() ?? key;
      final idDisplay = ids.isNotEmpty ? ids : '';
      parsed.add({'id': idDisplay, 'name': stationName});
    });

    parsed.sort((a, b) => a['name']!.compareTo(b['name']!));
    setState(() {
      stations = parsed;
      filtered = List.from(parsed);
    });
  }

  Future<void> _toggleSelect(
    String idDisplay,
    String name,
    bool selectedNow,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = (idDisplay.isNotEmpty ? '$idDisplay $name' : name);
    setState(() {
      if (selectedNow) {
        selected.add(key);
      } else {
        selected.remove(key);
      }
      prefs.setStringList('commonStations', selected.toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('選擇常用站點')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: '搜尋站名或代碼',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final s = filtered[idx];
                final idDisplay = s['id'] ?? '';
                final name = s['name'] ?? '';
                final key = (idDisplay.isNotEmpty ? '$idDisplay $name' : name);
                final isSel = selected.contains(key);
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  child: CheckboxListTile(
                    title: Text(key),
                    value: isSel,
                    onChanged: (v) =>
                        _toggleSelect(idDisplay, name, v ?? false),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
