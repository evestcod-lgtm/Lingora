import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models.dart';
import '../data/languages_data.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import '../main.dart';
import 'lesson_screen.dart';
import 'dictionary_screen.dart';
import 'progress_screen.dart';
import 'achievements_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'gnome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  final _screens = const [
    _HomeTab(),
    DictionaryScreen(),
    ProgressScreen(),
    AchievementsScreen(),
    SettingsScreen(),
  ];

  final _icons = const [
    Icons.home_rounded,
    Icons.menu_book_rounded,
    Icons.insights_rounded,
    Icons.emoji_events_rounded,
    Icons.settings_rounded,
  ];

  final _labels = const ['Дом', 'Словарь', 'Прогресс', 'Награды', 'Настройки'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(key: ValueKey(_tab), child: _screens[_tab]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            borderRadius: 26,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_icons.length, (i) {
                final active = _tab == i;
                return GestureDetector(
                  onTap: () {
                    SoundService.click();
                    setState(() => _tab = i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? Colors.white.withOpacity(0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_icons[i],
                            color: active ? AppColors.teal : AppColors.textSecondary, size: 22),
                        if (active) ...[
                          const SizedBox(height: 2),
                          Text(_labels[i],
                              style: const TextStyle(fontSize: 10, color: AppColors.teal)),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  @override
  Widget build(BuildContext context) {
    final app = AppState.I;
    final lang = languageById(app.settings.languageId);
    final ps = ProgressService(app.progress);
    final mood = GnomeService.moodFor(ps.daysSinceLastLesson());
    final phrase = GnomeService.randomPhrase(mood);

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          FadeSlideIn(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Привет, ${app.userName}!',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const Text('Продолжим путь в мире Lingora?',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                _StreakBadge(days: app.progress.streakDays),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FadeSlideIn(
            delayMs: 100,
            child: Center(
              child: GnomeWidget(
                mood: mood,
                phrase: phrase,
                onTap: () => Navigator.of(context).push(_route(const GnomeScreen())),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeSlideIn(
            delayMs: 180,
            child: GlassCard(
              child: Row(
                children: [
                  ProgressRing(
                    value: app.progress.levelProgress,
                    center: Text('${app.progress.level}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Уровень ${app.progress.level}',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('${app.progress.xp} опыта · ${lang.name} ${lang.flagEmoji}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                        const SizedBox(height: 8),
                        Text('Цель на сегодня: ${app.settings.dailyMinutes} мин занятий',
                            style: const TextStyle(color: AppColors.tealSoft, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeSlideIn(
            delayMs: 240,
            child: PrimaryButton(
              label: 'Начать урок',
              icon: Icons.play_arrow_rounded,
              height: 62,
              onPressed: () => Navigator.of(context).push(_route(LessonScreen(language: lang))),
            ),
          ),
          const SizedBox(height: 20),
          FadeSlideIn(
            delayMs: 300,
            child: Row(
              children: [
                Expanded(
                  child: _QuickCard(
                    icon: Icons.menu_book_rounded,
                    title: 'Словарь',
                    subtitle: '${lang.words.length} слов',
                    onTap: () => Navigator.of(context).push(_route(const DictionaryScreen())),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _QuickCard(
                    icon: Icons.extension_rounded,
                    title: 'Упражнения',
                    subtitle: 'Практика',
                    onTap: () => Navigator.of(context).push(_route(LessonScreen(language: lang))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FadeSlideIn(
            delayMs: 360,
            child: GlassCard(
              borderRadius: 18,
              child: Row(
                children: [
                  const Text('🍀', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _motivationFor(mood),
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _motivationFor(GnomeMood mood) {
    return switch (mood) {
      GnomeMood.joyful => 'Отличный темп! Каждое слово делает тебя ближе к свободному разговору.',
      GnomeMood.content => 'Маленькие шаги каждый день — и мир Lingora откроется полностью.',
      GnomeMood.bored => 'Даже один урок сегодня вернёт тебя в ритм.',
      GnomeMood.grumpy => 'Твой словарный запас скучает. Загляни хотя бы на 5 минут!',
      GnomeMood.pleading => 'Один урок — и мы снова в деле, обещаю!',
    };
  }

  Route _route(Widget screen) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, anim, __) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(anim),
            child: screen,
          ),
        ),
      );
}

class _StreakBadge extends StatelessWidget {
  final int days;
  const _StreakBadge({required this.days});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 16,
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text('$days', style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.teal),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
