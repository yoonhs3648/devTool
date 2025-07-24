<%@ page import="yoon.hyeon.sang.util.PropertiesUtil" %>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title><tiles:getAsString name="title" ignore="true" /></title>

    <%
        String serverEnv = PropertiesUtil.getProperties("isReal", "Y");
        String faviconPath = "/resources/img/";
        if ("Y".equals(serverEnv)) {
            faviconPath += "lfc2.ico";  //운영
        } else {
            faviconPath += "lfc.ico";   //개발
        }
    %>
    <link rel="shortcut icon" href="/core<%= faviconPath%>" type="image/x-icon">

    <!-- 스크립트 시작 -->
        <!-- 공통 스크립트 포함 -->
        <tiles:insertAttribute name="commonScripts" ignore="true" />
        <!-- 다크모드 지원 스크립트 -->
        <tiles:insertAttribute name="darkModeScripts" ignore="true" />
    <!-- 스크립트 끝 -->

    <!-- css 시작-->

    <!-- css 끝 -->
</head>
<body>
    <!-- 헤더 -->
    <tiles:insertAttribute name="header" ignore="true" />
    <!-- 본문 -->
    <div id="main-content">
        <tiles:insertAttribute name="content" />
    </div>

    <!-- iframe 에러 레이어 -->
    <iframe id="iframe" src="" style="display:none; position:fixed; top:10%; left:10%; width:80%; height:80%; border:1px solid #dc3545; border-radius:6px; z-index:9999; background:#fff;"></iframe>

    <!-- 푸터 -->
    <tiles:insertAttribute name="footer" ignore="true" />
</body>
</html>
