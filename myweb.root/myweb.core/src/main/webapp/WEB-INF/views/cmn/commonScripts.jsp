<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- 최상위 템플릿 CSS -->
<style>
    /* 기본 스타일 */
    html, body {
        font-family: Arial, sans-serif;
        margin: 0; padding: 0;
        height: 100%;
        min-width: 100%;
        background-color: #f9f9f9;
    }

    body {
        display: inline-flex;
        flex-direction: column;
    }

    header, footer {
        width: 100%;
        padding: 20px;
        box-sizing: border-box;
    }

    #main-content {
        flex: 1;    /* header, footer를 제외한 나머지 영역 차지 */
        display: flex;
    }
</style>

<!-- 공통 CSS 로드 -->
<link class="theme-link" rel="stylesheet" type="text/css" href="/core/resources/css/default.css">

<!-- 공통 JS 로드 -->
<script type="text/javascript" src="/core/resources/js/jquery-3.6.0.min.js"></script>
<script type="text/javascript" src="/core/resources/js/axios.min.js"></script>
<script type="text/javascript" src="/core/resources/js/common.js"></script>
<script type="text/javascript" src="/core/resources/js/utils.js"></script>
<script type="text/javascript" src="/core/resources/js/modalUtil.js"></script>
