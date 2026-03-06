import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/experience.dart';

/// Creator Studio Page
/// 
/// Интерфейс для создания микроопытов с помощью AI
/// Поддерживает генерацию арта, текста, аудио и мини-игр
class CreatorStudioPage extends StatefulWidget {
  const CreatorStudioPage({super.key});

  @override
  State<CreatorStudioPage> createState() => _CreatorStudioPageState();
}

class _CreatorStudioPageState extends State<CreatorStudioPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _promptController = TextEditingController();
  bool _isGenerating = false;
  int _dailyGenerationsLeft = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  void _generate() async {
    if (_promptController.text.isEmpty) return;

    setState(() => _isGenerating = true);

    // Simulate generation
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isGenerating = false;
        _dailyGenerationsLeft--;
      });

      // Show result
      _showGenerationResult();
    }
  }

  void _showGenerationResult() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GenerationResultSheet(
        onPublish: () {
          Navigator.pop(context);
          _showPublishDialog();
        },
        onRegenerate: () {
          Navigator.pop(context);
          _generate();
        },
      ),
    );
  }

  void _showPublishDialog() {
    showDialog(
      context: context,
      builder: (context) => _PublishDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Creator Studio',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Daily generations indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _dailyGenerationsLeft > 0
                          ? AppTheme.success.withOpacity(0.2)
                          : AppTheme.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt,
                          size: 16,
                          color: _dailyGenerationsLeft > 0
                              ? AppTheme.success
                              : AppTheme.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_dailyGenerationsLeft left today',
                          style: TextStyle(
                            color: _dailyGenerationsLeft > 0
                                ? AppTheme.success
                                : AppTheme.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Type selector tabs
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textSecondaryDark,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: const [
                Tab(
                  icon: Icon(Icons.image),
                  text: 'AI Art',
                ),
                Tab(
                  icon: Icon(Icons.article),
                  text: 'Story',
                ),
                Tab(
                  icon: Icon(Icons.music_note),
                  text: 'Music',
                ),
                Tab(
                  icon: Icon(Icons.gamepad),
                  text: 'Game',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTypeTab(ExperienceType.art),
                  _buildTypeTab(ExperienceType.text),
                  _buildTypeTab(ExperienceType.audio),
                  _buildTypeTab(ExperienceType.miniGame),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTab(ExperienceType type) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prompt section
          Text(
            'Describe what you want to create',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.textTertiaryDark.withOpacity(0.2),
              ),
            ),
            child: TextField(
              controller: _promptController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: type.suggestedPrompts.first,
                hintStyle: TextStyle(
                  color: AppTheme.textTertiaryDark,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Style/Options section (type-specific)
          _buildOptionsSection(type),

          const SizedBox(height: 24),

          // Suggested prompts
          Text(
            'Suggested prompts',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: type.suggestedPrompts.map((prompt) {
              return ActionChip(
                label: Text(
                  prompt,
                  style: TextStyle(
                    color: AppTheme.textSecondaryDark,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: AppTheme.surfaceDark,
                side: BorderSide(
                  color: AppTheme.textTertiaryDark.withOpacity(0.2),
                ),
                onPressed: () {
                  setState(() {
                    _promptController.text = prompt;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Generate button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _dailyGenerationsLeft > 0 && !_isGenerating
                  ? _generate
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                disabledBackgroundColor: AppTheme.textTertiaryDark,
              ),
              child: _isGenerating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Generating...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_fix_high),
                        const SizedBox(width: 8),
                        const Text(
                          'Generate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Upgrade prompt
          if (_dailyGenerationsLeft == 0)
            Center(
              child: TextButton(
                onPressed: () {
                  // Show upgrade dialog
                },
                child: Text(
                  'Upgrade to Pro for 50 generations/day',
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection(ExperienceType type) {
    switch (type) {
      case ExperienceType.art:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Style',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StyleChip(label: 'Photorealistic', selected: true),
                  _StyleChip(label: 'Digital Art'),
                  _StyleChip(label: 'Anime'),
                  _StyleChip(label: 'Oil Painting'),
                  _StyleChip(label: 'Cyberpunk'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aspect Ratio',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _AspectChip(label: '1:1', selected: true),
                  _AspectChip(label: '16:9'),
                  _AspectChip(label: '9:16'),
                  _AspectChip(label: '4:3'),
                ],
              ),
            ),
          ],
        );

      case ExperienceType.text:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StyleChip(label: 'Story', selected: true),
                  _StyleChip(label: 'Poem'),
                  _StyleChip(label: 'Script'),
                  _StyleChip(label: 'Dialogue'),
                ],
              ),
            ),
          ],
        );

      case ExperienceType.audio:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genre',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StyleChip(label: 'Lo-Fi', selected: true),
                  _StyleChip(label: 'Electronic'),
                  _StyleChip(label: 'Ambient'),
                  _StyleChip(label: 'Rock'),
                ],
              ),
            ),
          ],
        );

      case ExperienceType.miniGame:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Game Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StyleChip(label: 'Puzzle', selected: true),
                  _StyleChip(label: 'Quiz'),
                  _StyleChip(label: 'Memory'),
                  _StyleChip(label: 'Runner'),
                ],
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

/// Style Chip
class _StyleChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _StyleChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        backgroundColor: AppTheme.surfaceDark,
        labelStyle: TextStyle(
          color: selected ? AppTheme.primaryColor : AppTheme.textSecondaryDark,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: selected
              ? AppTheme.primaryColor
              : AppTheme.textTertiaryDark.withOpacity(0.2),
        ),
        onSelected: (_) {},
      ),
    );
  }
}

