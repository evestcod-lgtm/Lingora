import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models.dart';
import '../data/languages_data.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import '../main.dart';
import 'home_screen.dart';

/// Управляет последовательностью экранов онбординга через PageView.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _pageController = PageController();
  int _page = 0;

  SkillLevel? _level;
  int _minutes = 10;
  String? _languageId;

  void _next() {
    if (_page < 3) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    AppState.I.settings.level = _level ?? SkillLevel.zero;
    AppState.I.settings.dailyMinutes = _minutes;
    AppState.I.settings.languageId = _languageId ?? 'dusk';
    await AppState.I.saveSettings();
    await StorageService.setOnboarded();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, anim, __) => FadeTransition(opacity: anim, child: const HomeScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Column(
        children: [
          const SizedBox(height: 12),
          _StepDots(current: _page, total: 4),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _page = i),
              children: [
                _WelcomeStep(onNext: _next),
                _LevelStep(
                  selected: _level,
                  onSelect: (l) => setState(() => _level = l),
                  onNext: _next,
                ),
                _MinutesStep(
                  selected: _minutes,
                  onSelect: (m) => setState(() => _minutes = m),
                  onNext: _next,
                ),
                _LanguageStep(
                  selected: _languageId,
                  onSelect: (id) => setState(() => _languageId = id),
                  onNext: _next,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  final int current;
  final int total;
  const _StepDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.teal : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomeStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          FadeSlideIn(
            child: const GnomeWidget(
              mood: GnomeMood.joyful,
              phrase: 'Привет! Я твой проводник в мир Lingora 🌟',
              size: 140,
            ),
          ),
          const SizedBox(height: 36),
          FadeSlideIn(
            delayMs: 150,
            child: Text('Добро пожаловать в Lingora',
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge),
          ),
          const SizedBox(height: 14),
          FadeSlideIn(
            delayMs: 250,
            child: const Text(
              'Здесь ты будешь изучать живые языки удивительного мира — '
              'через игру, короткие уроки и весёлые задания. '
              'Я буду рядом на каждом шаге.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5),
            ),
          ),
          const SizedBox(height: 40),
          FadeSlideIn(
            delayMs: 350,
            child: PrimaryButton(label: 'Начать путешествие', icon: Icons.arrow_forward_rounded, onPressed: onNext),
          ),
        ],
      ),
    );
  }
}

class _LevelStep extends StatelessWidget {
  final SkillLevel? selected;
  final ValueChanged<SkillLevel> onSelect;
  final VoidCallback onNext;
  const _LevelStep({required this.selected, required this.onSelect, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          FadeSlideIn(child: Text('Какой у тебя уровень?', style: Theme.of(context).textTheme.headlineMedium)),
          const SizedBox(height: 8),
          const FadeSlideIn(
            delayMs: 100,
            child: Text('Это поможет мне подобрать темп занятий',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 24),
          ...List.generate(SkillLevel.values.length, (i) {
            final level = SkillLevel.values[i];
            final isSelected = selected == level;
            return FadeSlideIn(
              delayMs: 100 * i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GlassCard(
                  onTap: () => onSelect(level),
                  borderRadius: 20,
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isSelected ? AppColors.primaryButton : null,
                          color: isSelected ? null : Colors.white.withOpacity(0.08),
                        ),
                        child: Icon(
                          isSelected ? Icons.check_rounded : Icons.circle_outlined,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(level.title, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text(level.subtitle,
                                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          if (selected != null)
            FadeSlideIn(child: PrimaryButton(label: 'Дальше', icon: Icons.arrow_forward_rounded, onPressed: onNext)),
        ],
      ),
    );
  }
}

class _MinutesStep extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;
  const _MinutesStep({required this.selected, required this.onSelect, required this.onNext});

  static const options = [5, 10, 15, 20, 30];

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          FadeSlideIn(child: Text('Сколько минут в день?', style: Theme.of(context).textTheme.headlineMedium)),
          const SizedBox(height: 8),
          const FadeSlideIn(
            delayMs: 100,
            child: Text('Даже 5 минут в день творят магию',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: options.map((m) {
              final isSelected = selected == m;
              return _TapWrap(
                onTap: () => onSelect(m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.primaryButton : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.15),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$m', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                      const Text('мин', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          FadeSlideIn(child: PrimaryButton(label: 'Дальше', icon: Icons.arrow_forward_rounded, onPressed: onNext)),
        ],
      ),
    );
  }
}

class _LanguageStep extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;
  const _LanguageStep({required this.selected, required this.onSelect, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          FadeSlideIn(child: Text('Какой язык мира Lingora изучаем?', style: Theme.of(context).textTheme.headlineMedium)),
          const SizedBox(height: 20),
          ...List.generate(allLanguages.length, (i) {
            final lang = allLanguages[i];
            final isSelected = selected == lang.id;
            return FadeSlideIn(
              delayMs: 100 * i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GlassCard(
                  onTap: () => onSelect(lang.id),
                  borderRadius: 20,
                  child: Row(
                    children: [
                      Text(lang.flagEmoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang.name, style: Theme.of(context).textTheme.titleMedium),
                            Text(lang.nativeTagline,
                                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded, color: AppColors.teal),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          if (selected != null)
            FadeSlideIn(child: PrimaryButton(label: 'Войти в мир Lingora', icon: Icons.auto_awesome_rounded, onPressed: onNext)),
        ],
      ),
    );
  }
}

class _TapWrap extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _TapWrap({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SoundService.click();
        onTap();
      },
      child: child,
    );
  }
}

