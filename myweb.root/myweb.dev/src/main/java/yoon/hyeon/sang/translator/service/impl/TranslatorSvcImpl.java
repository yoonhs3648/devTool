package yoon.hyeon.sang.translator.service.impl;

import com.fasterxml.jackson.core.type.TypeReference;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;
import yoon.hyeon.sang.translator.dto.Languages;
import yoon.hyeon.sang.translator.dto.TranslateResponse;
import yoon.hyeon.sang.translator.service.TranslatorSvc;
import yoon.hyeon.sang.userObj.ApiResponse;
import yoon.hyeon.sang.util.ApiRequester;
import yoon.hyeon.sang.util.JsonConverter;
import yoon.hyeon.sang.util.PropertiesUtil;
import yoon.hyeon.sang.util.RedisUtil;

import javax.servlet.http.HttpServletRequest;
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
    public TranslateResponse doTranslate(String sourceLang, String content, List<String> targetLangList, HttpServletRequest request) {
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
}
