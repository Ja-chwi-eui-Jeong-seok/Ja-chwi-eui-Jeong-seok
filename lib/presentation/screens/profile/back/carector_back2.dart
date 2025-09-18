// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ja_chwi/presentation/providers/image_provider.dart';
// import 'package:ja_chwi/presentation/screens/profile/widgets/image_grid_item.dart';


// // 상단 선택 이미지 상태
// final selectedImageProvider = StateProvider<String?>((ref) => null);

// class ProfileScreen extends ConsumerWidget{
//   const ProfileScreen ({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//      final asyncImages = ref.watch(imageListProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Image List')),
//       body: asyncImages.when(
//         data: (images) => GridView.builder(
//           padding: const EdgeInsets.all(25),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 4, // 2열
//             crossAxisSpacing: 8,
//             mainAxisSpacing: 8,
//           ),
//           itemCount: images.length,
//           itemBuilder: (context, index) {
//             final img = images[index];
//             return ImageGridItem(
//               image: img,
//               onTap: () {
//                 showDialog(
//                   context: context,
//                   builder: (_) => Dialog(
//                     child: Image.asset(img.fullUrl, fit: BoxFit.contain),
//                     //Image.network() 는 인터넷 URL 전용
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, _) => Center(child: Text('Error: $err')),
//       ),
//     );
//   }
// }
