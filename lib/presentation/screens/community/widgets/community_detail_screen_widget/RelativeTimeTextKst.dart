import 'dart:async';

import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

final tz.Location _seoul = tz.getLocation('Asia/Seoul');

/// KST 기준 “방금 전 / N분 전 / …” (1분마다 자동 갱신)
class RelativeTimeTextKst extends StatefulWidget {
  final DateTime createdAtUtc; // UTC 전제
  final TextStyle? style;
  const RelativeTimeTextKst({
    super.key,
    required this.createdAtUtc,
    this.style,
  });

  @override
  State<RelativeTimeTextKst> createState() => RelativeTimeTextKstState();
}

/// KST 기준 “방금 전 / N분 전 / …” (1분마다 자동 갱신)
class RelativeTimeTextKstState extends State<RelativeTimeTextKst> {
  Timer? _t;
  String _text = '';

  String _format() {
    final nowKst = tz.TZDateTime.from(DateTime.now().toUtc(), _seoul);
    final kst = tz.TZDateTime.from(widget.createdAtUtc, _seoul);
    var diff = nowKst.difference(kst);
    if (diff.isNegative) diff = Duration.zero;

    if (diff.inSeconds < 5) return '방금 전';
    if (diff.inSeconds < 60) return '${diff.inSeconds}초 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    final w = (diff.inDays / 7).floor();
    if (diff.inDays < 30) return '${w}주 전';
    final m = (diff.inDays / 30).floor();
    if (diff.inDays < 365) return '${m}개월 전';
    return '${(diff.inDays / 365).floor()}년 전';
  }

  void _tick() {
    _text = _format();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tick();
    _t = Timer.periodic(const Duration(minutes: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(_text, style: widget.style);
}
