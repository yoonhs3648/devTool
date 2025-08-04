package yoon.hyeon.sang.service.impl;

import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;
import yoon.hyeon.sang.exception.ApiException;
import yoon.hyeon.sang.service.ControlSvc;
import yoon.hyeon.sang.userObj.ApiResponse;
import yoon.hyeon.sang.util.ApiRequester;
import yoon.hyeon.sang.util.JsonConverter;

import java.util.HashMap;
import java.util.Map;

@Service
public class ControlSvcImpl implements ControlSvc {
    
    //TODO 개발 대기중

    @Override
    public String callFido(String logonID) {
//        String url = "https://gw4j.covision.co.kr/groupware/board/selectMessageDetail.do";
//
//        //헤더
//        Map<String, String> headers = new HashMap<>();
//        if (!cookie.isEmpty()){
//            headers.put("cookie", cookie);
//        }
//        headers.put("Content-Type", "application/x-www-form-urlencoded");
//        headers.put("Accept", "application/json");
//        headers.put("User-Agent", userAgent);
//
//        //바디
//        Map<String, String> body = new HashMap<>();
//        body.put("bizSection", "Board");
//        body.put("version", "1");
//        body.put("messageID", messageID);
//        body.put("folderID", "6507");
//        body.put("readFlagStr", "false");
//
//        ApiRequester apiRequester = new ApiRequester(getClass(), request);
//        try {
//            ApiResponse response = apiRequester.callApi(url, HttpMethod.POST, headers, body);
//            if (response.isSuccess()) {
//                return JsonConverter.deserializeObject(response.getResponseBody(), CustomerMessageDetail.class);
//            } else if (response.isRedirect()) {
//                controlSvc.callFido(logonID);
//                throw new ApiException.ExpireSessionException("세션 만료로 크롤링에 실패했습니다. 쿠키값을 갱신합니다.");
//            } else {
//                throw new ApiException.ApiResponseException("사내 고객사 정보 조회에 실패했습니다");
//            }
//        } catch(Exception ex) {
//            throw ex;
//        }
        return null;
    }
}
