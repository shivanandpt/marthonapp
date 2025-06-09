class RunCardUtils {
  static String formatDuration(int durationSeconds) {
    final duration = Duration(seconds: durationSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "$hours:$minutes:$seconds";
    } else {
      return "$minutes:$seconds";
    }
  }

  static String formatPace(double distanceKm, int durationSeconds) {
    if (distanceKm == 0) return "0:00";

    double paceMinutesPerKm = durationSeconds / 60.0 / distanceKm;
    int minutes = paceMinutesPerKm.floor();
    int seconds = ((paceMinutesPerKm - minutes) * 60).round();

    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }
}
