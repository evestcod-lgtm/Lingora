import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../models.dart';
import '../data/languages_data.dart';

/// Хранилище: настройки, прогресс, флаг завершённого онбординга.
class StorageService {
  static const _kSettings = 'lingora_settings';
  static const _kProgress = 'lingora_progress';
  static const _kOnboarded = 'lingora_onboarded';
  static const _kUserName = 'lingora_user_name';

  static Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSettings);
    if (raw == null) return AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw));
    } catch (_) {
      return AppSettings();
    }
  }

  static Future<void> saveSettings(AppSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSettings, jsonEncode(s.toJson()));
  }

  static Future<UserProgress> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProgress);
    if (raw == null) return UserProgress();
    try {
      return UserProgress.fromJson(jsonDecode(raw));
    } catch (_) {
      return UserProgress();
    }
  }

  static Future<void> saveProgress(UserProgress p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProgress, jsonEncode(p.toJson()));
  }

  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboarded) ?? false;
  }

  static Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboarded, true);
  }

  static Future<String> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserName) ?? 'Странник';
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserName, name);
  }
}

/// Управляет опытом, уровнем, серией занятий (streak), ачивками.
class ProgressService {
  final UserProgress progress;
  ProgressService(this.progress);

  List<Achievement> addXp(int amount) {
    progress.xp += amount;
    final newlyUnlocked = <Achievement>[];
    // Левелап: пока накопленный опыт покрывает порог уровня — повышаем уровень.
    // Условие строго сужается на каждой итерации, цикл конечен.
    while (progress.xp >= progress.level * 100) {
      progress.level += 1;
    }
    for (final a in allAchievements) {
      if (a.xpRequired > 0 &&
          progress.xp >= a.xpRequired &&
          !progress.unlockedAchievements.contains(a.id)) {
        progress.unlockedAchievements.add(a.id);
        newlyUnlocked.add(a);
      }
    }
    return newlyUnlocked;
  }

  List<Achievement> registerLessonCompleted() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = progress.lastLessonDate;
    if (last == null) {
      progress.streakDays = 1;
    } else {
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 0) {
        // уже занимались сегодня — стрик не меняется
      } else if (diff == 1) {
        progress.streakDays += 1;
      } else {
        progress.streakDays = 1;
      }
    }
    progress.lastLessonDate = now;
    final unlocked = <Achievement>[];
    if (!progress.unlockedAchievements.contains('first_lesson')) {
      progress.unlockedAchievements.add('first_lesson');
      unlocked.add(allAchievements.firstWhere((a) => a.id == 'first_lesson'));
    }
    for (final id in ['streak_3', 'streak_7', 'streak_30']) {
      final threshold = int.parse(id.split('_').last);
      if (progress.streakDays >= threshold &&
          !progress.unlockedAchievements.contains(id)) {
        progress.unlockedAchievements.add(id);
        unlocked.add(allAchievements.firstWhere((a) => a.id == id));
      }
    }
    return unlocked;
  }

  /// Сколько дней прошло с последнего занятия (для настроения гномика).
  int daysSinceLastLesson() {
    if (progress.lastLessonDate == null) return 99;
    final now = DateTime.now();
    final last = progress.lastLessonDate!;
    return DateTime(now.year, now.month, now.day)
        .difference(DateTime(last.year, last.month, last.day))
        .inDays;
  }
}

/// Настроение гномика зависит от активности пользователя.
class GnomeService {
  static GnomeMood moodFor(int daysSinceLastLesson) {
    if (daysSinceLastLesson <= 0) return GnomeMood.joyful;
    if (daysSinceLastLesson == 1) return GnomeMood.content;
    if (daysSinceLastLesson == 2) return GnomeMood.bored;
    if (daysSinceLastLesson <= 4) return GnomeMood.grumpy;
    return GnomeMood.pleading;
  }

