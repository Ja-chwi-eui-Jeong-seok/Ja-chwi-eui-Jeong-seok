import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> fetchHousesBySidoSigun({
  required String sido,
  required String sigun,
}) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('houses')
      .where('sido', isEqualTo: sido)
      .where('sigun', isEqualTo: sigun)
      .get();

  return snapshot.docs.map((doc) => doc.data()).toList();
}
