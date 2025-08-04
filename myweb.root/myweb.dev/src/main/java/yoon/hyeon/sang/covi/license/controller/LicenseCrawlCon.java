package yoon.hyeon.sang.covi.license.controller;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import yoon.hyeon.sang.covi.license.dto.CustomerMessage;
import yoon.hyeon.sang.covi.license.dto.CustomerMessageDetail;
import yoon.hyeon.sang.covi.license.service.LicenseCrawlSvc;

import javax.servlet.http.HttpServletRequest;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.HashMap;
import java.util.Map;

@Controller
public class LicenseCrawlCon {

    @Autowired
    private LicenseCrawlSvc licenseCrawlSvc;

    @RequestMapping(value = "/crawl/custom", method = RequestMethod.GET)
    public @ResponseBody Map<String,Object> getCustomerMessageId(HttpServletRequest request, @RequestParam String customerName) throws UnsupportedEncodingException {
        Map<String, Object> returnMap = new HashMap<>();
        try{
            String decodedCustomerName = URLDecoder.decode(customerName, "UTF-8");
            CustomerMessage customerMessage = licenseCrawlSvc.getCustomerMessageId(request, decodedCustomerName.trim());
            returnMap.put("customerList", customerMessage.getList());
            returnMap.put("status", customerMessage.getStatus());
        } catch (Exception e) {
            throw e;
        }

        return returnMap;
    }

    @RequestMapping(value = "/crawl/customInfo", method = RequestMethod.GET)
    public @ResponseBody Map<String,Object> getCustomerMessageDetail(HttpServletRequest request, @RequestParam String messageID){
        Map<String, Object> returnMap = new HashMap<>();

        CustomerMessageDetail customerMessageDetail = licenseCrawlSvc.getCustomerMessageDetail(request, messageID.trim());
        returnMap.put("customerMessageDetail", customerMessageDetail.getList());
        returnMap.put("status", customerMessageDetail.getStatus());

        return returnMap;
    }
}
