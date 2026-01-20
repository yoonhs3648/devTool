package yoon.hyeon.sang.translator.service.impl;

import com.fasterxml.jackson.core.type.TypeReference;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.multipart.MultipartFile;
import yoon.hyeon.sang.exception.ApiException;
import yoon.hyeon.sang.exception.UserException;
import yoon.hyeon.sang.translator.dto.Languages;
import yoon.hyeon.sang.translator.dto.TranslateFileResponse;
import yoon.hyeon.sang.translator.dto.TranslateResponse;
import yoon.hyeon.sang.translator.service.TranslatorSvc;
import yoon.hyeon.sang.userObj.ApiFileResponse;
import yoon.hyeon.sang.userObj.ApiResponse;
import yoon.hyeon.sang.util.ApiRequester;
import yoon.hyeon.sang.util.JsonConverter;
import yoon.hyeon.sang.util.PropertiesUtil;
import yoon.hyeon.sang.util.RedisUtil;

import org.springframework.core.io.Resource;
import org.springframework.core.io.ByteArrayResource;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.*;

@Service
public class TranslatorSvcImpl implements TranslatorSvc {

    private static final Logger logger = LogManager.getLogger(TranslatorSvcImpl.class);
    public static final String apiKey = "DeepL-Auth-Key " + PropertiesUtil.getProperties("translator.api.key");

    @Autowired
    private RedisUtil redisUtil;

    @Override
    public List<Languages> getLanguage(String destination, HttpServletRequest request) {

        String redisKey = "lang.".concat(destination);
        long timeoutMillis = 30 * 60 * 1000;
        if (redisUtil.hasValue(redisKey)) {
            return (List<Languages>) redisUtil.get(redisKey);
        }

        String url = "https://api-free.deepl.com/v2/languages";

        Map<String, String> params = new HashMap<>();
        params.put("type", destination);

        Map<String, String> headers = new HashMap<>();
        headers.put("Authorization", apiKey);
        headers.put("Accept", "application/json");

        ApiRequester apiRequester = new ApiRequester(getClass(), request);

        try {
            ApiResponse response = apiRequester.callApi(apiRequester.appendQueryParams(url, params), HttpMethod.GET, headers);
            if (response.isSuccess()) {
                List<Languages> languages = JsonConverter.deserializeObject(response.getResponseBody(),
                        new TypeReference<List<Languages>>() { });
                languages.sort(Comparator.comparingInt(lang -> {
                    switch(lang.getLanguage().toUpperCase()) {
                        case "KO": return 0;
                        case "EN":
                        case "EN-US": return 1;
                        case "ZH": return 2;        //chinese simplified
                        case "ZH-HANT": return 3;   //chinese traditional
                        case "JA": return 4;
                        default: return 5;
                    }
                }));

                redisUtil.set(redisKey, languages, timeoutMillis);
                return languages;
            } else {
                return Collections.emptyList();
            }
        } catch(Exception ex) {
            return Collections.emptyList();
        }
    }

    @Override
    public TranslateResponse translateText(String sourceLang, String content, List<String> targetLangList, HttpServletRequest request) {
        TranslateResponse responseList = new TranslateResponse();

        String url = "https://api-free.deepl.com/v2/translate";
        ApiRequester apiRequester = new ApiRequester(getClass(), request);

        Map<String, String> headers = new HashMap<>();
        headers.put("Authorization", apiKey);
        headers.put("Accept", "application/json");

        Map<String, Object> body = new HashMap<>();
        if (!sourceLang.isEmpty()) {
            body.put("source_lang", sourceLang);
        }

        for (String targetLang : targetLangList) {

            if (targetLang.isEmpty()) {
                continue;
            }

            body.put("text", Collections.singletonList(content));
            body.put("target_lang", targetLang);

            try {
                ApiResponse response = apiRequester.callApi(url, HttpMethod.POST, headers, body);
                if (response.isSuccess()) {
                    TranslateResponse translate = JsonConverter.deserializeObject(response.getResponseBody(), TranslateResponse.class);
                    for (TranslateResponse.Translations data : translate.getTranslations()) {
                        data.setTargetLang(targetLang);
                    }

                    responseList.getTranslations().addAll(translate.getTranslations());
                }
                else {
                    TranslateResponse.Translations errData = new TranslateResponse.Translations();
                    errData.setTargetLang(targetLang);
                    errData.setText("deepL번역기 API 요청에 실패했습니다");
                    errData.setDetected_source_language(sourceLang);
                    responseList.getTranslations().add(errData);
                }
            } catch(Exception ex){
                TranslateResponse.Translations errData = new TranslateResponse.Translations();
                errData.setTargetLang(targetLang);
                errData.setText("deepL번역기 API 요청에 실패했습니다");
                errData.setDetected_source_language(sourceLang);
                responseList.getTranslations().add(errData);
            }
        }

        return responseList;
    }

