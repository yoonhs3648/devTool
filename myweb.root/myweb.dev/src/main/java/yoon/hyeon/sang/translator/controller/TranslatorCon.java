package yoon.hyeon.sang.translator.controller;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;
import yoon.hyeon.sang.translator.dto.Languages;
import yoon.hyeon.sang.translator.dto.TranslateFileResponse;
import yoon.hyeon.sang.translator.dto.TranslateResponse;
import yoon.hyeon.sang.translator.service.TranslatorSvc;
import yoon.hyeon.sang.util.JsonConverter;

import org.springframework.core.io.Resource;
import org.springframework.core.io.ByteArrayResource;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class TranslatorCon {

    @Autowired
    private TranslatorSvc translatorSvc;

    private static final Logger logger = LogManager.getLogger(TranslatorCon.class);

    @RequestMapping(value = "/translator", method = RequestMethod.GET)
    public ModelAndView goPage(HttpServletRequest request) throws IOException {
        String returnURL = "translator/translator";
        ModelAndView mv = new ModelAndView();

        List<Languages> sourceLang = translatorSvc.getLanguage("source", request);
        List<Languages> targetLang = translatorSvc.getLanguage("target", request);

        ObjectMapper mapper = new ObjectMapper();
        String targetLangString = mapper.writeValueAsString(targetLang);

        mv.addObject("sourceLang", sourceLang);
        mv.addObject("targetLang", targetLang);
        mv.addObject("targetLangStr", targetLangString);
        mv.setViewName(returnURL);
        return  mv;
    }

    @RequestMapping(value = "/translate/text", method = RequestMethod.POST)
    public @ResponseBody List<TranslateResponse.Translations> textTranslate(HttpServletRequest request, @RequestBody Map<String, Object> requestBody) {

        String sourceLang = (String) requestBody.get("sourceLang"); //출발언어
        String content = (String) requestBody.get("content");    //번역할 내용

        List<String> targetList = JsonConverter.deserializeObject(JsonConverter.serializeObject(requestBody.get("targetList"))
                , new TypeReference<List<String>>() {}); //도착언어리스트

        TranslateResponse translate = translatorSvc.translateText(sourceLang, content, targetList, request);

        return translate.getTranslations();
    }

    @RequestMapping(value ="/translate/file", method = RequestMethod.POST)
    public @ResponseBody Map<String, Object> fileTranslate(HttpServletRequest request,
                                                  @RequestParam("targetLang") String targetLang,
                                                  @RequestParam("sourceLang") String sourceLang,
                                                  @RequestParam("file") MultipartFile file) throws Exception{
        //null check
        if (targetLang == null || targetLang.trim().isEmpty() || file == null || file.isEmpty()) {
            throw new IllegalArgumentException("필수 파라미터 누락");
        }

        Map<String, Object> result = new HashMap<>();

        TranslateFileResponse translatedFile = translatorSvc.translateFile(sourceLang, targetLang, file, request);

        //파일명 설정
        String originalName = file.getOriginalFilename();
        String downloadName = "(" + targetLang + ")" + originalName;

        result.put("originalName", originalName);
        result.put("downloadName", downloadName);
        result.put("fileSize", translatedFile.getFileSize());
        result.put("docId", translatedFile.getDocId());
        result.put("docKey", translatedFile.getDocKey());

        return result;
    }

    @RequestMapping(value = "/translate/fileStatus", method = RequestMethod.GET)
    public @ResponseBody Map<String, Object> fileStatus(HttpServletRequest request) {
        String docId = request.getParameter("docId");
        String docKey = request.getParameter("docKey");

        //null check
        if (docId == null || docId.trim().isEmpty() || docKey == null || docKey.trim().isEmpty()) {
            throw new IllegalArgumentException("필수 파라미터 누락");
        }

        Map<String, Object> result = new HashMap<>();

        TranslateFileResponse translatedFileInfo = translatorSvc.getTranslateRemainTime(docId, docKey, request);

        result.put("fileStatus", translatedFileInfo.getFileStatus());
        result.put("remainSec", translatedFileInfo.getRemainSec());
        result.put("charUsage", translatedFileInfo.getCharUsage());
        result.put("errMsg", translatedFileInfo.getErrMsg());
        result.put("isSuccess", "OK");

        return result;
    }

    @RequestMapping(value = "/translate/fileDownload", method = RequestMethod.GET)
    public ResponseEntity<Resource> fileDownload(HttpServletRequest request) {
        String docId = request.getParameter("docId");
        String docKey = request.getParameter("docKey");

        //null check
        if (docId == null || docId.trim().isEmpty() || docKey == null || docKey.trim().isEmpty()) {
            throw new IllegalArgumentException("필수 파라미터 누락");
        }

        Map<String, Object> result = new HashMap<>();

        return translatorSvc.donwloadTranslatedFile(docId, docKey, request);
    }
}
