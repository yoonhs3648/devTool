package yoon.hyeon.sang.service;

import yoon.hyeon.sang.util.PropertiesUtil;

import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;

public class AdminManager {

    public static boolean isAdmin(String clientIp) {
        String adminListStr = PropertiesUtil.getProperties("admin-ip", "");

        Set<String> adminIpSet = Arrays.stream(adminListStr.split(";"))
                .map(String::trim)      // 앞뒤 공백 제거
                .filter(s -> !s.isEmpty()) // 빈 문자열 제거
                .collect(Collectors.toSet());

        return adminIpSet.contains(clientIp);
    }

    public static String makeAdminPageBtn() {

        String adminPageBtn = "<button id=\"adaminPage\" class=\"btn\" onclick=\"location.href='/admin/portal'\"  >\n" +
                "                <span class=\"label\">관리자페이지</span>\n" +
                "            </button>";

        return adminPageBtn;
    }
}
