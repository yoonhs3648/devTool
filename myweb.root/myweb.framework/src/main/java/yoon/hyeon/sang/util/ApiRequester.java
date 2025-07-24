package yoon.hyeon.sang.util;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.Marker;
import org.apache.logging.log4j.MarkerManager;
import org.springframework.http.*;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import yoon.hyeon.sang.exception.ApiException;
import yoon.hyeon.sang.exception.UserException;
import yoon.hyeon.sang.userObj.ApiResponse;

import javax.servlet.http.HttpServletRequest;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Collections;
import java.util.Map;

/// API 요청 템플릿
///TODO: 향후 Cookie, User-Agent, Referer 등 인자가 추가될때 추가개발 예정
public class ApiRequester {

    private final String clientIP;
    private final Logger logger;
    private static final Marker API_MAKER = MarkerManager.getMarker("API");

    public ApiRequester(Class<?> className, HttpServletRequest request) {
        this.clientIP = RequestUtil.getClientIp(request);
        this.logger = LogManager.getLogger(className);
    }

    public ApiResponse callApi(String url, HttpMethod method, Map<String, String> headersMap) {
        return callApi(url, method, headersMap, Collections.emptyMap());
    }

    public ApiResponse callApi(String url, HttpMethod method, Map<String, String> headersMap, Map<String, ?> bodyMap) {
        RestTemplate restTemplate = new RestTemplate();

        // 헤더 설정
        HttpHeaders headers = new HttpHeaders();
        if (headersMap != null) {
            headers.setAll(headersMap);
        }

        // Content-Type 설정
        String contentTypeStr = headersMap != null ? headersMap.get("Content-Type") : null;
        MediaType contentType;
        if (contentTypeStr != null) {
            try {
                contentType = MediaType.parseMediaType(contentTypeStr);
            } catch (Exception e) {
                throw new ApiException.InvalidContentType(e);   //유효하지않은 ContentType 예외처리
            }
        } else {
            contentType = MediaType.APPLICATION_JSON;
        }
        headers.setContentType(contentType);

        HttpEntity<?> requestEntity;
        String finalUrl = url;

        // HTTP METHOD에 따라 URL, BODY 처리
        if (method == HttpMethod.GET) {
            if (bodyMap != null && !bodyMap.isEmpty()) {
                finalUrl = appendQueryParams(url, bodyMap); //GET요청에 BODY값이 있으면 쿼리스트링으로 변환
            }
            requestEntity = new HttpEntity<>(headers);
        } else if (MediaType.APPLICATION_FORM_URLENCODED.equals(contentType)) {     //Content-Type = application/x-www-form-urlencoded 인 경우
            MultiValueMap<String, String> formBody = new LinkedMultiValueMap<>();
            for (Map.Entry<String, ?> entry : bodyMap.entrySet()) {
                formBody.add(entry.getKey(), entry.getValue().toString());
            }
            requestEntity = new HttpEntity<>(formBody, headers);
        } else {
            requestEntity = new HttpEntity<>(bodyMap, headers);     // 그외의 Content-Type (application/json, application/xml 등..)
        }

        //RequestInfo Logging
        logger.debug(API_MAKER, "== [API Request] ==");
        logger.debug(API_MAKER, "Request URL : {}", finalUrl);
        logger.debug(API_MAKER, "Http Method : {}", method);
        logger.debug(API_MAKER, "Request Headers : {}", headers);
        logger.debug(API_MAKER, "Request Body : {}", bodyMap);
        logger.debug(API_MAKER, "================");

        long startTime = System.currentTimeMillis();
        try {
            ResponseEntity<String> response = restTemplate.exchange(finalUrl, method, requestEntity, String.class);
            long endTime = System.currentTimeMillis();
            long durationMs = endTime - startTime;

            //ResponseInfo Logging
            logger.debug(API_MAKER, "== [API Response Success] ==");
            logger.debug(API_MAKER, "Status Code : {}", response.getStatusCodeValue());
            logger.debug(API_MAKER, "Response headers : {}", response.getHeaders());
            logger.debug(API_MAKER, "Response Body : {}", response.getBody());
            logger.debug(API_MAKER, "durationMs : {}ms", durationMs);
            logger.debug(API_MAKER, "================");

            return new ApiResponse(response.getStatusCodeValue(), response.getHeaders(), response.getBody(), durationMs);

        } catch (HttpClientErrorException | HttpServerErrorException ex) {
            // 400,500 번때 에러일 경우
            logger.error(API_MAKER, "== [API Response Error] ==");
            logger.error(API_MAKER, "Status Code : {}", ex.getRawStatusCode());
            logger.error(API_MAKER, "Response headers : {}", ex.getResponseHeaders());
            logger.error(API_MAKER, "Response Body: {}", ex.getResponseBodyAsString());
            logger.error(API_MAKER, "durationMs : {}ms", System.currentTimeMillis() - startTime);
            logger.error(API_MAKER, "================");

            return new ApiResponse(ex.getRawStatusCode(), ex.getResponseHeaders(), ex.getResponseBodyAsString(), 0);
        } catch (RestClientException ex) {
            // Http 응답이 없는 경우 (연결실패, DNS 오류 등..)
            logger.error(API_MAKER, "== [API No Response Error] ==");
            logger.error(API_MAKER, "에러 메시지: {}", ex.getMessage());
            logger.error(API_MAKER, "durationMs : {}ms", System.currentTimeMillis() - startTime);
            logger.error(API_MAKER, "================");

            throw new ApiException.NoHttpResponseException(ex);
        }
    }

    public String appendQueryParams(String url, Map<String, ?> params) {
        if (params == null || params.isEmpty()) return url;

        StringBuilder sb = new StringBuilder(url);
        if (!url.contains("?")) {
            sb.append("?");
        } else if (!url.endsWith("&") && !url.endsWith("?")) {
            sb.append("&");
        }

        for (Map.Entry<String, ?> entry : params.entrySet()) {
            try {
                String key = URLEncoder.encode(entry.getKey(), "UTF-8");
                String value = URLEncoder.encode(entry.getValue().toString(), "UTF-8");
                sb.append(key).append("=").append(value).append("&");
            } catch (UnsupportedEncodingException e) {
                throw new UserException.URLEncodingException(e);
            }
        }

        sb.setLength(sb.length() - 1);
        return sb.toString();
    }
}
