import 'package:flutter/material.dart';
import 'package:ja_chwi/core/config/router/route_titles.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Widget? leading;

  const CommonAppBar({super.key, this.actions, this.leading});

  @override
  Widget build(BuildContext context) {
    final title = RouteTitles.of(context);
    return AppBar(
      title: Text(title),
      //centerTitle: true,
      actions: actions,
      leading: leading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// 뒤로가기버튼 추가
// Scaffold(
//   appBar: CommonAppBar(
//     leading: IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: () => Navigator.of(context).pop(),
//     ),
//   ),
//   body: ...
// )

// 오른쪽 액션버튼 추가
// Scaffold(
//   appBar: CommonAppBar(
//     actions: [
//       IconButton(
//         icon: const Icon(Icons.add),
//         onPressed: () { /* TODO */ },
//       ),
//     ],
//   ),
//   body: ...
// )
