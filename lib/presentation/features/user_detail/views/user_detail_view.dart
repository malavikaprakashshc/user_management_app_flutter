import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../user_list/widgets/error_view.dart';
import '../providers/user_detail_provider.dart';
import '../../../../domain/entities/user.dart';

class UserDetailView extends ConsumerWidget {
  final int userId;

  const UserDetailView({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(userDetailProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: detailState.when(
        data: (user) => buildDetailContent(context, user),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.read(userDetailProvider(userId).notifier).loadDetails(),
        ),
      ),
    );
  }

  Widget buildDetailContent(BuildContext context, User user) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(64),
                    child: CachedNetworkImage(
                      imageUrl: user.image,
                      width: 128,
                      height: 128,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const SizedBox(
                        width: 128,
                        height: 128,
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 128,
                        height: 128,
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.person,
                          color: theme.colorScheme.primary,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  user.fullName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  '@${user.username} • ${user.age} yrs',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                buildInfoSection(
                  context,
                  title: 'Other Information',
                  icon: Icons.contact_mail_outlined,
                  items: [
                    buildInfoRow(context, Icons.email_outlined, 'Email', user.email),
                    buildInfoRow(context, Icons.phone_outlined, 'Phone', user.phone),
                    buildInfoRow(context, Icons.map_outlined, 'Address', user.address.address),
                    buildInfoRow(context, Icons.business_outlined, 'Company', user.company.name),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? 'N/A' : value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
