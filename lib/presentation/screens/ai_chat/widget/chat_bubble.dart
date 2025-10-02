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

  Widget _buildAiBubble() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      widget.message,
      style: TextStyle(fontSize: 14),
      softWrap: true,
      overflow: TextOverflow.visible,
    ),
  );

  Widget _buildUserBubble() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(widget.message, style: const TextStyle(color: Colors.white)),
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
          onTap: () {
            widget.onRetry?.call(widget.message);
            setState(() => _isFailed = false);
          },
          child: const Icon(Icons.refresh, size: 12, color: Colors.black),
        ),
        const SizedBox(width: 2),
        GestureDetector(
          onTap: () => widget.onDelete?.call(widget.message),
          child: const Icon(Icons.close, size: 12, color: Colors.black),
        ),
      ],
    ),
  );
}
