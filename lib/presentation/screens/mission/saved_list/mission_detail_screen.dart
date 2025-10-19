import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MissionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> missionData;

  const MissionDetailScreen({super.key, required this.missionData});

  @override
  State<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends State<MissionDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '날짜 정보 없음';
    final date = timestamp.toDate();
    return DateFormat('yyyy년 MM월 dd일').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.missionData['title'] ?? '제목 없음';
    final String description = widget.missionData['description'] ?? '내용 없음';
    final List<dynamic> photos = widget.missionData['photos'] ?? [];
    final Timestamp? completedAt = widget.missionData['missioncreatedate'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '미션 상세 보기',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사진 슬라이더
            if (photos.isNotEmpty) ...[
              SizedBox(
                height: 300,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: photos.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          photos[index] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              if (photos.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(photos.length, (index) {
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 4.0,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Colors.black
                            : Colors.grey.withOpacity(0.4),
                      ),
                    );
                  }),
                ),
            ] else
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.camera_alt, color: Colors.grey, size: 50),
                ),
              ),
            const SizedBox(height: 24),

            // 날짜
            Text(
              _formatDate(completedAt),
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),

            // 제목
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            // const SizedBox(height: 16),
            // const Divider(),
            const SizedBox(height: 16),

            // 내용
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
