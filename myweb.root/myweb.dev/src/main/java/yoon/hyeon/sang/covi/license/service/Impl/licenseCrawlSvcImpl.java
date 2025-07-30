package yoon.hyeon.sang.covi.license.service.Impl;

import com.fasterxml.jackson.core.type.TypeReference;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;
import yoon.hyeon.sang.covi.license.dto.CustomerMessage;
import yoon.hyeon.sang.covi.license.dto.CustomerMessageDetail;
import yoon.hyeon.sang.covi.license.service.licenseCrawlSvc;
import yoon.hyeon.sang.exception.ApiException;
import yoon.hyeon.sang.translator.dto.Languages;
import yoon.hyeon.sang.userObj.ApiResponse;
import yoon.hyeon.sang.util.ApiRequester;
import yoon.hyeon.sang.util.JsonConverter;
import yoon.hyeon.sang.util.PropertiesUtil;
import yoon.hyeon.sang.util.RedisUtil;

import javax.servlet.http.HttpServletRequest;
import java.util.*;

@Service
public class licenseCrawlSvcImpl implements licenseCrawlSvc {

    public static final String cookie = PropertiesUtil.getProperties("covi.license.cookie");

    @Override
    public CustomerMessage getCustomerMessageId(HttpServletRequest request, String customerName) {

        String url = "https://gw4j.covision.co.kr/groupware/board/selectMessageGridList.do";

        //헤더
        Map<String, String> headers = new HashMap<>();
        if (!cookie.isEmpty()){
            headers.put("cookie", cookie);
        }
        headers.put("Content-Type", "application/x-www-form-urlencoded");
        headers.put("Accept", "application/json");

        //바디
        Map<String, String> body = new HashMap<>();
        body.put("pageNo", "1");
        body.put("pageSize", "50");     // 모든 고객사를 조회하기 위해 임의의 큰값을 사용
        body.put("bizSection", "Board");
        body.put("boardType", "Normal");
        body.put("viewType", "List");
        body.put("boxType", "Receive");
        body.put("menuID", "10");
        body.put("menuCode", "BoardMain");
        body.put("folderID", "6507");
        body.put("folderType", "Board");
        body.put("categoryID", "");
        body.put("searchType", "Subject");
        body.put("searchText", customerName);
        body.put("startDate", "");
        body.put("endDate", "");
        body.put("useTopNotice", "Y");
        body.put("useUserForm", "Y");
        body.put("approvalStatus", "R");
        body.put("readSearchType", "");
        body.put("communityID", "");
        body.put("searchFolderIDs", "");
        body.put("grCode", "");

        ApiRequester apiRequester = new ApiRequester(getClass(), request);
        try {
            ApiResponse response = apiRequester.callApi(url, HttpMethod.POST, headers, body);
            if (response.isSuccess()) {
                return JsonConverter.deserializeObject(response.getResponseBody(), CustomerMessage.class);
            } else {
                throw new ApiException.ApiResponseException("사내 고객사 정보 조회에 실패했습니다");
            }
        } catch(Exception ex) {
            throw ex;
        }
    }

    @Override
    public CustomerMessageDetail getCustomerMessageDetail(HttpServletRequest request, String messageID) {
        String url = "https://gw4j.covision.co.kr/groupware/board/selectMessageDetail.do";

        //헤더
        Map<String, String> headers = new HashMap<>();
        if (!cookie.isEmpty()){
            headers.put("cookie", cookie);
        }
        headers.put("Content-Type", "application/x-www-form-urlencoded");
        headers.put("Accept", "application/json");

        //바디
        Map<String, String> body = new HashMap<>();
        body.put("bizSection", "Board");
        body.put("version", "1");
        body.put("messageID", messageID);
        body.put("folderID", "6507");
        body.put("readFlagStr", "false");

        ApiRequester apiRequester = new ApiRequester(getClass(), request);
        try {
            ApiResponse response = apiRequester.callApi(url, HttpMethod.POST, headers, body);
            if (response.isSuccess()) {
                return JsonConverter.deserializeObject(response.getResponseBody(), CustomerMessageDetail.class);
            } else if (response.getStatusCode() == 302) {
                throw new ApiException.ExpireSessionException("세션 만료로 크롤링에 실패했습니다");
            } else {
                throw new ApiException.ApiResponseException("사내 고객사 정보 조회에 실패했습니다");
            }
        } catch(Exception ex) {
            throw ex;
        }
    }
}
