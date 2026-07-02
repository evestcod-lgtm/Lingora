import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/languages_data.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import '../main.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final lang = languageById(AppState.I.settings.languageId);
    final words = lang.words
        .where((w) =>
            w.word.toLowerCase().contains(_query.toLowerCase()) ||
            w.translation.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          FadeSlideIn(
            child: Row(
              children: [
                Text(lang.flagEmoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Text('Словарь · ${lang.name}', style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FadeSlideIn(
            delayMs: 80,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: 18,
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Поиск слова...',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  icon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const FadeSlideIn(
            delayMs: 120,
            child: Text('Фразы для практики', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          FadeSlideIn(
            delayMs: 160,
            child: SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: lang.phrases.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final p = lang.phrases[i];
                  return Container(
                    width: 220,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryButton,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(p.phrase,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(p.translation,
                            style: const TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Слова', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...List.generate(words.length, (i) {
            final w = words[i];
            final learned = AppState.I.progress.learnedWordIds.contains(w.word);
            return FadeSlideIn(
              delayMs: (i % 8) * 40,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  onTap: () {
                    setState(() {
                      AppState.I.progress.learnedWordIds.add(w.word);
                    });
                    AppState.I.saveProgress();
                    SoundService.success();
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(w.word,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            Text(w.translation,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                          ],
                        ),
                      ),
                      Icon(
                        learned ? Icons.star_rounded : Icons.star_border_rounded,
                        color: learned ? AppColors.gold : AppColors.textSecondary,
                      ),
                    ],
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
