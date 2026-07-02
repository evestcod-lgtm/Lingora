/// Модели данных Lingora

enum SkillLevel { zero, medium, high }

extension SkillLevelX on SkillLevel {
  String get title => switch (this) {
        SkillLevel.zero => 'С нуля',
        SkillLevel.medium => 'Средний',
        SkillLevel.high => 'Отличный',
      };
  String get subtitle => switch (this) {
        SkillLevel.zero => 'Я только начинаю путь в мир Lingora',
        SkillLevel.medium => 'Я уже знаю базовые слова и фразы',
        SkillLevel.high => 'Я уверенно говорю и хочу углубляться',
      };
}

enum GnomeMood { joyful, content, bored, grumpy, pleading }

extension GnomeMoodX on GnomeMood {
  String get emoji => switch (this) {
        GnomeMood.joyful => '🤩',
        GnomeMood.content => '🙂',
        GnomeMood.bored => '😐',
        GnomeMood.grumpy => '😤',
        GnomeMood.pleading => '🥺',
      };
}

class LingoraLanguage {
  final String id;
  final String name;
  final String nativeTagline;
  final String flagEmoji;
  final String colorHex;
  final String mood; // "энергичный" / "спокойный" / "звонкий"
  final List<VocabWord> words;
  final List<PhraseEntry> phrases;
  final List<MiniStory> stories;

  const LingoraLanguage({
    required this.id,
    required this.name,
    required this.nativeTagline,
    required this.flagEmoji,
    required this.colorHex,
    required this.mood,
    required this.words,
    required this.phrases,
    required this.stories,
  });
}

class VocabWord {
  final String word; // на языке Lingora
  final String translation; // русский перевод
  final String? note; // произношение / подсказка
  const VocabWord(this.word, this.translation, {this.note});
}

class PhraseEntry {
  final String phrase;
  final String translation;
  const PhraseEntry(this.phrase, this.translation);
}

class MiniStory {
  final String title;
  final List<String> lines; // построчно, оригинал
  final List<String> translations;
  const MiniStory(this.title, this.lines, this.translations);
}

enum ExerciseType { multipleChoice, sentenceBuilder, matching, listenChoice }

class ExerciseItem {
  final ExerciseType type;
  final String prompt;
  final List<String> options; // варианты / слова для сборки
  final dynamic correctAnswer; // String для MC, List<String> для builder, Map для matching
  const ExerciseItem({
    required this.type,
    required this.prompt,
    required this.options,
    required this.correctAnswer,
  });
}

class UserProgress {
  int xp;
  int streakDays;
  DateTime? lastLessonDate;
  int level;
  Set<String> learnedWordIds;
  Set<String> unlockedAchievements;

  UserProgress({
    this.xp = 0,
    this.streakDays = 0,
    this.lastLessonDate,
    this.level = 1,
    Set<String>? learnedWordIds,
    Set<String>? unlockedAchievements,
  })  : learnedWordIds = learnedWordIds ?? {},
        unlockedAchievements = unlockedAchievements ?? {};

  int get xpForNextLevel => level * 100;
  double get levelProgress => (xp % xpForNextLevel) / xpForNextLevel;

  Map<String, dynamic> toJson() => {
        'xp': xp,
        'streakDays': streakDays,
        'lastLessonDate': lastLessonDate?.toIso8601String(),
        'level': level,
        'learnedWordIds': learnedWordIds.toList(),
        'unlockedAchievements': unlockedAchievements.toList(),
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
        xp: json['xp'] ?? 0,
        streakDays: json['streakDays'] ?? 0,
        lastLessonDate: json['lastLessonDate'] != null
            ? DateTime.tryParse(json['lastLessonDate'])
            : null,
        level: json['level'] ?? 1,
        learnedWordIds: Set<String>.from(json['learnedWordIds'] ?? []),
        unlockedAchievements:
            Set<String>.from(json['unlockedAchievements'] ?? []),
      );
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int xpRequired;
  const Achievement(this.id, this.title, this.description, this.emoji,
      this.xpRequired);
}

class AppSettings {
  bool soundOn;
  bool vibrationOn;
  double animationSpeed; // 0.5 .. 1.5
  int dailyMinutes;
  SkillLevel level;
  String languageId;
  bool remindersOn;
  int reminderHour;

  AppSettings({
    this.soundOn = true,
    this.vibrationOn = true,
    this.animationSpeed = 1.0,
    this.dailyMinutes = 10,
    this.level = SkillLevel.zero,
    this.languageId = 'dusk',
    this.remindersOn = true,
    this.reminderHour = 19,
  });

  Map<String, dynamic> toJson() => {
        'soundOn': soundOn,
        'vibrationOn': vibrationOn,
        'animationSpeed': animationSpeed,
        'dailyMinutes': dailyMinutes,
        'level': level.name,
        'languageId': languageId,
        'remindersOn': remindersOn,
        'reminderHour': reminderHour,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        soundOn: json['soundOn'] ?? true,
        vibrationOn: json['vibrationOn'] ?? true,
        animationSpeed: (json['animationSpeed'] ?? 1.0).toDouble(),
        dailyMinutes: json['dailyMinutes'] ?? 10,
        level: SkillLevel.values.firstWhere(
            (e) => e.name == json['level'],
            orElse: () => SkillLevel.zero),
        languageId: json['languageId'] ?? 'dusk',
        remindersOn: json['remindersOn'] ?? true,
        reminderHour: json['reminderHour'] ?? 19,
      );
}
