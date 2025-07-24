package yoon.hyeon.sang.util;

import javax.servlet.http.HttpServletRequest;

public class RequestUtil {

    /// 요청자의 IP를 반환합니다
    public static String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        } else {
            ip = ip.split(",")[0];
        }
        return ip;
    }
}
