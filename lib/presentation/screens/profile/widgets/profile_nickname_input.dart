import 'package:flutter/material.dart';

class ProfileNicknameInput extends StatelessWidget {
  const ProfileNicknameInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(15, 10, 0, 0),
          child: Text(
            '닉네임',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          width: double.infinity,
          height: 50,
          child: TextField(
            decoration: InputDecoration(
              hintText: '집먼지의 이름을 지어주세요!',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.grey, width: 3),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.blue, width: 3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
