import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/languages_data.dart';
import '../widgets/widgets.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: AppState.I.userName);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.I;
    final lang = languageById(app.settings.languageId);

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 14),
              Text('Профиль', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 24),
          FadeSlideIn(
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryButton,
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 42),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: 220,
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      decoration: const InputDecoration(border: InputBorder.none),
                      onSubmitted: (v) => app.saveUserName(v.isEmpty ? 'Странник' : v),
                      onEditingComplete: () => app.saveUserName(
                          _controller.text.isEmpty ? 'Странник' : _controller.text),
                    ),
                  ),
                  Text('Изучает ${lang.name} ${lang.flagEmoji}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          FadeSlideIn(
            delayMs: 100,
            child: Row(
              children: [
                Expanded(child: _MiniStat(label: 'Уровень', value: '${app.progress.level}')),
                const SizedBox(width: 12),
                Expanded(child: _MiniStat(label: 'Опыт', value: '${app.progress.xp}')),
                const SizedBox(width: 12),
                Expanded(child: _MiniStat(label: 'Серия', value: '${app.progress.streakDays} дн')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FadeSlideIn(
            delayMs: 160,
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('О тебе', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Text(
                    'Ты изучаешь ${lang.name} — ${lang.nativeTagline.toLowerCase()}. '
                    'Продолжай в том же духе, и гномик обязательно это заметит!',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

