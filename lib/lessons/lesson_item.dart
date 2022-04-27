class LessonItem {

  String? kr;
  String? pron;
  String? en;
  String? audio;

  setExplainItem(String explain) {
    en = explain;
  }

  setAudioItem(String kr, String pron, String en, String audio) {
    kr = kr;
    pron = pron;
    en = en;
    audio = audio;
  }
}