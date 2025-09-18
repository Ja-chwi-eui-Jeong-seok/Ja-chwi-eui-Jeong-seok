// import 'package:flutter/material.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('ProfileScreen')),
//       body: SingleChildScrollView(
//         child: Column(
//         children: [
//             SizedBox(
//               height: 380,
//               child: Container(color: Colors.orange),
//             ), 
//             Container(              
//               padding: EdgeInsets.fromLTRB(15,10,0,0),       // 안쪽 여백
//               width: double.infinity,
//               child: Text(
//                 '닉네임',
//                 style: TextStyle(
//                   color: Colors.black, fontSize: 17,
//                   fontWeight:FontWeight.bold 
//                  ),
//               ), 
//             ), 
//             Container(              
//               margin: EdgeInsets.fromLTRB(20,10,20,20),          // 외부 여백
//               width: double.infinity,
//               height: 50,
//               child:  TextField(
//                 decoration: InputDecoration(
//                   hintText: '집먼지의 이름을 지어주세요!',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide(
//                       color: Colors.grey, // 테두리 색상
//                       width: 3,           // 테두리 두께
//                     ),
//                   ),
//                 ),
//               ),
//             ),   
//             Container(              
//               padding: EdgeInsets.fromLTRB(15,5,0,0),       // 안쪽 여백
//               width: double.infinity,
//               child: Text(
//                 '캐릭터',
//                 style: TextStyle(
//                   color: Colors.black, fontSize: 17,
//                   fontWeight:FontWeight.bold 
//                  ),
//               ), 
//             ),           
//            Container(
//               height: 300, // 필수: 높이 지정
//               padding: EdgeInsets.all(8),
//               child: GridView.builder(
//                 itemCount: 8,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 4,
//                   mainAxisSpacing: 8,
//                   crossAxisSpacing: 8,
//                   childAspectRatio: 1,
//                 ),
//                 itemBuilder: (context, index) {
//                   return Container(
//                     color: Colors.blue[(index + 1) * 100],
//                   );
//                 },
//               ),
//             )         
//          ],
//         )
//       ),  
//         bottomNavigationBar: Container(
//         height: 80,
//         color: Colors.blue,
//         child:  Center(),
//       ),
//     );
//   }
// }
