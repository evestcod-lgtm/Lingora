import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models.dart';
import '../data/languages_data.dart';
import '../widgets/widgets.dart';
import '../main.dart';
import 'profile_screen.dart';
import 'reminders_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final app = AppState.I;
    final s = app.settings;

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          FadeSlideIn(child: Text('Настройки', style: Theme.of(context).textTheme.headlineMedium)),
          const SizedBox(height: 18),

          FadeSlideIn(
            child: GlassCard(
              onTap: () => Navigator.of(context).push(_slide(const ProfileScreen())),
              borderRadius: 18,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.violetPrimary,
                    child: Icon(Icons.person_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.userName, style: Theme.of(context).textTheme.titleMedium),
                        const Text('Мой профиль', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const _SectionTitle('Обучение'),
          const SizedBox(height: 10),
          FadeSlideIn(
            child: GlassCard(
              borderRadius: 18,
              child: Column(
                children: [
                  _RowTile(
                    icon: Icons.language_rounded,
                    title: 'Язык обучения',
                    trailing: Text(languageById(s.languageId).name,
                        style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.w700)),
                    onTap: () => _pickLanguage(context),
                  ),
                  const _Divider(),
                  _RowTile(
                    icon: Icons.speed_rounded,
                    title: 'Уровень сложности',
                    trailing: Text(s.level.title,
                        style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.w700)),
                    onTap: () => _pickLevel(context),
                  ),
                  const _Divider(),
                  _RowTile(
                    icon: Icons.timer_rounded,
                    title: 'Минут в день',
                    trailing: Text('${s.dailyMinutes} мин',
                        style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.w700)),
                    onTap: () => _pickMinutes(context),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const _SectionTitle('Звук и вибрация'),
          const SizedBox(height: 10),
          FadeSlideIn(
            child: GlassCard(
              borderRadius: 18,
              child: Column(
                children: [
                  _SwitchTile(
                    icon: Icons.volume_up_rounded,
                    title: 'Звуковые эффекты',
                    value: s.soundOn,
                    onChanged: (v) {
                      setState(() => s.soundOn = v);
                      app.saveSettings();
                    },
                  ),
                  const _Divider(),
                  _SwitchTile(
                    icon: Icons.vibration_rounded,
                    title: 'Вибрация',
                    value: s.vibrationOn,
                    onChanged: (v) {
                      setState(() => s.vibrationOn = v);
                      app.saveSettings();
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const _SectionTitle('Анимации'),
          const SizedBox(height: 10),
          FadeSlideIn(
            child: GlassCard(
              borderRadius: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome_motion_rounded, color: AppColors.textSecondary, size: 20),
                      SizedBox(width: 12),
                      Text('Скорость анимаций'),
                    ],
                  ),
                  Slider(
                    value: s.animationSpeed,
                    min: 0.5,
                    max: 1.5,
                    divisions: 4,
                    activeColor: AppColors.teal,
                    inactiveColor: Colors.white.withOpacity(0.1),
                    label: s.animationSpeed.toStringAsFixed(1),
                    onChanged: (v) {
                      setState(() => s.animationSpeed = v);
                      app.saveSettings();
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const _SectionTitle('Гномик и напоминания'),
          const SizedBox(height: 10),
          FadeSlideIn(
            child: GlassCard(
              borderRadius: 18,
              child: Column(
                children: [
                  _SwitchTile(
                    icon: Icons.notifications_active_rounded,
                    title: 'Напоминания заниматься',
                    value: s.remindersOn,
                    onChanged: (v) {
                      setState(() => s.remindersOn = v);
                      app.saveSettings();
                    },
                  ),
                  const _Divider(),
                  _RowTile(
                    icon: Icons.schedule_rounded,
                    title: 'Настроить время',
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    onTap: () => Navigator.of(context).push(_slide(const RemindersScreen())),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _pickLanguage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: 'Выбери язык',
        children: allLanguages.map((l) {
          return _PickerOption(
            label: '${l.flagEmoji}  ${l.name}',
            selected: l.id == AppState.I.settings.languageId,
            onTap: () {
              setState(() => AppState.I.settings.languageId = l.id);
              AppState.I.saveSettings();
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _pickLevel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: 'Выбери уровень',
        children: SkillLevel.values.map((lvl) {
          return _PickerOption(
            label: lvl.title,
            selected: lvl == AppState.I.settings.level,
            onTap: () {
              setState(() => AppState.I.settings.level = lvl);
              AppState.I.saveSettings();
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _pickMinutes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: 'Минут в день',
        children: [5, 10, 15, 20, 30].map((m) {
          return _PickerOption(
            label: '$m минут',
            selected: m == AppState.I.settings.dailyMinutes,
            onTap: () {
              setState(() => AppState.I.settings.dailyMinutes = m);
              AppState.I.saveSettings();
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  Route _slide(Widget screen) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, anim, __) => FadeTransition(opacity: anim, child: screen),
      );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w700));
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Divider(color: Colors.white.withOpacity(0.08), height: 24);
}

class _RowTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback onTap;
  const _RowTile({required this.icon, required this.title, required this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          trailing,
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({required this.icon, required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(title)),
        Switch(value: value, onChanged: onChanged, activeColor: AppColors.teal),
      ],
    );
  }
}

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _PickerSheet({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        borderRadius: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PickerOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: TextStyle(color: selected ? AppColors.teal : AppColors.textPrimary)),
      trailing: selected ? const Icon(Icons.check_rounded, color: AppColors.teal) : null,
    );
  }
}

