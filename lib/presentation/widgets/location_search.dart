import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class LocationSearchPage extends StatefulWidget {
  const LocationSearchPage({super.key});

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  List<Map<String, dynamic>> locations = [];
  List<Map<String, dynamic>> filteredLocations = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final jsonStr = await rootBundle.loadString('assets/config/json/sido.json');
    final List<dynamic> jsonList = json.decode(jsonStr);
    setState(() {
      locations = jsonList.cast<Map<String, dynamic>>();
      filteredLocations = List.from(locations);
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value.trim();
      filteredLocations = locations.where((e) =>
          e['sido'].toString().contains(searchQuery) ||
          e['sigun'].toString().contains(searchQuery)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("동 선택")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "지역 검색 (시도/시군)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: filteredLocations.isEmpty
                ? const Center(child: Text("검색 결과가 없습니다"))
                : ListView.builder(
                    itemCount: filteredLocations.length,
                    itemBuilder: (_, index) {
                      final loc = filteredLocations[index];
                      return ListTile(
                        title: Text("${loc['sido']} ${loc['sigun']}"),
                        onTap: () => context.pop(loc),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
