import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/screens/mission/core/model/mission_achiever.dart';

/// 미션 랭킹 등에서 사용자 프로필을 표시하는 공통 위젯
class AchieverProfileTile extends StatelessWidget {
  final MissionAchiever achiever;
  final Widget? leading;
  final Widget? trailing;

  const AchieverProfileTile({
    super.key,
    required this.achiever,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 8),
        ],
        SizedBox(
          width: 48,
          height: 48,
          child: ClipOval(
            child: Image(
              image:
                  (achiever.imageFullUrl.startsWith('http')
                          ? NetworkImage(achiever.imageFullUrl)
                          : AssetImage(achiever.imageFullUrl))
                      as ImageProvider,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.person, size: 30),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                achiever.level,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                achiever.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ] else
          Text(
            '${achiever.weekCount}회',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}
