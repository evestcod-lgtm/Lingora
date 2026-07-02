import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import '../main.dart';

class LessonScreen extends StatefulWidget {
  final LingoraLanguage language;
  const LessonScreen({super.key, required this.language});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final List<ExerciseItem> _items;
  int _index = 0;
  int _correctCount = 0;
  bool _showReward = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _items = ExerciseGenerator.generateLesson(widget.language, count: 8);
  }

  void _onAnswered(bool correct) {
    if (correct) {
      _correctCount++;
      SoundService.success();
    } else {
      SoundService.error();
    }
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (_index < _items.length - 1) {
        setState(() => _index++);
      } else {
        _completeLesson();
      }
    });
  }

  Future<void> _completeLesson() async {
    final app = AppState.I;
    final ps = ProgressService(app.progress);
    final earnedXp = _correctCount * 10 + 5;
    ps.addXp(earnedXp);
    ps.registerLessonCompleted();
    await app.saveProgress();
    setState(() {
      _finished = true;
      _showReward = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return _LessonResultScreen(
        correct: _correctCount,
        total: _items.length,
        showReward: _showReward,
        onRewardDone: () => setState(() => _showReward = false),
      );
    }

    final item = _items[_index];
    final progress = (_index) / _items.length;

    return GradientBackground(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 400),
                      builder: (context, v, _) => LinearProgressIndicator(
                        value: v,
                        minHeight: 10,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation(AppColors.teal),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0.08, 0), end: Offset.zero).animate(anim),
                  child: child,
                ),
              ),
              child: _ExerciseView(
                key: ValueKey(_index),
                item: item,
                onAnswered: _onAnswered,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseView extends StatelessWidget {
  final ExerciseItem item;
  final void Function(bool correct) onAnswered;
  const _ExerciseView({super.key, required this.item, required this.onAnswered});

  @override
  Widget build(BuildContext context) {
    switch (item.type) {
      case ExerciseType.multipleChoice:
      case ExerciseType.listenChoice:
        return _MultipleChoiceView(item: item, onAnswered: onAnswered);
      case ExerciseType.sentenceBuilder:
        return _SentenceBuilderView(item: item, onAnswered: onAnswered);
      case ExerciseType.matching:
        return _MultipleChoiceView(item: item, onAnswered: onAnswered);
    }
  }
}

class _MultipleChoiceView extends StatefulWidget {
  final ExerciseItem item;
  final void Function(bool correct) onAnswered;
  const _MultipleChoiceView({required this.item, required this.onAnswered});

  @override
  State<_MultipleChoiceView> createState() => _MultipleChoiceViewState();
}

class _MultipleChoiceViewState extends State<_MultipleChoiceView> {
  String? _selected;
  bool? _isCorrect;

  void _select(String option) {
    if (_selected != null) return;
    final correct = option == widget.item.correctAnswer;
    setState(() {
      _selected = option;
      _isCorrect = correct;
    });
    widget.onAnswered(correct);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text('Выбери правильный перевод',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          FadeSlideIn(
            child: GlassCard(
              borderRadius: 26,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              child: Center(
                child: Text(
                  widget.item.prompt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...widget.item.options.asMap().entries.map((e) {
            final option = e.value;
            final isSelected = _selected == option;
            Color? bg;
            Color borderColor = Colors.white.withOpacity(0.14);
            if (_selected != null) {
              if (option == widget.item.correctAnswer) {
                bg = AppColors.success.withOpacity(0.22);
                borderColor = AppColors.success;
              } else if (isSelected) {
                bg = AppColors.error.withOpacity(0.22);
                borderColor = AppColors.error;
              }
            }
            return FadeSlideIn(
              delayMs: 60 * e.key,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _select(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: bg ?? Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(option, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SentenceBuilderView extends StatefulWidget {
  final ExerciseItem item;
  final void Function(bool correct) onAnswered;
  const _SentenceBuilderView({required this.item, required this.onAnswered});

  @override
  State<_SentenceBuilderView> createState() => _SentenceBuilderViewState();
}

class _SentenceBuilderViewState extends State<_SentenceBuilderView> {
  late List<String?> _slots;
  late List<bool> _used;
  bool _checked = false;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    final correctWords = widget.item.correctAnswer as List<String>;
    _slots = List.filled(correctWords.length, null);
    _used = List.filled(widget.item.options.length, false);
  }

  void _tapWord(int optionIndex) {
    if (_checked || _used[optionIndex]) return;
    final firstEmpty = _slots.indexOf(null);
    if (firstEmpty == -1) return;
    setState(() {
      _slots[firstEmpty] = widget.item.options[optionIndex];
      _used[optionIndex] = true;
    });
    if (!_slots.contains(null)) _check();
  }

  void _removeSlot(int slotIndex) {
    if (_checked || _slots[slotIndex] == null) return;
    final word = _slots[slotIndex]!;
    setState(() {
      _slots[slotIndex] = null;
      // находим первый занятый инстанс этого слова, чтобы освободить
      for (int i = 0; i < widget.item.options.length; i++) {
        if (widget.item.options[i] == word && _used[i]) {
          _used[i] = false;
          break;
        }
      }
    });
  }

  void _check() {
    final correctWords = widget.item.correctAnswer as List<String>;
    final built = _slots.map((e) => e ?? '').toList();
    final correct = List.generate(built.length, (i) => built[i] == correctWords[i])
        .every((e) => e);
    setState(() {
      _checked = true;
      _isCorrect = correct;
    });
    widget.onAnswered(correct);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text('Собери предложение из слов',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          FadeSlideIn(
            child: GlassCard(
              borderRadius: 22,
              child: Text(
                widget.item.prompt,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // слоты для сборки
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_slots.length, (i) {
              final filled = _slots[i] != null;
              Color border = Colors.white.withOpacity(0.2);
              if (_checked && _isCorrect != null) {
                border = _isCorrect! ? AppColors.success : AppColors.error;
              }
              return GestureDetector(
                onTap: () => _removeSlot(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  constraints: const BoxConstraints(minWidth: 56, minHeight: 46),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: filled ? Colors.white.withOpacity(0.1) : Colors.transparent,
                    border: Border(bottom: BorderSide(color: border, width: 2)),
                  ),
                  child: Text(_slots[i] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
          // доступные слова
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(widget.item.options.length, (i) {
              final used = _used[i];
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: used ? 0.25 : 1,
                child: GestureDetector(
                  onTap: () => _tapWord(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: used ? null : AppColors.primaryButton,
                      color: used ? Colors.white.withOpacity(0.08) : null,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(widget.item.options[i],
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          if (!_slots.contains(null) && !_checked)
            PrimaryButton(label: 'Проверить', icon: Icons.check_rounded, onPressed: _check),
        ],
      ),
    );
  }
}

class _LessonResultScreen extends StatelessWidget {
  final int correct;
  final int total;
  final bool showReward;
  final VoidCallback onRewardDone;

  const _LessonResultScreen({
    required this.correct,
    required this.total,
    required this.showReward,
    required this.onRewardDone,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : correct / total;
    final xp = correct * 10 + 5;
    return GradientBackground(
      child: Stack(
        children: [
          ScreenScaffold(
            child: Column(
              children: [
                const SizedBox(height: 50),
                FadeSlideIn(
                  child: Text(
                    percent >= 0.7 ? 'Отличный урок!' : 'Урок пройден!',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                const FadeSlideIn(
                  delayMs: 100,
                  child: Text('Гномик очень тобой гордится 🎉',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
                const SizedBox(height: 32),
                FadeSlideIn(
                  delayMs: 180,
                  child: GnomeWidget(
                    mood: percent >= 0.7 ? GnomeMood.joyful : GnomeMood.content,
                    phrase: percent >= 0.7
                        ? 'Ты почти не ошибался — я в восторге!'
                        : 'Хороший результат, продолжаем вместе!',
                    size: 130,
                  ),
                ),
                const SizedBox(height: 32),
                FadeSlideIn(
                  delayMs: 260,
                  child: GlassCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatColumn(label: 'Правильно', value: '$correct/$total'),
                        _StatColumn(label: 'Опыт', value: '+$xp XP'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeSlideIn(
                  delayMs: 340,
                  child: PrimaryButton(
                    label: 'Продолжить',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
          if (showReward)
            Positioned.fill(
              child: Center(
                child: RewardBurst(label: '+$xp XP', onDone: onRewardDone),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