  static const Map<GnomeMood, List<String>> phrases = {
    GnomeMood.joyful: [
      'Ты сегодня занимался — я просто сияю! ✨',
      'Вот это темп! Мир Lingora гордится тобой!',
      'Ещё одно слово — и я станцую!',
    ],
    GnomeMood.content: [
      'Привет! Готов продолжить наше приключение?',
      'Я помню тебя вчера — было классно!',
      'Новый день — новые слова. Начнём?',
    ],
    GnomeMood.bored: [
      'Хм... а тебя тут не было со вчера.',
      'Я немного заскучал один. Заглянешь на урок?',
      'Слова тоже скучают без тебя, между прочим.',
    ],
    GnomeMood.grumpy: [
      'Так, минуточку. Уже несколько дней тишины!',
      'Я, вообще-то, начинаю ворчать. Возвращайся!',
      'Мои усы обвисли от грусти. Урок спасёт положение!',
    ],
    GnomeMood.pleading: [
      'Пожалуйста... ну пожалуйста, вернись на урок! 🥺',
      'Я испеку тебе магическое печенье, только приходи!',
      'Без тебя весь мир Lingora как будто тише...',
    ],
  };

  static String randomPhrase(GnomeMood mood) {
    final list = phrases[mood]!;
    return list[Random().nextInt(list.length)];
  }
}

/// Звуковая система: мягкая, отключаемая, не крашит приложение
/// если файл ещё не добавлен в assets/sounds.
class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static bool enabled = true;
  static bool vibrationEnabled = true;

  static Future<void> _play(String fileName) async {
    if (!enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/$fileName'));
    } catch (_) {
      // файла ещё нет в assets — тихо игнорируем, приложение не падает
    }
  }

  static Future<void> _vibrate({int duration = 30}) async {
    if (!vibrationEnabled) return;
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: duration);
      }
    } catch (_) {}
  }

  static void click() {
    _play('click.mp3');
    _vibrate(duration: 15);
  }

  static void success() {
    _play('success.mp3');
    _vibrate(duration: 25);
  }

  static void error() {
    _play('error.mp3');
    _vibrate(duration: 40);
  }

  static void reward() {
    _play('reward.mp3');
    _vibrate(duration: 50);
  }

  static void streak() => _play('streak.mp3');
  static void gnomeHappy() => _play('gnome_happy.mp3');
  static void gnomeSad() => _play('gnome_sad.mp3');
  static void gnomeBeg() => _play('gnome_beg.mp3');
}

/// Генерация упражнений на основе словаря/фраз выбранного языка.
class ExerciseGenerator {
  static List<ExerciseItem> generateLesson(LingoraLanguage lang, {int count = 8}) {
    final rnd = Random();
    final items = <ExerciseItem>[];
    final words = List<VocabWord>.from(lang.words)..shuffle(rnd);
    final phrases = List<PhraseEntry>.from(lang.phrases)..shuffle(rnd);

    // 1) Карточки на перевод (multiple choice) — слово -> перевод
    for (final w in words.take(3)) {
      final distractors = (List<VocabWord>.from(lang.words)..shuffle(rnd))
          .where((x) => x.translation != w.translation)
          .take(3)
          .map((x) => x.translation)
          .toList();
      final options = [w.translation, ...distractors]..shuffle(rnd);
      items.add(ExerciseItem(
        type: ExerciseType.multipleChoice,
        prompt: w.word,
        options: options,
        correctAnswer: w.translation,
      ));
    }

    // 2) Сопоставление перевод -> слово
    for (final w in words.skip(3).take(2)) {
      final distractors = (List<VocabWord>.from(lang.words)..shuffle(rnd))
          .where((x) => x.word != w.word)
          .take(3)
          .map((x) => x.word)
          .toList();
      final options = [w.word, ...distractors]..shuffle(rnd);
      items.add(ExerciseItem(
        type: ExerciseType.multipleChoice,
        prompt: w.translation,
        options: options,
        correctAnswer: w.word,
      ));
    }

    // 3) Сборка предложения из слов
    for (final p in phrases.take(3)) {
      final wordsInPhrase = p.phrase.split(' ');
      final shuffled = List<String>.from(wordsInPhrase)..shuffle(rnd);
      items.add(ExerciseItem(
        type: ExerciseType.sentenceBuilder,
        prompt: p.translation,
        options: shuffled,
        correctAnswer: wordsInPhrase,
      ));
    }

    items.shuffle(rnd);
    return items.take(count).toList();
  }
}
