package yoon.hyeon.sang.translator.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public class Languages {
    @JsonProperty("language")
    private String language;

    @JsonProperty("name")
    private String name;

    @JsonProperty("supports_formality")
    private Boolean supports_formality;

    public Languages() {
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Boolean getSupports_formality() {
        return supports_formality;
    }

    public void setSupports_formality(Boolean supports_formality) {
        this.supports_formality = supports_formality;
    }
}
