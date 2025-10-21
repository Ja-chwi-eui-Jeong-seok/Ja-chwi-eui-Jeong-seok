import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  final bool isUser;
  final String message;
  final String time;
  final bool isFailed;
  final void Function(String)? onRetry;
  final void Function(String)? onDelete;

  const ChatBubble({
    super.key,
    required this.isUser,
    required this.message,
    required this.time,
    this.isFailed = false,
    this.onRetry,
    this.onDelete,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  late bool _isFailed;

  @override
  void initState() {
    super.initState();
    _isFailed = widget.isFailed;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.isUser)
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(
                'assets/images/m_profile/m_black.png',
              ),
            ),
          if (!widget.isUser) const SizedBox(width: 8),

          Flexible(
            fit: FlexFit.loose,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!widget.isUser) ...[
                  _buildAiBubble(),
                  const SizedBox(width: 4),
                  _buildTime(),
                ] else ...[
                  if (_isFailed)
                    _buildFailedActions()
                  else ...[
                    _buildTime(),
                    const SizedBox(width: 4),
                  ],
                  _buildUserBubble(),
                ],
              ],
            ),
          ),

          if (widget.isUser) const SizedBox(width: 8),
          if (widget.isUser)
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(
                'assets/images/m_profile/m_black.png',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAiBubble() => ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width * 0.55,
    ),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.message,
        style: const TextStyle(fontSize: 14),
        softWrap: true,
        maxLines: null,
        overflow: TextOverflow.clip,
      ),
    ),
  );

  Widget _buildUserBubble() => ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width * 0.55,
    ),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.message,
        style: const TextStyle(color: Colors.white),
        softWrap: true,
        maxLines: null,
        overflow: TextOverflow.clip,
      ),
    ),
  );

  Widget _buildTime() => Text(
    widget.time,
    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
  );

  Widget _buildFailedActions() => Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey, width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _showConfirmDialog(
            context,
            title: '다시 보내시겠습니까?',
            onConfirm: () {
              widget.onRetry?.call(widget.message);
              setState(() => _isFailed = false);
            },
          ),
          child: const Icon(Icons.refresh, size: 12, color: Colors.black),
        ),
        const SizedBox(width: 2),
        GestureDetector(
          onTap: () => _showConfirmDialog(
            context,
            title: '정말 삭제하시겠습니까?',
            onConfirm: () => widget.onDelete?.call(widget.message),
          ),
          child: const Icon(Icons.close, size: 12, color: Colors.black),
        ),
      ],
    ),
  );

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          // 취소 버튼: 알약 테두리
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                '취소',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 확인 버튼: 배경색 채운 알약
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                '확인',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
