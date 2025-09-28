import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationAutocompleteWidget extends StatefulWidget {
  const LocationAutocompleteWidget({super.key});

  @override
  State<LocationAutocompleteWidget> createState() =>
      _LocationAutocompleteWidgetState();
}

class _LocationAutocompleteWidgetState
    extends State<LocationAutocompleteWidget> {
  List<Map<String, String>> locationList = [];
  String? selectedSido;
  String? selectedSigun;

  List<Map<String, dynamic>> results = [];
  String? errorText;

  @override
  void initState() {
    super.initState();
    _loadSidoJson();
  }

  Future<void> _loadSidoJson() async {
    final jsonString =
        await rootBundle.loadString('assets/config/sido.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    setState(() {
      locationList = List<Map<String, String>>.from(jsonList);
    });
  }

  List<String> getSidoSuggestions(String pattern) {
    return locationList
        .map((e) => e['sido']!)
        .where((sido) => sido.contains(pattern))
        .toSet()
        .toList();
  }

  List<String> getSigunSuggestions(String pattern) {
    if (selectedSido == null) return [];
    return locationList
        .where((e) => e['sido'] == selectedSido)
        .map((e) => e['sigun']!)
        .where((sigun) => sigun.contains(pattern))
        .toList();
  }

  Future<void> _search() async {
    if (selectedSido == null || selectedSigun == null) {
      setState(() {
        errorText = "시도와 시군/구를 선택해주세요";
        results = [];
      });
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('houses')
        .where('sido', isEqualTo: selectedSido)
        .where('sigun', isEqualTo: selectedSigun)
        .get();

    setState(() {
      results = snapshot.docs.map((doc) => doc.data()).toList();
      errorText = results.isEmpty ? "조회 결과가 없습니다" : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 시도 Autocomplete
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
            return getSidoSuggestions(textEditingValue.text);
          },
          onSelected: (selection) {
            setState(() {
              selectedSido = selection;
              selectedSigun = null;
            });
          },
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(labelText: "시도 선택"),
            );
          },
        ),
        const SizedBox(height: 12),

        // 시군/구 Autocomplete
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
            return getSigunSuggestions(textEditingValue.text);
          },
          onSelected: (selection) {
            setState(() {
              selectedSigun = selection;
            });
          },
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(labelText: "시군/구 선택"),
            );
          },
        ),

        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _search,
          child: const Text("검색"),
        ),

        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(errorText!, style: const TextStyle(color: Colors.red)),
          ),

        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final item = results[index];
              return ListTile(
                title: Text(item['name'] ?? "이름 없음"),
                subtitle: Text("${item['sido']} ${item['sigun']}"),
              );
            },
          ),
        ),
      ],
    );
  }
}
