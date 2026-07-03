import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/languages_data.dart';
import '../widgets/widgets.dart';
import '../main.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unlocked = AppState.I.progress.unlockedAchievements;

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          FadeSlideIn(child: Text('Награды', style: Theme.of(context).textTheme.headlineMedium)),
          const SizedBox(height: 6),
          FadeSlideIn(
            delayMs: 60,
            child: Text('${unlocked.length}/${allAchievements.length} получено',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.92,
            children: List.generate(allAchievements.length, (i) {
              final a = allAchievements[i];
              final isUnlocked = unlocked.contains(a.id);
              return FadeSlideIn(
                delayMs: (i % 6) * 60,
                child: GlassCard(
                  borderRadius: 20,
                  child: Opacity(
                    opacity: isUnlocked ? 1 : 0.4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.emoji, style: const TextStyle(fontSize: 30)),
                        const SizedBox(height: 10),
                        Text(a.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(a.description,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        const Spacer(),
                        if (isUnlocked)
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                          )
                        else
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.lock_rounded, color: AppColors.textSecondary, size: 16),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
