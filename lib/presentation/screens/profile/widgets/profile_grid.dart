import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/providers/image_provider.dart';


class ProfileGrid extends ConsumerWidget {
  const ProfileGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncImages = ref.watch(imageListProvider);

    return asyncImages.when(
      data: (images) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(15, 5, 0, 0),
            child: Text(
              '캐릭터',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 250,
            child: GridView.builder(
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final img = images[index];
                return GestureDetector(
                  onTap: () {
                    ref.read(selectedImageProvider.notifier).state = img.fullUrl;
                  },
                  child: Image.asset(img.thumbUrl, fit: BoxFit.cover),
                );
              },
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}
