import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/providers/profile_providers.dart';

class ProfileGrid extends ConsumerWidget {
  const ProfileGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(profileImagesProvider);
    final selectedImage = ref.watch(selectedImageProvider);

    return imagesAsync.when(
      data: (images) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: images.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final img = images[index];
          final isSelected = selectedImage?.id == img.id;

          return GestureDetector(
            onTap: () => ref.read(selectedImageProvider.notifier).state = img,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(img.thumbUrl),
            ),
          );
        },
      ),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text("Error: $e"),
    );
  }
}