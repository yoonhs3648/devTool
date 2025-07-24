package yoon.hyeon.sang.translator.dto;

import java.util.ArrayList;
import java.util.List;

public class TranslateResponse {

    private List<Translations> translations;

    public TranslateResponse() {
        this.translations = new ArrayList<>();
    }

    public List<Translations> getTranslations() {
        return translations;
    }

    public void setTranslations(List<Translations> translations) {
        this.translations = translations;
    }

    public static class Translations {
        public Translations() { }

        private String detected_source_language;    //출발언어
        private String text;    //번역결과
        private String targetLang;   //도착언어

        public String getDetected_source_language() {
            return detected_source_language;
        }

        public void setDetected_source_language(String detected_source_language) {
            this.detected_source_language = detected_source_language;
        }

        public String getText() {
            return text;
        }

        public void setText(String text) {
            this.text = text;
        }

        public String getTargetLang() {
            return targetLang;
        }

        public void setTargetLang(String targetLang) {
            this.targetLang = targetLang;
        }
    }

}

