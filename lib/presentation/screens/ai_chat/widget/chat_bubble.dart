import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  final bool isUser;
  final String message;
  final String time;
  final bool isFailed;

  const ChatBubble({
    super.key,
    required this.isUser,
    required this.message,
    required this.time,
    this.isFailed = false,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  late bool _isFailed;

  @override
  void initState() {
    super.initState();
    _isFailed = widget.isFailed; // 초기 상태
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI 프로필
          if (!widget.isUser) ...[
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(
                'assets/images/m_profile/m_black.png',
              ),
            ),
            const SizedBox(width: 8),
          ],

          // 말풍선 + 시간/실패 아이콘
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!widget.isUser) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(widget.message),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.time,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ] else ...[
                  if (_isFailed) ...[
                    Container(
                      padding: const EdgeInsets.all(2), // 최소 패딩
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8), // 작게
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              print('다시보내기: ${widget.message}');
                              setState(() {
                                _isFailed = false;
                              });
                            },
                            child: const Icon(
                              Icons.refresh,
                              size: 12, // 아이콘 아주 작게
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 2), // 아이콘 간격 최소화
                          GestureDetector(
                            onTap: () {
                              print('삭제: ${widget.message}');
                            },
                            child: const Icon(
                              Icons.close,
                              size: 12,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                  ] else ...[
                    Text(
                      widget.time,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(widget.message),
                  ),
                ],
              ],
            ),
          ),

          if (widget.isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/user_profile.png'),
            ),
          ],
        ],
      ),
    );
  }
}
