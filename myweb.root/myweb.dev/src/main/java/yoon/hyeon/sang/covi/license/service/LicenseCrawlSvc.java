package yoon.hyeon.sang.covi.license.service;

import yoon.hyeon.sang.covi.license.dto.CustomerMessage;
import yoon.hyeon.sang.covi.license.dto.CustomerMessageDetail;

import javax.servlet.http.HttpServletRequest;

public interface LicenseCrawlSvc {

    public CustomerMessage getCustomerMessageId(HttpServletRequest request, String customerName);
    public CustomerMessageDetail getCustomerMessageDetail(HttpServletRequest request, String messageID);
}
