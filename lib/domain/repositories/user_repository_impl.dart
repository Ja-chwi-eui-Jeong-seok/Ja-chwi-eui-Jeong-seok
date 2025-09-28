import 'package:ja_chwi/data/datasources/user_datasource.dart';
import 'package:ja_chwi/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource dataSource;

  UserRepositoryImpl(this.dataSource);

  @override
  Future<Map<String, dynamic>> fetchUserProfile(String userId) {
    return dataSource.fetchUserProfile(userId);
  }

  @override
  Stream<Map<String, dynamic>> fetchUserProfileStream(String userId) {
    return dataSource.fetchUserProfileStream(userId);
  }
}
