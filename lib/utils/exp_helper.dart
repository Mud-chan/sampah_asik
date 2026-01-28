class ExpHelper {
  /// EXP dasar level 1
  static const int baseExp = 1000;

  /// Kenaikan EXP tiap level
  static const int increment = 1500;

  /// EXP yang dibutuhkan untuk naik ke level berikutnya
  static int expForNextLevel(int level) {
    return baseExp + (level * increment);
  }

  /// Hitung level dari total EXP
  static int getLevel(int totalExp) {
    int level = 0;
    int expNeeded = expForNextLevel(level);

    while (totalExp >= expNeeded) {
      totalExp -= expNeeded;
      level++;
      expNeeded = expForNextLevel(level);
    }

    return level;
  }

  /// EXP saat ini di level berjalan
  static int getCurrentExp(int totalExp) {
    int level = 0;
    int expNeeded = expForNextLevel(level);

    while (totalExp >= expNeeded) {
      totalExp -= expNeeded;
      level++;
      expNeeded = expForNextLevel(level);
    }

    return totalExp;
  }

  /// Progress bar (0.0 - 1.0)
  static double getProgress(int totalExp) {
    int level = getLevel(totalExp);
    int currentExp = getCurrentExp(totalExp);
    int expNeeded = expForNextLevel(level);

    return currentExp / expNeeded;
  }

  /// Sisa EXP ke level berikutnya
  static int expToNextLevel(int totalExp) {
    int level = getLevel(totalExp);
    int currentExp = getCurrentExp(totalExp);
    int expNeeded = expForNextLevel(level);

    return expNeeded - currentExp;
  }
}
