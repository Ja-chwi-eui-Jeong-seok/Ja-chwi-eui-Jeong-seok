// test/data/datasources/category_data_source_impl_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:ja_chwi/data/datasources/category_data_source_impl.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseFirestore>(),
  MockSpec<CollectionReference>(),
  MockSpec<QuerySnapshot>(),
  MockSpec<QueryDocumentSnapshot>(),
  MockSpec<Query>(),
])
import 'category_data_source_impl_test.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCol;
  late MockQuerySnapshot mockSnap;
  late MockQueryDocumentSnapshot mockDoc;
  late CategoryDataSourceImpl dataSource;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCol = MockCollectionReference();
    mockSnap = MockQuerySnapshot();
    mockDoc = MockQueryDocumentSnapshot();
    dataSource = CategoryDataSourceImpl(mockFirestore);
  });

  test('fetchCategoryCodes', () async {
    when(
      mockFirestore.collection('categorycode'),
    ).thenReturn(mockCol as CollectionReference<Map<String, dynamic>>);
    when(
      mockCol.get(),
    ).thenAnswer((_) async => mockSnap as QuerySnapshot<Map<String, dynamic>>);
    when(mockSnap.docs).thenReturn(
      [mockDoc] as List<QueryDocumentSnapshot<Map<String, dynamic>>>,
    );
    when(mockDoc.data()).thenReturn({
      'categorycode': 1,
      'categoryname': '요리',
      'categorycreate': Timestamp.now(),
      'categoryupdate': null,
      'categorydelete': null,
      'categorydeleteyn': false,
      'categorydeletenote': '',
    });

    final res = await dataSource.fetchCategoryCodes();

    expect(res.first.categoryname, '요리');
  });
}
