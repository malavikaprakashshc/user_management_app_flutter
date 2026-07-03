import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/repositories/user_repository.dart';
import '../../../providers/repository_providers.dart';

class UserSearchState {
  final List<User> suggestions;
  final bool isLoading;
  final String query;
  final String? errorMessage;

  const UserSearchState({
    this.suggestions = const [],
    this.isLoading = false,
    this.query = '',
    this.errorMessage,
  });

  UserSearchState copyWith({
    List<User>? suggestions,
    bool? isLoading,
    String? query,
    String? errorMessage,
  }) {
    return UserSearchState(
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      errorMessage: errorMessage,
    );
  }
}

class UserSearchNotifier extends StateNotifier<UserSearchState> {
  final UserRepository userRepository;
  Timer? debounceTimer;

  UserSearchNotifier(this.userRepository) : super(const UserSearchState());

  void onQueryChanged(String query) {
    debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      state = const UserSearchState();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      query: query,
      errorMessage: null,
    );

    debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      await performSearch(query);
    });
  }

  Future<void> performSearch(String query) async {
    try {
      final results = await userRepository.searchUsers(query);
      
      if (state.query != query) return;

      state = state.copyWith(
        suggestions: results,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      if (state.query != query) return;
      state = state.copyWith(
        suggestions: [],
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void clearSearch() {
    debounceTimer?.cancel();
    state = const UserSearchState();
  }

  @override
  void dispose() {
    debounceTimer?.cancel();
    super.dispose();
  }
}

final userSearchProvider = StateNotifierProvider<UserSearchNotifier, UserSearchState>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserSearchNotifier(repository);
});
