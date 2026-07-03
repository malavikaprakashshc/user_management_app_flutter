import 'package:dio/dio.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final Dio dio = Dio();

  String handleError(Object e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please try again.';
        case DioExceptionType.connectionError:
          return 'No internet connection. Please check your network.';
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          return 'Server error (HTTP $statusCode). Please try again later.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        default:
          return 'Network error: ${e.message}';
      }
    }
    return e.toString();
  }

  @override
  Future<List<User>> getUsers({required int limit, required int skip}) async {
    try {
      final response = await dio.get(
        'https://dummyjson.com/users',
        queryParameters: {'limit': limit, 'skip': skip},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final usersList = data['users'] as List?;
        if (usersList == null) return [];
        return usersList
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>).toEntity())
            .toList();
      }
      throw 'Unexpected response format.';
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await dio.get(
        'https://dummyjson.com/users/search',
        queryParameters: {'q': query},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final usersList = data['users'] as List?;
        if (usersList == null) return [];
        return usersList
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>).toEntity())
            .toList();
      }
      throw 'Unexpected response format.';
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<User> getUserDetails(int id) async {
    try {
      final response = await dio.get('https://dummyjson.com/users/$id');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return UserModel.fromJson(data).toEntity();
      }
      throw 'Unexpected response format.';
    } catch (e) {
      throw handleError(e);
    }
  }
}
