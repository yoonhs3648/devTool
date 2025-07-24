package yoon.hyeon.sang.translator.service;

import yoon.hyeon.sang.translator.dto.Languages;
import yoon.hyeon.sang.translator.dto.TranslateResponse;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

public interface TranslatorSvc {

    public List<Languages> getLanguage(String destination, HttpServletRequest request);
    public TranslateResponse doTranslate(String sourceLang, String content, List<String> targetLangList, HttpServletRequest request);
}
