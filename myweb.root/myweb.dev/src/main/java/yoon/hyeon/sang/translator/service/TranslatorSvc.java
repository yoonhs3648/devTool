package yoon.hyeon.sang.translator.service;

import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;
import yoon.hyeon.sang.translator.dto.Languages;
import yoon.hyeon.sang.translator.dto.TranslateFileResponse;
import yoon.hyeon.sang.translator.dto.TranslateResponse;

import org.springframework.core.io.Resource;
import org.springframework.core.io.ByteArrayResource;
import javax.servlet.http.HttpServletRequest;
import java.util.List;

public interface TranslatorSvc {

    public List<Languages> getLanguage(String destination, HttpServletRequest request);
    public TranslateResponse translateText(String sourceLang, String content, List<String> targetLangList, HttpServletRequest request);
    public TranslateFileResponse translateFile(String sourceLang, String targetLang, MultipartFile file, HttpServletRequest request);
    public TranslateFileResponse getTranslateRemainTime(String docId, String docKey, HttpServletRequest request);
    public ResponseEntity<Resource> donwloadTranslatedFile(String docId, String docKey, HttpServletRequest request);
}
