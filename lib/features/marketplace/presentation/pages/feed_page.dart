import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/experience.dart';
import '../widgets/experience_card.dart';
import 'experience_detail_page.dart';

/// Feed Page
/// 
/// Главная лента микроопытов с фильтрами
/// Показывает: Тренды, Новые, Скоро истекают
class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // App Bar with search
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: AppTheme.backgroundDark,
                elevation: 0,
                title: _isSearching
                    ? TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: TextStyle(color: AppTheme.textPrimaryDark),
                        decoration: InputDecoration(
                          hintText: 'Search experiences...',
                          hintStyle: TextStyle(
                            color: AppTheme.textTertiaryDark,
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: AppTheme.textTertiaryDark,
                            ),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _isSearching = false;
                              });
                            },
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppTheme.primaryGradient,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'MEE',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Discover',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppTheme.textPrimaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isSearching ? Icons.close : Icons.search,
                      color: AppTheme.textPrimaryDark,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: AppTheme.textPrimaryDark,
                    ),
                    onPressed: () {
                      // Show notifications
                    },
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.primaryColor,
                  indicatorWeight: 3,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.textSecondaryDark,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  tabs: const [
                    Tab(text: 'Trending'),
                    Tab(text: 'New'),
                    Tab(text: 'Expiring'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // Trending tab
              _ExperienceList(
                filter: 'trending',
                onExperienceTap: _onExperienceTap,
              ),
              // New tab
              _ExperienceList(
                filter: 'new',
                onExperienceTap: _onExperienceTap,
              ),
              // Expiring tab
              _ExperienceList(
                filter: 'expiring',
                onExperienceTap: _onExperienceTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Experience List Widget
class _ExperienceList extends StatelessWidget {
  final String filter;
  final Function(Experience) onExperienceTap;

  const _ExperienceList({
    required this.filter,
    required this.onExperienceTap,
  });

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final experiences = _getMockExperiences();

    if (experiences.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 64,
              color: AppTheme.textTertiaryDark,
            ),
            const SizedBox(height: 16),
            Text(
              'No experiences yet',
              style: TextStyle(
                color: AppTheme.textSecondaryDark,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh data
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppTheme.primaryColor,
      backgroundColor: AppTheme.surfaceDark,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: experiences.length,
        itemBuilder: (context, index) {
          final experience = experiences[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ExperienceCard(
              experience: experience,
              onTap: () => onExperienceTap(experience),
            ),
          );
        },
      ),
    );
  }

  List<Experience> _getMockExperiences() {
    return [
      Experience(
        id: '1',
        creatorId: 'user1',
        type: ExperienceType.art,
        title: 'Cyberpunk City at Night',
        description: 'A stunning AI-generated cyberpunk cityscape with neon lights',
        aiPrompt: 'Cyberpunk city at night with neon lights, rain, futuristic',
        contentUrl: 'https://example.com/image1.jpg',
        thumbnailUrl: 'https://example.com/thumb1.jpg',
        price: 2.99,
        currency: Currency.usd,
        status: ExperienceStatus.active,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().add(const Duration(hours: 22)),
        salesCount: 15,
        viewsCount: 234,
        likesCount: 45,
        tags: ['cyberpunk', 'art', 'neon', 'futuristic'],
      ),
      Experience(
        id: '2',
        creatorId: 'user2',
        type: ExperienceType.text,
        title: 'The Last AI: A Sci-Fi Story',
        description: 'An engaging short story about the last artificial intelligence',
        aiPrompt: 'Write a sci-fi story about the last AI on Earth',
        contentUrl: 'https://example.com/story1.txt',
        price: 1.99,
        currency: Currency.usd,
        status: ExperienceStatus.active,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        expiresAt: DateTime.now().add(const Duration(hours: 19)),
        salesCount: 8,
        viewsCount: 156,
        likesCount: 23,
        tags: ['story', 'sci-fi', 'ai', 'fiction'],
      ),
      Experience(
        id: '3',
        creatorId: 'user3',
        type: ExperienceType.audio,
        title: 'Lo-Fi Study Beats',
        description: 'Relaxing lo-fi beats perfect for studying',
        aiPrompt: 'Create lo-fi hip hop beats for studying',
        contentUrl: 'https://example.com/audio1.mp3',
        thumbnailUrl: 'https://example.com/thumb3.jpg',
        price: 3.99,
        currency: Currency.usd,
        status: ExperienceStatus.active,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        expiresAt: DateTime.now().add(const Duration(hours: 23, minutes: 30)),
        salesCount: 3,
        viewsCount: 89,
        likesCount: 12,
        tags: ['music', 'lo-fi', 'study', 'relax'],
      ),
      Experience(
        id: '4',
        creatorId: 'user4',
        type: ExperienceType.miniGame,
        title: 'Neon Puzzle Challenge',
        description: 'A fast-paced puzzle game with neon aesthetics',
        aiPrompt: 'Create a puzzle game concept with neon theme',
        contentUrl: 'https://example.com/game1.json',
        thumbnailUrl: 'https://example.com/thumb4.jpg',
        price: 0.99,
        currency: Currency.usd,
        status: ExperienceStatus.active,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        expiresAt: DateTime.now().add(const Duration(hours: 23)),
        salesCount: 25,
        viewsCount: 412,
        likesCount: 67,
        tags: ['game', 'puzzle', 'neon', 'fun'],
      ),
    ];
  }
}
