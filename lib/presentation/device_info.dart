import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  String? deviceModel;
  String? mappedName;
  Map<String, dynamic>? deviceModelMap;

  @override
  void initState() {
    super.initState();
    _loadDeviceModelMap().then((_) => _getDeviceModel());
  }

  /// JSON 로드
  Future<void> _loadDeviceModelMap() async {
    final jsonString = await rootBundle.loadString('assets/config/device_models.json');
    setState(() {
      deviceModelMap = json.decode(jsonString);
    });
  }

  /// 디바이스 모델 가져오기
  Future<void> _getDeviceModel() async {
    final deviceInfo = DeviceInfoPlugin();

    String? model;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      model = androidInfo.model; // 예: "SM-G991B"
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      model = iosInfo.utsname.machine; // 예: "iPhone15,3"
    }

    setState(() {
      deviceModel = model;
      mappedName = deviceModelMap?[model] ?? "Unknown Device ($model)";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Device Info")),
      body: Center(
        child: (deviceModel == null || deviceModelMap == null)
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Raw Model: $deviceModel",
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  Text("Mapped Name: $mappedName",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }
}
