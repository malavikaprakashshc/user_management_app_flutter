import 'package:abeltech_machine_test/presentation/features/user_detail/views/user_detail_view.dart';
import 'package:abeltech_machine_test/presentation/features/user_list/providers/user_list_provider.dart';
import 'package:abeltech_machine_test/presentation/features/user_list/providers/user_search_provider.dart';
import 'package:abeltech_machine_test/presentation/features/user_list/widgets/error_view.dart';
import 'package:abeltech_machine_test/presentation/features/user_list/widgets/user_card.dart';
import 'package:abeltech_machine_test/presentation/features/user_list/widgets/user_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserListView extends ConsumerStatefulWidget {
  const UserListView({super.key});

  @override
  ConsumerState<UserListView> createState() => UserListViewState();
}

class UserListViewState extends ConsumerState<UserListView> {
  final FocusNode searchFocusNode = FocusNode();
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(onScroll);
    scrollController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void onScroll() {
    if (scrollController.hasClients) {
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;
      if (maxScroll - currentScroll <= 300) {
        ref.read(userListProvider.notifier).loadNextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userListState = ref.watch(userListProvider);
    final searchState = ref.watch(userSearchProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('User List')),
      body: GestureDetector(
        onTap: () => searchFocusNode.unfocus(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Type name of the user to find...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();
                            ref.read(userSearchProvider.notifier).clearSearch();
                            searchFocusNode.unfocus();
                          },
                          icon: const Icon(Icons.search_rounded),
                        )
                      : null,
                ),
                onChanged: (value) {
                  ref.read(userSearchProvider.notifier).onQueryChanged(value);
                  setState(() {});
                },
              ),
            ),
            Expanded(
              child: searchController.text.trim().isNotEmpty
                  ? buildSearchResults(searchState)
                  : buildPaginatedList(userListState),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchResults(UserSearchState searchState) {
    final theme = Theme.of(context);

    if (searchState.isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => const UserShimmer(),
      );
    }

    if (searchState.errorMessage != null) {
      return ErrorView(
        message: searchState.errorMessage!,
        onRetry: () {
          ref
              .read(userSearchProvider.notifier)
              .onQueryChanged(searchController.text);
        },
      );
    }

    if (searchState.suggestions.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Results Found',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We couldn\'t find any users matching "${searchState.query}"',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: searchState.suggestions.length,
      itemBuilder: (context, index) {
        final user = searchState.suggestions[index];
        return UserCard(
          user: user,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserDetailView(userId: user.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildPaginatedList(UserListState userListState) {
    if (userListState.users.isEmpty && userListState.isLoading) {
      return ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) => const UserShimmer(),
      );
    }

    if (userListState.users.isEmpty && userListState.errorMessage != null) {
      return ErrorView(
        message: userListState.errorMessage!,
        onRetry: () => ref.read(userListProvider.notifier).loadNextPage(),
      );
    }

    if (userListState.users.isEmpty) {
      return const Center(
        child: Text('No users found in directory.'),
      );
    }

    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: userListState.users.length + (userListState.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < userListState.users.length) {
          final user = userListState.users[index];
          return UserCard(
            user: user,
            onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserDetailView(userId: user.id),
              ),
            );
          },
          );
        } else {
          if (userListState.errorMessage != null) {
            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Failed to load next page: ${userListState.errorMessage}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.read(userListProvider.notifier).loadNextPage(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        }
      },
    );
  }
}
