import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/experience.dart';
import '../../../../domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../marketplace/presentation/widgets/experience_card.dart';
import '../../../marketplace/presentation/pages/experience_detail_page.dart';

/// Profile Page
/// 
/// Профиль пользователя с его микроопытами, статистикой и настройками
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _editProfile() {
    // Navigate to edit profile
  }

  void _showSettings() {
    // Show settings
  }

  void _shareProfile() {
    // Share profile
  }

  void _onExperienceTap(Experience experience) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExperienceDetailPage(experience: experience),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;

        return Scaffold(
          backgroundColor: AppTheme.backgroundDark,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // App bar
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: AppTheme.backgroundDark,
                  elevation: 0,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: _shareProfile,
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: _showSettings,
                    ),
                  ],
                ),

                // Profile header
                SliverToBoxAdapter(
                  child: _ProfileHeader(
                    user: user,
                    onEdit: _editProfile,
                  ),
                ),

                // Stats
                SliverToBoxAdapter(
                  child: _ProfileStats(user: user),
                ),

                // Tab bar
                SliverPersistentHeader(
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppTheme.primaryColor,
                      indicatorWeight: 3,
                      labelColor: AppTheme.primaryColor,
                      unselectedLabelColor: AppTheme.textSecondaryDark,
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: const [
                        Tab(text: 'My Experiences'),
                        Tab(text: 'Purchased'),
                        Tab(text: 'Liked'),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _MyExperiencesList(onTap: _onExperienceTap),
                _PurchasedList(onTap: _onExperienceTap),
                _LikedList(onTap: _onExperienceTap),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Profile Header
class _ProfileHeader extends StatelessWidget {
  final User user;
  final VoidCallback onEdit;

  const _ProfileHeader({required this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppTheme.primaryGradient,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor,
                    width: 3,
                  ),
                ),
                child: user.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          user.avatarUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.backgroundDark,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            user.displayNameOrUsername,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (user.username != null) ...[
            const SizedBox(height: 4),
            Text(
              '@${user.username}',
              style: TextStyle(
                color: AppTheme.textSecondaryDark,
                fontSize: 16,
              ),
            ),
          ],

          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              user.bio!,
              style: TextStyle(
                color: AppTheme.textSecondaryDark,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 16),

          // Referral code
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.textTertiaryDark.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.card_giftcard,
                  size: 16,
                  color: AppTheme.accentOrange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ref: ${user.referralCode}',
                  style: TextStyle(
                    color: AppTheme.textSecondaryDark,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Copy referral code
                    showSuccessSnackbar(context, 'Copied!');
                  },
                  child: Icon(
                    Icons.copy,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile Stats
class _ProfileStats extends StatelessWidget {
  final User user;

  const _ProfileStats({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatColumn(
              value: '12',
              label: 'Created',
            ),
            _StatDivider(),
            _StatColumn(
              value: '45',
              label: 'Sold',
            ),
            _StatDivider(),
            _StatColumn(
              value: '\$450',
              label: 'Earned',
            ),
            _StatDivider(),
            _StatColumn(
              value: '128',
              label: 'Followers',
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat Column
class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textPrimaryDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondaryDark,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

/// Stat Divider
class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppTheme.textTertiaryDark.withOpacity(0.2),
    );
  }
}

/// My Experiences List
class _MyExperiencesList extends StatelessWidget {
  final Function(Experience) onTap;

  const _MyExperiencesList({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final experiences = [
      Experience(
        id: '1',
        creatorId: 'user1',
        type: ExperienceType.art,
        title: 'Cyberpunk City',
        description: 'A futuristic cityscape',
        contentUrl: '',
        price: 2.99,
        currency: Currency.usd,
        status: ExperienceStatus.active,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 20)),
        salesCount: 15,
        viewsCount: 234,
        likesCount: 45,
        tags: ['cyberpunk', 'art'],
      ),
      Experience(
        id: '2',
        creatorId: 'user1',
        type: ExperienceType.text,
        title: 'The Last AI',
        description: 'A sci-fi story',
        contentUrl: '',
        price: 1.99,
        currency: Currency.usd,
        status: ExperienceStatus.active,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 15)),
        salesCount: 8,
        viewsCount: 156,
        likesCount: 23,
        tags: ['story', 'sci-fi'],
      ),
    ];

    if (experiences.isEmpty) {
      return _EmptyState(
        icon: Icons.create,
        title: 'No experiences yet',
        subtitle: 'Create your first micro-experience!',
        actionLabel: 'Create',
        onAction: () {},
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: experiences.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ExperienceCard(
            experience: experiences[index],
            onTap: () => onTap(experiences[index]),
          ),
        );
      },
    );
  }
}

/// Purchased List
class _PurchasedList extends StatelessWidget {
  final Function(Experience) onTap;

  const _PurchasedList({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final experiences = [
      Experience(
        id: '3',
        creatorId: 'user2',
        type: ExperienceType.audio,
        title: 'Lo-Fi Study Beats',
        description: 'Relaxing music',
        contentUrl: '',
        price: 3.99,
        currency: Currency.usd,
        status: ExperienceStatus.active,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 10)),
        salesCount: 100,
        viewsCount: 500,
        likesCount: 80,
        tags: ['music', 'lo-fi'],
      ),
    ];

    if (experiences.isEmpty) {
      return _EmptyState(
        icon: Icons.shopping_bag,
        title: 'No purchases yet',
        subtitle: 'Explore the marketplace to find amazing experiences!',
        actionLabel: 'Explore',
        onAction: () {},
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: experiences.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ExperienceCard(
            experience: experiences[index],
            onTap: () => onTap(experiences[index]),
          ),
        );
      },
    );
  }
}

/// Liked List
class _LikedList extends StatelessWidget {
  final Function(Experience) onTap;

  const _LikedList({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _EmptyState(
      icon: Icons.favorite,
      title: 'No likes yet',
      subtitle: 'Like experiences to save them here!',
      actionLabel: 'Discover',
      onAction: () {},
    );
  }
}

/// Empty State
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.textTertiaryDark,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.textPrimaryDark,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: AppTheme.textSecondaryDark,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sliver Tab Bar Delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppTheme.backgroundDark,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