/// Aspect Chip
class _AspectChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _AspectChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppTheme.secondaryColor.withOpacity(0.2),
        backgroundColor: AppTheme.surfaceDark,
        labelStyle: TextStyle(
          color:
              selected ? AppTheme.secondaryColor : AppTheme.textSecondaryDark,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: selected
              ? AppTheme.secondaryColor
              : AppTheme.textTertiaryDark.withOpacity(0.2),
        ),
        onSelected: (_) {},
      ),
    );
  }
}

/// Generation Result Sheet
class _GenerationResultSheet extends StatelessWidget {
  final VoidCallback onPublish;
  final VoidCallback onRegenerate;

  const _GenerationResultSheet({
    required this.onPublish,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textTertiaryDark.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Icon(
            Icons.check_circle,
            size: 64,
            color: AppTheme.success,
          ),
          const SizedBox(height: 16),
          Text(
            'Generation Complete!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your content is ready to publish',
            style: TextStyle(
              color: AppTheme.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 24),
          // Preview placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.backgroundDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.textTertiaryDark.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image,
                    size: 48,
                    color: AppTheme.textTertiaryDark,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preview',
                    style: TextStyle(
                      color: AppTheme.textTertiaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRegenerate,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondaryDark,
                    side: BorderSide(
                      color: AppTheme.textTertiaryDark.withOpacity(0.3),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Regenerate'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onPublish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Publish Experience'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Publish Dialog
class _PublishDialog extends StatefulWidget {
  @override
  State<_PublishDialog> createState() => _PublishDialogState();
}

class _PublishDialogState extends State<_PublishDialog> {
  double _price = 1.99;
  int _durationHours = 24;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        'Publish Experience',
        style: TextStyle(color: AppTheme.textPrimaryDark),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set your price',
            style: TextStyle(
              color: AppTheme.textSecondaryDark,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _price,
            min: 0.99,
            max: 4.99,
            divisions: 40,
            activeColor: AppTheme.primaryColor,
            label: '\$${_price.toStringAsFixed(2)}',
            onChanged: (value) {
              setState(() {
                _price = value;
              });
            },
          ),
          Center(
            child: Text(
              '\$${_price.toStringAsFixed(2)}',
              style: TextStyle(
                color: AppTheme.textPrimaryDark,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Duration',
            style: TextStyle(
              color: AppTheme.textSecondaryDark,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _DurationChip(
                label: '1h',
                hours: 1,
                selected: _durationHours == 1,
                onTap: () => setState(() => _durationHours = 1),
              ),
              _DurationChip(
                label: '6h',
                hours: 6,
                selected: _durationHours == 6,
                onTap: () => setState(() => _durationHours = 6),
              ),
              _DurationChip(
                label: '24h',
                hours: 24,
                selected: _durationHours == 24,
                onTap: () => setState(() => _durationHours = 24),
              ),
              _DurationChip(
                label: '7d',
                hours: 168,
                selected: _durationHours == 168,
                onTap: () => setState(() => _durationHours = 168),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You\'ll earn 80% of each sale (\$${(_price * 0.8).toStringAsFixed(2)})',
                    style: TextStyle(
                      color: AppTheme.textSecondaryDark,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppTheme.textSecondaryDark),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            showSuccessSnackbar(context, 'Experience published!');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Publish'),
        ),
      ],
    );
  }
}

/// Duration Chip
class _DurationChip extends StatelessWidget {
  final String label;
  final int hours;
  final bool selected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.hours,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppTheme.secondaryColor.withOpacity(0.2),
      backgroundColor: AppTheme.backgroundDark,
      labelStyle: TextStyle(
        color: selected ? AppTheme.secondaryColor : AppTheme.textSecondaryDark,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected
            ? AppTheme.secondaryColor
            : AppTheme.textTertiaryDark.withOpacity(0.2),
      ),
      onSelected: (_) => onTap(),
    );
  }
}