    @Override
    public TranslateFileResponse translateFile(String sourceLang, String targetLang, MultipartFile file, HttpServletRequest request) {
        TranslateFileResponse apiResponse = new TranslateFileResponse();

        String url = "https://api-free.deepl.com/v2/document";
        ApiRequester apiRequester = new ApiRequester(getClass(), request);

        Map<String, String> headers = new HashMap<>();
        headers.put("Authorization", apiKey);
        headers.put("Content-Type", "multipart/form-data");
        headers.put("Accept", "application/json");

        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();   // multipart/form-data 는 반드시 MultiValueMap<String, Object>
        if (!sourceLang.isEmpty()) {
            body.add("source_lang", sourceLang);
        }
        body.add("target_lang", targetLang);

        byte[] fileBytes;
        try {
            fileBytes = file.getBytes();
        } catch (IOException ex) {
            throw new UserException.FileException("파일을 읽을수 없습니다. " + ex);
        }

        body.add("file", new ByteArrayResource(fileBytes) {
            @Override
            public String getFilename() {
                return file.getOriginalFilename();
            }
        });

        try {
            ApiResponse response = apiRequester.callApi(url, HttpMethod.POST, headers, body);
            if (response.isSuccess()) {
                apiResponse = JsonConverter.deserializeObject(response.getResponseBody(), TranslateFileResponse.class);
                apiResponse.setFileSize(fileBytes.length);
            }
            else {
                throw new ApiException.ApiResponseException("파일번역 API 호출에 실패했습니다");
            }
        } catch(Exception ex){
            throw new ApiException.ApiResponseException("파일번역 API 호출에 실패했습니다");
        }

        return apiResponse;
    }

    @Override
    public TranslateFileResponse getTranslateRemainTime(String docId, String docKey, HttpServletRequest request) {
        TranslateFileResponse apiResponse = new TranslateFileResponse();

        String url = "https://api-free.deepl.com/v2/document/";
        url += docId;
        ApiRequester apiRequester = new ApiRequester(getClass(), request);

        Map<String, String> headers = new HashMap<>();
        headers.put("Authorization", apiKey);
        headers.put("Content-Type", "application/x-www-form-urlencoded");

        Map<String, Object> body = new HashMap<>();
        body.put("document_key", docKey);

        try {
            ApiResponse response = apiRequester.callApi(url, HttpMethod.POST, headers, body);
            if (response.isSuccess()) {
                apiResponse = JsonConverter.deserializeObject(response.getResponseBody(), TranslateFileResponse.class);
            }
            else {
                throw new ApiException.ApiResponseException("파일번역 API 호출에 실패했습니다");
            }
        } catch(Exception ex){
            throw new ApiException.ApiResponseException("파일번역 API 호출에 실패했습니다", ex);
        }

        return apiResponse;
    }

    @Override
    public ResponseEntity<Resource> donwloadTranslatedFile(String docId, String docKey, HttpServletRequest request) {
        String url = "https://api-free.deepl.com/v2/document/";
        url += docId;
        url += "/result";
        ApiRequester apiRequester = new ApiRequester(getClass(), request);

        Map<String, String> headers = new HashMap<>();
        headers.put("Authorization", apiKey);
        headers.put("Content-Type", "application/x-www-form-urlencoded");

        Map<String, Object> body = new HashMap<>();
        body.put("document_key", docKey);

        try {
            ApiFileResponse response = apiRequester.callFileApi(url, HttpMethod.POST, headers, body);
            if (response.isSuccess()) {
                return ResponseEntity.ok()
                        .contentType(MediaType.APPLICATION_OCTET_STREAM)
                        .body(new ByteArrayResource(response.getResponseBody()));
            }
            else {
                throw new ApiException.ApiResponseException("파일번역 API 호출에 실패했습니다");
            }
        } catch(Exception ex){
            throw new ApiException.ApiResponseException("파일번역 API 호출에 실패했습니다", ex);
        }
    }
}
