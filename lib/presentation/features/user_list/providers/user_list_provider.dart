import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/repositories/user_repository.dart';
import '../../../providers/repository_providers.dart';

class UserListState {
  final List<User> users;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final int skip;

  const UserListState({
    this.users = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.skip = 0,
  });

  UserListState copyWith({
    List<User>? users,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    int? skip,
  }) {
    return UserListState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      skip: skip ?? this.skip,
    );
  }

  UserListState copyWithNoError({
    List<User>? users,
    bool? isLoading,
    bool? hasMore,
    int? skip,
  }) {
    return UserListState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: null,
      skip: skip ?? this.skip,
    );
  }
}

class UserListNotifier extends StateNotifier<UserListState> {
  final UserRepository userRepository;
  static const int limit = 20;

  UserListNotifier(this.userRepository) : super(const UserListState()) {
    loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final newUsers = await userRepository.getUsers(
        limit: limit,
        skip: state.skip,
      );

      final hasMore = newUsers.length >= limit;

      state = state.copyWithNoError(
        users: [...state.users, ...newUsers],
        isLoading: false,
        hasMore: hasMore,
        skip: state.skip + newUsers.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = const UserListState();
    await loadNextPage();
  }
}

final userListProvider = StateNotifierProvider<UserListNotifier, UserListState>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserListNotifier(repository);
});
