import '../entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getUsers({required int limit, required int skip});
  Future<List<User>> searchUsers(String query);
  Future<User> getUserDetails(int id);
}
