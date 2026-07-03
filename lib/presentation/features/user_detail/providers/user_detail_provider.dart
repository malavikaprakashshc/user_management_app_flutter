import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/repositories/user_repository.dart';
import '../../../providers/repository_providers.dart';

class UserDetailNotifier extends StateNotifier<AsyncValue<User>> {
  final UserRepository userRepository;
  final int userId;

  UserDetailNotifier(this.userRepository, this.userId) : super(const AsyncValue.loading()) {
    loadDetails();
  }

  Future<void> loadDetails() async {
    state = const AsyncValue.loading();
    try {
      final user = await userRepository.getUserDetails(userId);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final userDetailProvider = StateNotifierProvider.family.autoDispose<UserDetailNotifier, AsyncValue<User>, int>((ref, userId) {
  final repository = ref.watch(userRepositoryProvider);
  return UserDetailNotifier(repository, userId);
});
